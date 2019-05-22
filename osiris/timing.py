import argparse
import glob
import os 

import numpy as np

p = argparse.ArgumentParser()
p.add_argument(
    '--dataset',
    type=str,
    help='path to the directory containing the dataset')
)
args = p.parse_args()

files = sorted(glob.glob('*_time.out'))
times = np.zeros((len(files),))

for i, fname in enumerate(files):
    with open(fname, 'r') as f:
        tstring = f.readline().strip().split()[2]
    print(fname, tstring)
    colon = tstring.find(':')
    dot = tstring.find('.')
    word = tstring.find('e')
    m = int(tstring[:colon])
    s = int(tstring[colon + 1:dot])
    ms = int(tstring[dot + 1:word])

    print(m, s, ms)

    t = (60 * m) + s + (ms / 1000)
    times[i] += t

subjects = sorted(glob.glob(os.path.join(args.dataset, '*')))
imgcount = np.zeros((len(subjects),))

for i, subject in enumerate(subjects):
    count = len(glob.glob(os.path.join(subject, '*.bmp')))
    imgcount[i] += count

fps = imgcount[:times.shape[0]] / times

print('Video Count: {}'.format(times.shape[0]))
print('Total Time to Segment: {0:.3f}'.format(np.sum(times)))
print('Mean Time Per Video: {0:.3f}'.format(np.mean(times)))
print('Total FPS: {0:.2f}'.format(np.sum(imgcount) / np.sum(times)))
print('Mean FPS: {0:.2f} +/- {1:.2f}'.format(np.mean(fps), np.std(fps)))
