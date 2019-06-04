#!/usr/bin/env bash

# This script will run FLoRIN on the Pupil dynamics dataset using the settings
# that generated the results in by Kinnison et al.

# Path to the downsampled Pupil Dynamics dataset
dataset=$1
florin_env=$2


# Load the FLoRIN virtual environment
module load python/3.6.4
source $florin_env/bin/activate

# Segment each video in the dataset and save the masks
for subject_directory in $dataset/*; do
    subject="$(basename $subject_directory)"
    echo $subject
    if [ ! -f "${subject}_time.out" ]; then
        python florin.py \
            --input $subject_directory \
            --output florin_segmentation/$subject \
            --parameter-file params.json \
            --depth 5 \
            --recover-parameters
    fi
done
