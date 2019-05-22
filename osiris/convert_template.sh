#!/usr/bin/env bash

module load python/2.7.14

base=$1
dataset=$base/downsampled_320_240

for subject_dir in $dataset/*; do
    subject="$(basename $subject_dir)"
    mkdir $subject
    
    sed "s@SUBJECT@$subject@" template/configuration.ini > $subject/configuration.ini
    python write_imagelist.py $subject_dir
done
