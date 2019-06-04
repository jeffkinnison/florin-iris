import argparse
import json
import os
import shutil
import sys
import time

import h5py
import numpy as np
import scipy.ndimage as ndi
from skimage.draw import circle
from skimage.measure import label, regionprops
from skimage.morphology import remove_small_holes, remove_small_objects, watershed

from utils import load_volume, save_imgs, threshold_bradley_nd, \
                  integral_image, summate


def parse_args(args=None):
    p = argparse.ArgumentParser()

    p.add_argument('-i', '--input',
        help='path to the video directory',
        type=str)
    p.add_argument('-o', '--output',
        help='directory to write the masks to',
        type=str)
    p.add_argument('-p', '--parameter-file',
        help='path to the json file with video parameters',
        type=str,
        default='params.json')
    p.add_argument('--t-iris',
        help='threshold value for the iris in [0, 1]',
        type=float)
    p.add_argument('--t-pupil',
        help='threshold value for the pupil in [0, 1]',
        type=float)
    p.add_argument('--window-iris',
        help='threshold window for the iris, ex. 2 256 256',
        type=int,
        nargs='*')
    p.add_argument('--window-pupil',
        help='threshold window for the pupil, ex. 4 64 64',
        type=int,
        nargs='*')
    p.add_argument('--depth',
        help='number of images to process in 3D at a time',
        type=int,
        default=5)
    p.add_argument('--recover-parameters',
        help='pass to recover the threshold values and windo sizes',
        action='store_true')
    p.add_argument('--save-iris',
        help='pass to save raw iris masks',
        action='store_true')
    p.add_argument('--save-pupil',
        help='pass to save pupil masks',
        action='store_true')
    
    return p.parse_args(args)


