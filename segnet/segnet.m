function []=segnet(DIR_IN, DIR_OUT, CSV_NAME)
    %% SegNetIris example
    %
    % This sample code demostrates how to obtain a binary mask prediction using
    % the DCNN-based approach employing SegNet in MATLAB 2017b
    %
    % Prerequisites: MATLAB 2017b or later with Neural Network Toolbox
   
    load('SegNetWarm-noUBIRIS.mat')

    % DIR_IN = './';
    % DIR_OUT = './';
    
    files = dir(fullfile(DIR_IN, '*.bmp'));

    timing = zeros(size(files));
    for i=1:length(files)
        
        tic; 

        image = imread([DIR_IN files(i).name]);
        % if the image is already 320x240, the following lines are not needed
        % [sY sX] = size(image);
        % imageSegNetIn = imresize(image,[240 320],'bicubic');

        prediction_categorical = semanticseg(image, net);

        background = zeros(size(prediction_categorical));
        overlay = labeloverlay(background, prediction_categorical);
        overlay = logical(~overlay(:, :, 2));    
        imwrite(overlay,fullfile([DIR_OUT files(i).name(1:end-4) '_Segnet.png']));
                                                        
        timing(i) = toc;

    end
    display(sum(timing))
    csvwrite(CSV_NAME, timing);
    clear;
end
