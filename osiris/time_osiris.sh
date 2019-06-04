#!/usr/bin/env bash

module use ~/Public/modulefiles
module load opencv/2.4.13

dataset=$1
osiris_install=$2

for subject_directory in $dataset/*; do
    subject="$(basename $subject_directory)"
    if [ ! -f "${subject}_time.out" ]; then
        mkdir -p osiris_segmentation/$subject
        config_file="./${subject}_config/configuration.ini"
        /usr/bin/time -o "${subject}_time.out" $osiris_install/src/osiris $config_file
    fi
done
