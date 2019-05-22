import argparse
import os
import sys
import time

import h5py
import numpy as np

from utils import summate, integral_image, load_volume, save_imgs, \
                  threshold_bradley_nd


def parse_args(args=None):
    p = argparse.ArgumentParser()

    p.add_argument('--input',
                   help='path to the input volume',
                   type=str)

    p.add_argument('--output',
                   help='path to write images to',
                   type=str)

    p.add_argument('--depth',
                   help='the number of frames to batch process',
                   type=int)

    p.add_argument('--window',
                   help='shape of the pixel window to use',
                   type=int,
                   nargs='*')

    return p.parse_args()


def main():
    args = parse_args()

    vol = load_volume(args.input, stop=args.depth, ext='.bmp')

    with h5py.File('downsampled_histogram.h5', 'r') as f:
        hist = f['hist'][:]
    hist = np.cumsum(hist)
    vol = np.floor(255 * hist[vol])
    vol[vol > 255] = 255
    vol[vol < 0] = 0
    vol = vol.astype(np.uint8)

    if not os.path.isdir(args.output):
        os.makedirs(args.output)

    sums, counts = summate(integral_image(vol), np.asarray(args.window))

    for t in np.arange(0, 1, 0.01):
        seg = threshold_bradley_nd(vol, t=t, s=np.asarray(args.window),
                                   sums=sums, counts=counts)
        dirname = os.path.join(args.output, '{0:.2f}'.format(t))
        save_imgs(seg * 255, dirname)


if __name__ == '__main__':
    start = time.time()
    main()
    print('Sweep complete in {0:.2f}'.format(time.time() - start))
            