def main():
    args = parse_args()
    images = args.input
    vol = load_volume(images, ext='.bmp')

    with h5py.File('downsampled_histogram.h5', 'r') as f:
        hist = f['hist'][:]
        hist = np.cumsum(hist)

    vol = np.floor(255 * hist[vol])
    vol[vol > 255] = 255
    vol[vol < 0] = 0
    vol = vol.astype(np.uint8)

    sel = ndi.generate_binary_structure(3, 1)
    sel[0] = 0
    sel[2] = 0

    subject = os.path.basename(args.input)
    print(subject)
    params = {}

    if args.recover_parameters:
        # try:
            with open(args.parameter_file, 'r') as f:
                params = json.load(f)
                t_iris = params[subject]['t_iris']
                t_pupil = params[subject]['t_pupil']
                window_iris = tuple(params[subject]['window_iris'])
                window_pupil = tuple(params[subject]['window_pupil'])
        # except KeyError:
        #    pass

    if args.t_iris is not None:
        t_iris = args.t_iris
    
    if args.t_pupil is not None:
        t_pupil = args.t_pupil
    
    if args.window_iris is not None:
        window_iris = tuple(args.window_iris)
    
    if args.window_pupil is not None:
        window_pupil = tuple(args.window_pupil)
    
    depth = args.depth 
    radius = int(min(vol.shape[1], vol.shape[2]) / 4)

    if args.save_iris:
        iris_seg = np.zeros(vol.shape, dtype=np.uint8)
    if args.save_pupil:
        pupil_seg = np.zeros(vol.shape, dtype=np.uint8)
    seg = np.zeros(vol.shape, dtype=np.uint8)
    
    sums, counts = None, None

    for i in range(0, vol.shape[0], depth):
        subvol = np.copy(vol[i:i + depth])
        orig_shape = subvol.shape
        if subvol.shape[0] < depth:
            subvol = np.concatenate(
                [subvol,
                 np.repeat(
                    subvol[-1].reshape(1, subvol.shape[1], subvol.shape[2]),
                    depth - subvol.shape[0],
                    axis=0)],
                axis=0)

        if all([window_iris[j] == window_pupil[j] for j in range(len(window_iris))]):
            sums, counts = summate(integral_image(subvol), np.asarray(window_iris))

        # Iris Segmentation
        iris = 1.0 - threshold_bradley_nd(subvol, t=t_iris, s=window_iris,
                                          sums=sums, counts=counts)
        iris = ndi.binary_fill_holes(iris, structure=sel)
        
        # Pupil Segmentation
        pupil= 1.0 - threshold_bradley_nd(subvol, t=t_pupil, s=window_pupil,
                                          sums=sums, counts=counts)
        pupil = ndi.binary_fill_holes(pupil, structure=sel)
        pupil = ndi.binary_erosion(pupil, structure=sel)
        pupil = ndi.binary_dilation(pupil, structure=sel)
        pupil = ndi.binary_dilation(pupil, structure=sel).astype(np.uint8)
        pupil_collapsed = (np.sum(pupil, axis=0) > 1).astype(np.uint8)
        pupil_collapsed = remove_small_objects(
            label(pupil_collapsed), min_size=200).astype(np.uint8)
        circle_mask = np.zeros(pupil_collapsed.shape, dtype=np.uint8)
       
        try:
            objs = regionprops(
                label(pupil_collapsed), 
                intensity_image=np.mean(subvol, axis=0).astype(np.uint8))
            for obj in objs:
                if obj.convex_area > 1000 and obj.solidity < 0.5 or np.sum(obj.inertia_tensor_eigvals) == 0:
                    pupil_collapsed[obj.coords[:, 0], obj.coords[:, 1]] = 0

            pupil_idx = np.argmax([
                o.area * np.abs(o.orientation) * o.solidity
                / (o.eccentricity + 1e-7) / (o.inertia_tensor_eigvals[0]
                - o.inertia_tensor_eigvals[1]) for o in objs])
            pupil_obj = objs[pupil_idx]
            circle_coords = circle(
                pupil_obj.centroid[0],
                pupil_obj.centroid[1],
                radius,
                shape=pupil_collapsed.shape)
            circle_mask[circle_coords] = 1
        except (ValueError, IndexError):
            pass
        
        pupil = np.logical_and(
            pupil,
            np.repeat(pupil_collapsed.reshape((1,) + pupil_collapsed.shape),
                pupil.shape[0], axis=0))

        # Final Segmentation
        final = np.logical_xor(iris, pupil).astype(np.uint8)
        final = ndi.binary_dilation(final, structure=sel)
        final[:, circle_mask == 0] = 0

        # Save it
        seg[i:i + depth] = final[:orig_shape[0]]
        if args.save_iris:
            iris_seg[i:i + depth] += iris[:orig_shape[0]]
        if args.save_pupil:
            pupil_seg[i:i + depth] += pupil[:orig_shape[0]]

    seg[:, np.sum(seg, axis=0) < 20] = 0
    seg = ndi.binary_erosion(seg, structure=sel)
    seg = ndi.binary_erosion(seg, structure=sel).astype(np.uint8)

    outdir = os.path.join(args.output, subject)
    if not os.path.isdir(outdir):
        os.makedirs(outdir)
    seg[seg.nonzero()] = 255
    save_imgs(seg, outdir, prefix=subject)

    if args.save_iris:
        outdir = os.path.join(args.output, 'iris', subject)
        if not os.path.isdir(outdir):
            os.makedirs(outdir)
        iris_seg[iris_seg.nonzero()] = 255
        save_imgs(iris_seg, outdir)
    
    if args.save_pupil:
        outdir = os.path.join(args.output, 'pupil', subject)
        if not os.path.isdir(outdir):
            os.makedirs(outdir)
        pupil_seg[pupil_seg.nonzero()] =  255
        save_imgs(pupil_seg, outdir)

    shutil.copy(args.parameter_file, args.parameter_file + '.bak')

    with open(args.parameter_file, 'w') as f:
        params[subject] = {
            't_iris': t_iris,
            't_pupil': t_pupil,
            'window_iris': window_iris,
            'window_pupil': window_pupil,
        }
        json.dump(params, f)


if __name__ == '__main__':
    start = time.time()
    main()
    end  = time.time()
    print('Segmentation completed in {0:.3f}s'.format(end - start))
    fname = os.path.basename(sys.argv[2]) + '_time.out'
    with open(fname, 'w') as f:
        f.write(str(end - start))
