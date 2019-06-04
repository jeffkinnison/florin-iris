import functools
import glob
import itertools
import os

import h5py
import numpy as np
import scipy.ndimage


def imcomplement(img):
    if img.dtype.kind in 'iu':
        x = np.iinfo(img.dtype).max if np.max(img) > 1 or np.min(img) < 0 else 1
        img = x - img
    elif img.dtype.kind in 'fc':
        x = np.finfo(img.dtype).max
        img = x - img
    elif img.dtype.kind in 'b':
        img = not img
    else:
        img = None

    return img


def integral_image(img):
    int_img = np.copy(img)
    for i in range(len(img.shape) - 1, -1, -1):
        int_img = np.cumsum(int_img, axis=i, dtype=np.uint32)
    return int_img


def summate(int_img, s, return_counts=True):
    """Do weird vectorization shit here."""
    grids = np.meshgrid(*[np.arange(int_img.shape[i], dtype=np.int32) for i in range(len(int_img.shape))], indexing='ij', sparse=True)
    grids = np.array(grids)
    # grids = grids.reshape([grids.shape[0], np.product(grids.shape[1:])])
    s = np.round(s / 2).astype(np.uint32).reshape((s.size, 1))
    img_shape = np.asarray(int_img.shape)
    #img_shape = np.array([np.full(grids[i].shape, img_shape[i]) for i in range(len(img_shape))])
    lo = (grids.copy() - s.T)[0]
    hi = (grids + s.T)[0]
    for i in range(len(lo)):
        lo[i][lo[i] < 0] = 0
        x = hi[i] >= img_shape[i]
        hi[i][x] = (img_shape[i] - 1)
    bounds = np.array([[lo[i], hi[i]] for i in range(lo.shape[0])])
    del grids, lo, hi, img_shape
    indices = np.array(list(itertools.product([1, 0], repeat=len(int_img.shape))), dtype=np.uint8)
    ref = sum(indices[0]) & 1
    parity = np.array([1 if (sum(i) & 1) == ref else -1 for i in indices], dtype=np.int8)
    sums = np.zeros(int_img.shape, dtype=np.int32)  # ravel().shape, dtype=np.int32)
    for i in range(len(indices)):
        idx = list(bounds[j, indices[i][j]] for j in range(len(indices[i])))
        sums += np.multiply(int_img[idx], parity[i], dtype=np.int32)
    sums = sums.ravel()
    if return_counts:
        counts = functools.reduce(np.multiply, bounds[:, 1] - bounds[:, 0])
        return sums, counts.ravel()
    else:
        return sums


def binarize(img, sums, count, t):
    out = np.ones(np.prod(img.shape), dtype=np.bool)
    out[img.ravel() * count <= sums.ravel() * t] = False
    return np.reshape(out, img.shape).astype(np.uint8)


def threshold_bradley_nd(img, s=None, t=None, sums=None, counts=None):
    if s is None:
        s = np.round(np.array(list(img.shape)) / 8)
    elif isinstance(s, (list, tuple)):
        s = np.asarray(s)

    if t is None:
        t = 15.0
    else:
        t = float(t)

    if t > 1.0:
        t = (100.0 - t) / 100.0
    elif t >= 0.0 and t <= 1.0:
        t = 1.0 - t
    else:
        raise ValueError('t must be positive')

    orig_shape = None
    if img.shape[0] < s.shape[0]:
        orig_shape = img.shape
        img = np.repeat(img, s.shape[0], axis=0).astype(np.uint8)

    if sums is None or counts is None:
        int_img = integral_image(img)
        sums, counts = summate(int_img, s)

    out = binarize(img, sums, counts, t)
    
    if orig_shape is not None:
        out = out[:orig_shape[0]].reshape(orig_shape)

    return out


def load_volume(path, start=None, stop=None, ext='', grayscale=True, channel=0):
    if path.find('*') < 0 and os.path.isdir(path):
        path = os.path.join(path, '*')
    imgs = sorted(glob.glob(path + ext))

    if stop is not None:
        imgs = imgs[:stop]
    if start is not None:
        imgs = imgs[start:]

    vol = None

    for i in range(len(imgs)):
        img = scipy.ndimage.imread(imgs[i])
        if grayscale and img.ndim == 3:
            img = np.squeeze(np.copy(img[:, :, channel]))

        if vol is None:
            vol = np.zeros((len(imgs), img.shape[0], img.shape[1]),
                           dtype=np.uint8)

        vol[i] += img.astype(np.uint8)

    return vol


def save_imgs(vol, path, start=0, stop=None, imtype='png', prefix=''):
    if not os.path.isdir(path):
        os.makedirs(path)
    leading = 3
    if prefix:
        prefix= prefix + '_'
    for i in range(vol.shape[0]):
        n = str(i + start).zfill(leading)
        f = ''.join([prefix, n, '.', imtype])
        scipy.misc.imsave(os.path.join(path, f), vol[i], format=imtype)

