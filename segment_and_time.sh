#!/usr/bin/env bash

# Path to the root directory of the Pupil Dynamics dataset
dataset=$1
# Path to the root directory of the OSIRIS install
osiris_install=$2

base=$(pwd)

# Python environment setup
if [ ! -d 'florin-env']; then
    python3 -m venv florin-env
    source florin-env/bin/activate
    pip install -r requirements.txt
else
    source florin-env/bin/activate
fi

# Downsample the dataset and equalize the histogram
python setup_data.py --dataset $dataset --output $base/downsampled_320_240

# FLoRIN Segmentation and Timing

cd florin
bash $base/time_florin.sh $dataset
cd $base

# OSIRIS Segmentation and Timing

cd osiris
bash setup_osiris.sh
bash $base/time_osiris.sh $dataset $osiris_install
cd $base

# SegNet Segmentation and Timing
cd segnet
bash $base/time_segnet.sh $dataset
cd $base

