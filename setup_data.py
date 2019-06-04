import argparse
import os
import shutil

from skimage.io import imread, imsave
from skimage.transform import resize


def parse_args(args=None):
    p = argparse.ArgumentParser()
    p.add_argument('--input', type=str, help='path to orginal images')
    p.add_argument('--output', type=str, help='path to save resized images to')
    p.add_argument('--new-shape', type=int, nargs='*',
                   help='shape of output images')
    return p.parse_args()


def main():
    args = parse_args()

    for root, dirs, files in os.walk(args.input):
        if len(files) > 0:
            video = os.path.basename(root)
            print('Resizing {}'.format(video))
            os.makedirs(os.path.join(args.output, video), exist_ok=True)
            for f in files:
                try:
                    img = imread(os.path.join(root, f))
                    img = resize(img, args.new_shape)
                    fname = os.path.join(args.output, video, f)
                    imsave(fname, img)
                except OSError:
                    shutil.copy(os.path.join(root, f),
                                os.path.join(args.output, video, f))
            print('Done')


if __name__ == '__main__':
    main()
