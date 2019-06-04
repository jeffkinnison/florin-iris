#!/usr/bin/env bash

# Path to the root directory of the Pupil Dynamics dataset
dataset=$1

# Path to FLoRIN virtual environment
florin_env=$2

# Path to the root directory of the OSIRIS install
osiris_install=$3

base=$(pwd)

# Python environment setup
module load python/3.6.4
if [ ! -d "$base/$florin_env" ]; then
    python3 -m venv $florin_env
    source$base/ $florin_env/bin/activate
    pip install -r requirements.txt
else
    source $florin_env/bin/activate
fi

florin_path="$(realpath $florin_env)"

# Downsample the dataset and equalize the histogram
if [ ! -d "$base/downsampled_320_240" ]; then
    python setup_data.py \
        --input $dataset \
        --output $base/downsampled_320_240 \
        --new-shape 240 320
fi

dataset="$base/downsampled_320_240"

# FLoRIN Segmentation and Timing

cd florin
# bash time_florin.sh $dataset $florin_env
cd $base

# OSIRIS Segmentation and Timing

cd osiris
output=$base/osiris/osiris_segmentation
bash setup_osiris.sh $dataset $osiris_install $output 
bash copy_image_list.sh $dataset
# bash time_osiris.sh $dataset $osiris_install
cd $base

# SegNet Segmentation and Timing
cd segnet
bash time_segnet.sh $dataset
cd $base

