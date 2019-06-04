import os
import sys

files = os.listdir(sys.argv[1])
subject = os.path.basename(sys.argv[1])
with open(os.path.join(subject + '_config', 'imagelist.txt'), 'w') as f:
    for fname in sorted(files):
        f.write(fname + '\n')
