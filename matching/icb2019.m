% Supplementary materials for the paper:
% Learning-Free Iris Segmentation Revisited: A First Step Toward Fast Volumetric Operation Over Video Samples
% Authors: Jeffery Kinnison, Mateusz Trokielewicz, Camila Carballo, Adam Czajka, Walter Scheirer
% Published at The 12th IAPR International Conference on Biometrics (ICB 2019), Crete, Greece
% Pre-print available at https://arxiv.org/abs/1901.01575
% _____________________________________________
% Author: Adam Czajka, May 2019, aczajka@nd.edu

clear all
close all
addpath('./mFiles');

disp('Conversion from JPEG 2000 to BMP (compatible with OSIRIS):')
jp2bmp
disp(['Done.';'     '])

disp('Hough transform-based circular approximation of iris boundaries:')
fitHoughCircles
disp(['Done.';'     '])

disp('Rescaling masks and boundary parameters to ISO resolution:')
rescaleToISO
disp(['Done.';'     '])

disp('Normalizing iris images and generating iris codes (it may take ~30 minutes for the entire dataset):')
generateIrisCodes
disp(['Done.';'     '])

disp('Generating genuine scores:')
generateGenuineScores
disp(['Done.';'     '])

disp('Generating impostor scores:')
generateImpostorScores
disp(['Done.';'     '])
