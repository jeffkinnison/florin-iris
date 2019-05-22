import glob
import os

import numpy as np

files = sorted(glob.glob('*.csv'))
times = np.zeros((len(files),))

for i, fname in enumerate(files):
    imgtime = np.loadtxt(fname)
    t = np.sum(imgtime)
    times[i] += t

subjects = sorted(glob.glob('/afs/crc.nd.edu/group/cvrl/scratch_12/jkinniso/downsampled_320_240/*'))
imgcount = np.zeros((len(subjects),))

for i, subject in enumerate(subjects):
    count = len(glob.glob(os.path.join(subject, '*.bmp')))
    imgcount[i] += count

fps = imgcount / times

print('Video Count: {}'.format(times.shape[0]))
print('Total Time to Segment: {0:.3f}'.format(np.sum(times)))
print('Mean Time Per Video: {0:.3f}'.format(np.mean(times)))
print('Total FPS: {0:.2f}'.format(np.sum(imgcount) / np.sum(times)))
print('Mean FPS: {0:.2f} +/- {1:.2f}'.format(np.mean(fps), np.std(fps)))

