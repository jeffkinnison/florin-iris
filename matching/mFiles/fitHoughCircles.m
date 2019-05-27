% Supplementary materials for the paper:
% Learning-Free Iris Segmentation Revisited: A First Step Toward Fast Volumetric Operation Over Video Samples
% Authors: Jeffery Kinnison, Mateusz Trokielewicz, Camila Carballo, Adam Czajka, Walter Scheirer
% Published at The 12th IAPR International Conference on Biometrics (ICB 2019), Crete, Greece
% Pre-print available at https://arxiv.org/abs/1901.01575
% __________________________________________________________________________
% Author: Mateusz Trokielewicz, December 2018, m.trokielewicz@elka.pw.edu.pl
% Edits: Adam Czajka, May 2019, aczajka@nd.edu

clear all
close all

% switch off warnings about "too large radius ranges" -- we need large radius ranges
warning off all

DIR_MASKS = './imageData/Warsaw-BioBase-Pupil-Dynamics-v3-segmentation-masks/';
DIR_OUT_APPROX_JPG = './interimFiles/HoughFitting/JPG/';
DIR_OUT_APPROX_TXT = './interimFiles/HoughFitting/TXT_320x240/';

% Estimates of iris and pupil radii for 320x240 resolution
MIN_IRIS_R = 40;
MAX_IRIS_R = 90;
MIN_PUPIL_R = 12;

FILES = dir([DIR_MASKS '*.png']);
ALL_FILES = length(FILES);
disp(['Found ' num2str(ALL_FILES) ' masks -- processing ...']);

for i = 1:ALL_FILES
    
    disp([num2str(i) '/' num2str(ALL_FILES) ': ' FILES(i).name])
    
    HOUGH_VIS_FILE = [FILES(i).name(1:end-4) '_HoughVis.jpg'];
    OSIRIS_OUT_FILE = [FILES(i).name(1:end-4) '_para.txt'];
    
    MASK = logical(imread([DIR_MASKS FILES(i).name]));
    
    if ~isempty(MASK)
        
        % create the iris radius search range for Hough transform
        SEARCH_RANGE_I = [MIN_IRIS_R MAX_IRIS_R];
        
        % estimate the outer iris circle with Hough transform
        [IRIS_CENTERS, IRIS_RADII, ~] = imfindcircles(MASK, SEARCH_RANGE_I, 'ObjectPolarity', 'bright', 'Sensitivity', 0.98);
        
        % safeguard: if no circles found do the second iteration with increased sensitivity
        if isempty(IRIS_CENTERS)
            
            % estimate the outer iris circle with Hough
            [IRIS_CENTERS, IRIS_RADII, ~] = imfindcircles(MASK, SEARCH_RANGE_I, 'ObjectPolarity', 'bright', 'Sensitivity', 0.99);
            
        end
        
        if ~isempty(IRIS_CENTERS)
            
            irisXY = IRIS_CENTERS(1,:);
            irisX = irisXY(1);
            irisY = irisXY(2);
            irisR = IRIS_RADII(1);
            
            % set the found iris radius as max possible pupil radius minus some
            MAX_PUPIL_R = round(0.9*irisR);
            
            % do the usual search routine
            SEARCH_RANGE_P = [MIN_PUPIL_R MAX_PUPIL_R];
            
            % estimate the inner iris circle with Hough
            [PUPIL_CENTERS, PUPIL_RADII, ~] = imfindcircles(MASK, SEARCH_RANGE_P, 'ObjectPolarity', 'dark', 'Sensitivity', 0.99);
            
            if (~isempty(PUPIL_CENTERS))
                pupilXY = PUPIL_CENTERS(1, :);
                pupilX = pupilXY(1);
                pupilY = pupilXY(2);
                pupilR = PUPIL_RADII(1);
            else
                % pupil estimation failed, using irisR/3
                pupilR = round(irisR/3);
                pupilX = irisX;
                pupilY = irisY;
            end
            
            % generate points around the pupil and iris circles
            % and save them as "_para.txt" files (OSIRIS compatible)
            % N is 21
            theta = 2*pi*(0:0.05:1);
            pupil_x = round(pupilX + pupilR.*cos(theta));
            pupil_y = round(pupilY + pupilR.*sin(theta));
            
            theta = 2*pi*(0:0.05:1);
            iris_x = round(irisX + irisR.*cos(theta));
            iris_y = round(irisY + irisR.*sin(theta));
            
            % open a TXT file for OSIRIS Hough parameters
            params_TXT = fopen([DIR_OUT_APPROX_TXT OSIRIS_OUT_FILE], 'w');
            
            fprintf(params_TXT,'21');
            fprintf(params_TXT,'\n');
            fprintf(params_TXT,'21');
            fprintf(params_TXT,'\n');
            
            for i = 1:length(theta)
                fprintf(params_TXT, num2str(pupil_x(i)));
                fprintf(params_TXT,' ');
                fprintf(params_TXT, num2str(pupil_y(i)));
                fprintf(params_TXT,' ');
                fprintf(params_TXT, num2str(theta(i)));
                fprintf(params_TXT,' ');
            end
            
            fprintf(params_TXT,'\n');
            
            for i = 1:length(theta)
                fprintf(params_TXT, num2str(iris_x(i)));
                fprintf(params_TXT,' ');
                fprintf(params_TXT, num2str(iris_y(i)));
                fprintf(params_TXT,' ');
                fprintf(params_TXT, num2str(theta(i)));
                fprintf(params_TXT,' ');
            end
            
            % close the file on exit
            fclose(params_TXT);
            
            % create and save image and mask with localized circles drawn
            % (comment the following lines if you do not need this
            % visualization)
            MASK = uint8(MASK) * 255;
            IMAGE = insertShape(MASK, 'Circle', [pupilX pupilY pupilR], 'LineWidth', 3, 'Color', 'red');
            IMAGE = insertShape(IMAGE, 'Circle', [irisX irisY irisR], 'LineWidth', 3, 'Color', 'blue');
            imwrite(IMAGE, [DIR_OUT_APPROX_JPG HOUGH_VIS_FILE]);
            
        end
        
    end
    
end