#!/usr/bin/env bash

module load python/2.7.14

dataset=$1
osiris_install=$2
output=$3


for subject_dir in $dataset/*; do
    subject="$(basename $subject_dir)"
    subject_config="${subject}_config"
    mkdir "$subject_config"
    
    cp template/configuration.ini $subject_config

    sed -i "s@DATASET@$dataset@" $subject_config/configuration.ini  # > $subject_config/configuration.ini
    sed -i "s@OSIRIS_INSTALL@$osiris_install@" $subject_config/configuration.ini  # > $subject_config/configuration.ini
    sed -i "s@OUTPUT@$output@" $subject_config/configuration.ini  # > $subject_config/configuration.ini
    sed -i "s@SUBJECT@$subject@" $subject_config/configuration.ini  # > $subject_config/configuration.ini
    
    python write_imagelist.py $subject_dir
done
