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
NewImg = nan(Param.yImgNum*Param.yRoiNum,Param.xImgNum*Param.xRoiNum,2);


%% Image information extraction

%Check to see if the analyzed images are for the correct base file
if ~(batchData{2,2}(1,1:size(fileName_NE,2)) == fileName_NE)
    disp('Error: This is not the correct batch file for %s', fileName)
    disp('This batch file has images from %S', batchData{2,2})
    return;
end

%Fill in pixels of NewImg where batchData has corresponding non-null values
for row = 2:size(batchData,1)
    if strcmp(batchData{row,4},'NaN')
        continue;
    end
    
    imgStr = batchData{row,2};
    roiStr = batchData{row,3};
    
    imgNum = str2double(imgStr((size(fileName_NE,2)+2):size(imgStr,2)));
    roiNum = str2double(roiStr(4:size(roiStr,2)));
    
    yImgIdx = floor((imgNum-1)/Param.xImgNum)*Param.yRoiNum ...
        + ceil(roiNum/Param.xRoiNum);
    xImgIdx = rem((imgNum-1),Param.xImgNum)*Param.xRoiNum ...
        + rem((roiNum-1),Param.xRoiNum) + 1;
    
    NewImg(yImgIdx,xImgIdx,1) = batchData{row,4};
    NewImg(yImgIdx,xImgIdx,2) = batchData{row,5};
    NewImg(yImgIdx,xImgIdx,3) = batchData{row,6};
    
end

%% Figure formation and saving

analysisType = strcat(batchData{2,7},'_',num2str(Param.roiWidth),'x',num2str(Param.roiHeight));
resultName = inputdlg('Base File Name:','Results Naming',[1 50],{strcat(fileName_NE,'_',analysisType,'_Results')});


resultsDir = fullfile(paramFilePath,strcat(fileName_NE,' Results')); %make a results directory
if ~(exist(resultsDir,'dir')) 
    mkdir(resultsDir);
end

% todo : write code to check for prior results and stop overwriting if so
save(fullfile(resultsDir,strcat(resultName{1},'.mat')),'NewImg','batchData'); %Save raw data
cd(resultsDir)

figNum = 1;
while(ishandle(figNum))
    figNum = figNum + 1;
end

figure(figNum)
imagesc(NewImg(:,:,1))
colormap('jet')
title('Orientation')
axis off
saveas(figure(figNum),fullfile(resultsDir,strcat(resultName{1},' Orientation.tif')))

figure(figNum+1)
imagesc(NewImg(:,:,2))
colormap('jet')
title('Alignment')
axis off
saveas(figure(figNum+1),fullfile(resultsDir,strcat(resultName{1},' Alignment.tif')))

cd(originalDir) %Return to the original directory

end