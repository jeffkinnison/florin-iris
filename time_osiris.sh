#!/usr/bin/env bash

module load opencv/2.4.13

dataset=$1

for subject_directory in $dataset/*; do
    subject="$(basename $subject_directory)"
    if [ ! -f "${subject}_time.out" ]; then
        mkdir $base/osiris_seg/$subject
        config_file="$dataset/$subject/configuration.ini"
        /usr/bin/time -o "${subject}_time.out" osiris $config_file
    fi
done
