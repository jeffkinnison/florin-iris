# FLoRIN for Iris Segmentation

This repository contains the code used in the paper "Learning-Free Iris Segmentation Revisited: A First Step Toward Fast Volumetric Operation Over Video Samples" published at the 2019 International Conference on Biometrics, Crete, Greece.

Pre-print available at: https://arxiv.org/abs/1901.01575

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

- MATLAB r2018b (or newer)

## Preparation

1. [Download](http://svnext.it-sudparis.eu/svnview2-eph/ref_syst/Iris_Osiris_v4.1/ "OSIRIS v4.1") and [install](http://svnext.it-sudparis.eu/svnview2-eph/ref_syst/Iris_Osiris_v4.1/doc/ "OSIRIS v4.1 Documentation") OSIRIS v4.1. A local copy of OSIRIS is also included into this repository (`./matching/OSIRIS_v4.1`). To reproduce this work, compile with GCC 7.1.0 following the OSIRIS installation instructions.
2. [Download](https://www.mathworks.com/products/matlab.html "MATLAB Home Page") and install MATLAB.
3. [Download](https://www.python.org/downloads/release/python-364/ "Download Python 3.6.4") and install Python 3.4+. To reproduce this work, install Python 3.6.4 compiled with GCC 7.1.0.
4. Request a copy of the [Warsaw-BioBase-Pupil-Dynamics-v3 dataset](http://zbum.ia.pw.edu.pl/EN/node/46 "Warsaw Biobase Pupil Dynamics v3 Dataset).

## Segmentation

In a terminal, run

```bash
bash segment_and_time.sh /path/to/dataset /path/to/florin/virtual/environment /path/to/osiris/install
```

This script will attempt to install FLoRIN and its dependencies in a virtual environment, prepare the dataset and configuration files, and run all of the segmentation and timing code used to compare FLoRIN, OSIRIS, and SegNet in sequence.

## Matching

1. Put the segmentation masks (either FLoRIN- or SegNet-based) into `./matching/imageData/Warsaw-BioBase-Pupil-Dynamics-v3-segmentation-masks` folder
2. Compile OSIRIS (you will need to edit the `makefile` accordingly to your system configuration). Note that OSIRIS requires OpenCV 2.4.x correctly installed. The executable `osiris` file should appear in `matching/OSIRIS_v4.1/src` folder.  
3. Open Matlab, go to the folder with `icb2019.m` m-file and run it. This m-file calls other scripts that go through the process step by step. The entire process may take more than an hour, depending on your hardware.
4. The matching scores should appear in the `matchingResults` folder as `res_matching_genuine.txt` and `res_matching_impostor.txt`.

# Ofiicial FLoRIN Software

[The official FLoRIN software release](https://github.com/jeffkinnison/florin "FLoRIN Pipeline Repo") is now available as a pip-installable Python package! We are currently working on translating the FLoRIN pipeline used in this study to the new code and will update the repository when it is ready. To get FLoRIN for yourself, install Python 3.4+ and run 

```bash
pip install florin
```

This code is under active development, and we welcome any contributions from the community.
