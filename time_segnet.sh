#!/usr/bin/env bash

module load matlab/2018b

dataset=$1

export CUDA_VISIBLE_DEVICES=3

for subject_directory in $dataset/*; do
    subject="$(basename $subject_directory)"
    out_directory=$base/segnet_seg/$subject
    mkdir -p $out_directory
    csv_file="${subject}_time.csv"

    if [ ! -f "$csv_file" ]; then
        /afs/crc.nd.edu/x86_64_linux/m/matlab/R2018b/bin/exe/matlab -nosplash -nodisplay -nodesktop -nojvm  -r "segnet('$subject_directory/','$out_directory/','$csv_file');exit"
    fi
done
