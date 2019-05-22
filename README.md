# FLoRIN for Iris Segmentation

This repository contains the code used in the paper "Learning-Free Iris Segmentation Revisited: A First Step Toward Fast Volumetric Operation Over Video Samples" published at the 2019 International Conference on Biometrics.

## Dependencies

To run this code, the following dependencies must be met.

### FLoRIN

- Python 3.4+
- numpy
- scipy
- scikit-image
- h5py

### OSIRIS

- gcc
- Python 3.4+
- OpenCV 2.14

### SegNet

- MATLAB r2018b

## Preparation

1. (Download)[http://svnext.it-sudparis.eu/svnview2-eph/ref_syst/Iris_Osiris_v4.1/ "OSIRIS v4.1"] and (install)[http://svnext.it-sudparis.eu/svnview2-eph/ref_syst/Iris_Osiris_v4.1/doc/ "OSIRIS v4.1 Documentation"] OSIRIS v4.1.
2. (Download)[https://www.mathworks.com/products/matlab.html "MATLAB Home Page"] and install MATLAB r2018b.
3. (Download)[] and install Python 3.4+. To reproduce this work, install Python 3.6.4 compiled with GCC 7.1.0.
4. Run the following code in a terminal:

```bash
python3 -m venv florin-env
pip3 install -r requirements.txt
source florin-env/bin/activate
```

5. Download the (Pupil Dynamics dataset)[].

## Segmentation

In a terminal, run

```bash
bash segment_and_time.sh /path/to/dataset /path/to/osiris/install
```

This script will configure and run all of the segmentation and timing code used to compare FLoRIN, SegNet, and OSIRIS.

## Matching

TODO

