function reconstructSubImages()
%% Function explanation
% reconstructSubImages.m - reconstructSubImages is a module for the
% open-source software tool CurveAlign.  It is meant to be paired with the
% function extractSubImages, after CurveAlign analysis has been run on the
% resulting images.

% This function takes the results from extractSubImages and
% constructs new parametric images, using the ROIs defined in
% extractSubImages as the pixel size.

% By Laboratory for Optical and Computational Instrumentation, UW-Madison
% Since 2017
% Developers:
%   Michael Pinkert (module developer, May 2017-)
%   Yuming Liu (primary contact and lead developer, May 2017-)

%% Image and batch selection
%Query the user to select a file
[fileName, filePath] = uigetfile({'*.tif';'*.*'},'Image to reconstruct');
originalDir = cd(filePath);
[~, fileName_NE] = fileparts(fileName); %File name without extension

%Get and read the tiling parameters
[paramFileName, paramFilePath] = uigetfile({'*.mat';'*.*'},'Tiling parameters');
load(fullfile(paramFilePath,paramFileName));

if ~(Param.xRoiNum)
    disp('The parameter file is not formatted correctly')
    return;
elseif ~(Param.fileName_NE == fileName_NE)
    disp('The tiling parameters do not match the chosen image.')
    disp('Please check the file name parameter.')
    return;
end

%Get and read the batch file
[batchFile, batchFilePath] = uigetfile({'*.xlsx*','*.*'},'CurveAlign batch file');
try [~,~,batchData] = xlsread(fullfile(batchFilePath,batchFile), 'CA ROI alignment analysis');
catch
    disp('Error: Batch data file is does not have the correct page.')
    disp('The data should be on page: CA ROI alignment analysis');
    return;
end

%Instantatiate the new parametric image.  Currently 3 dimensions, for
%orientation (1), alignment (2), and feature number
NewImg = zeros(Param.yImgNum*Param.yRoiNum,Param.xImgNum*Param.xRoiNum,2);


%% Image information extraction

%Check to see if the analyzed images are for the correct base file
if ~(batchData{2,2}(1,1:size(fileName_NE,2)) == fileName_NE)
    disp('Error: This is not the correct batch file for %s', fileName)
    disp('This batch file has images from %S', batchData{2,2})
    return;
end

%Fill in pixels of NewImg where batchData has corresponding non-null values
for row = 2:size(batchData,1)
    if batchData{row,4} == 'NaN'
        continue;
    end
    imgNum = str2double(extractAfter(batchData{row,2},size(fileName_NE,2)+1));
    roiNum = str2double(extractAfter(batchData{row,3},3));
    
    yImgIdx = floor((imgNum-1)/Param.xImgNum)*Param.yRoiNum ...
        + ceil(roiNum/Param.xRoiNum);
    xImgIdx = rem((imgNum-1),Param.xImgNum)*Param.xRoiNum ...
        + rem((roiNum-1),Param.xRoiNum) + 1;
    
    NewImg(yImgIdx,xImgIdx,1) = batchData{row,4};
    NewImg(yImgIdx,xImgIdx,2) = batchData{row,5};
    NewImg(yImgIdx,xImgIdx,3) = batchData{row,6};
    
end

%% Figure formation and saving

resultsDir = fullfile(filePath,strcat(fileName_NE,' Results')); %make a results directory
if ~(exist(resultsDir,'dir')) 
    mkdir(resultsDir);
end

save(fullfile(resultsDir,'Raw Image.mat'),'NewImg'); %Save raw data



cd(originalDir) %Return to the original directory

end