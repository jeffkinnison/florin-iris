% Supplementary materials for the paper:
% Learning-Free Iris Segmentation Revisited: A First Step Toward Fast Volumetric Operation Over Video Samples
% Authors: Jeffery Kinnison, Mateusz Trokielewicz, Camila Carballo, Adam Czajka, Walter Scheirer
% Published at The 12th IAPR International Conference on Biometrics (ICB 2019), Crete, Greece
% Pre-print available at https://arxiv.org/abs/1901.01575
% _____________________________________________
% Author: Adam Czajka, May 2019, aczajka@nd.edu

clear all
close all


%% RESCALE TXT

DIR_IN = './interimFiles/HoughFitting/TXT_320x240/';
DIR_OUT = './interimFiles/HoughFitting/TXT_768x574/';

scale = 768/320;

filenames = dir(fullfile(DIR_IN, '*.txt'));

for f = 1:length(filenames)
    
    % disp(filenames(f).name)
    
    c = dlmread([DIR_IN filenames(f).name]);
    NoOfPupilPoints = c(1);
    NoOfIrisPoints = c(2);
    PupilPoints = c(3,1:3*NoOfPupilPoints);
    IrisPoints = c(4,1:3*NoOfIrisPoints);
    
    pupil_x = PupilPoints(1:3:end);
    pupil_y = PupilPoints(2:3:end);
    iris_x = IrisPoints(1:3:end);
    iris_y = IrisPoints(2:3:end);
    theta = 2*pi*(0:0.05:1);
    
    params_TXT = fopen(fullfile(DIR_OUT, filenames(f).name), 'w');
    
    fprintf(params_TXT,'21');
    fprintf(params_TXT,'\n');
    fprintf(params_TXT,'21');
    fprintf(params_TXT,'\n');
    
    for i = 1:NoOfPupilPoints
        fprintf(params_TXT, num2str(round(scale*pupil_x(i))));
        fprintf(params_TXT,' ');
        fprintf(params_TXT, num2str(round(scale*pupil_y(i))));
        fprintf(params_TXT,' ');
        fprintf(params_TXT, num2str(theta(i)));
        fprintf(params_TXT,' ');
    end
    
    fprintf(params_TXT,'\n');
    
    for i = 1:NoOfIrisPoints
        fprintf(params_TXT, num2str(round(scale*iris_x(i))));
        fprintf(params_TXT,' ');
        fprintf(params_TXT, num2str(round(scale*iris_y(i))));
        fprintf(params_TXT,' ');
        fprintf(params_TXT, num2str(theta(i)));
        fprintf(params_TXT,' ');
    end
    
    % close the file on exit
    fclose(params_TXT);
    
end

%% RESCALE MASKs

DIR_IN = './imageData/Warsaw-BioBase-Pupil-Dynamics-v3-segmentation-masks/';
DIR_OUT = './interimFiles/segmentationMasksRescaled/';

filenames = dir(fullfile(DIR_IN, '*.png'));

for f = 1:length(filenames)
    
    % disp(filenames(f).name)
    
    im = imread([DIR_IN filenames(f).name]);
    imS = imresize(im,[574 768],'nearest');
    imwrite(imS,[DIR_OUT filenames(f).name(1:end-4) '_mask.bmp'],'bmp');
    
end



