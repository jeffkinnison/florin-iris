#!/usr/bin/env bash

# This script will run FLoRIN on the Pupil dynamics dataset using the settings
# that generated the results in by Kinnison et al.

# Path to the downsampled Pupil Dynamics dataset
dataset=$1

# Segment each video in the dataset and save the masks
for subject_directory in $dataset/*; do
    subject="$(basename $subject_directory)"
    if [ ! -f "${subject}_time.out" ]; then
        python florin.py \
            --input $subject_directory \
            --output segmentation/$subject \
            --parameter-file params.json \
            --depth 5 \
            --recover-parameters
    fi
done
