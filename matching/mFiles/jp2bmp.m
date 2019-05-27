% Supplementary materials for the paper:
% Learning-Free Iris Segmentation Revisited: A First Step Toward Fast Volumetric Operation Over Video Samples
% Authors: Jeffery Kinnison, Mateusz Trokielewicz, Camila Carballo, Adam Czajka, Walter Scheirer
% Published at The 12th IAPR International Conference on Biometrics (ICB 2019), Crete, Greece
% Pre-print available at https://arxiv.org/abs/1901.01575
% _____________________________________________
% Author: Adam Czajka, May 2019, aczajka@nd.edu

clear all

DIR_JP2 = './imageData/Warsaw-BioBase-Pupil-Dynamics-v3/';
DIR_BMP = './interimFiles/Warsaw-BioBase-Pupil-Dynamics-v3-BMP/';

FILES = dir([DIR_JP2 '/*.jp2']);
disp(['Found ' num2str(length(FILES)) ' JPEG 2000 files -- processing ...']);

ALL_FILES = length(FILES);
for i=1:ALL_FILES
    disp([num2str(i) '/' num2str(ALL_FILES) ': ' FILES(i).name])
    im = imread([DIR_JP2 '/' FILES(i).name]);
    imwrite(im,[DIR_BMP '/' FILES(i).name(1:end-3) 'bmp']);
end