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

NewImg = nan(Param.yImgNum*Param.yRoiNum,Param.xImgNum*Param.xRoiNum,3);

%todo: REformat to read individual .csv stats instead of batch stats.
imagesDir = uigetdir('Folder with sub images');
statsDir = fullfile(imagesDir,'CA_ROI','Batch','ROI_post_analysis');

cd(statsDir);
statsList = ls(strcat(fileName_NE,'**stats.csv'));


%Check to see if the analyzed images are for the correct base file
if size(statsList,1) == 0
    disp('Error: No results found %s', fileName)
    return;
end


%Get a list of the .csv files
%open each
%read from each
% 
% %Get and read the batch file
% [batchFile, batchFilePath] = uigetfile({'*.xlsx*','*.*'},'CurveAlign batch file');
% try [~,~,batchData] = xlsread(fullfile(batchFilePath,batchFile), 'CA ROI alignment analysis');
% catch
%     disp('Error: Batch data file does not have the correct page.')
%     disp('The data should be on page: CA ROI alignment analysis');
%     return;
% end

%Instantatiate the new parametric image.  Currently 3 dimensions, for
%orientation (1), alignment (2), and feature number


%% Image information extraction

%Fill in pixels of NewImg where batchData has corresponding non-null values
for i = 1:size(statsList,1)
    
    %Extract the x an y image number 
    xLocs = strfind(statsList(i,:),'x');
    xStrIdx = xLocs(size(xLocs,2));
    
    yLocs = strfind(statsList(i,:),'y');
    yStrIdx = yLocs(size(yLocs,2));
    
    %Find where the ROI str starts, and the y string ends
    roiStrIdx = strfind(statsList(i,:),'_ROI');
    
    %Find where the ROI str ends
    statsIdx = strfind(statsList(i,:),'_stats');
    
    %Extract the tile number 
    xImageNum = str2double(statsList(i,(xStrIdx+1):(yStrIdx-2)));
    yImageNum = str2double(statsList(i,(yStrIdx+1):(roiStrIdx-1)));
    
    roiNum = str2double(statsList(i,(roiStrIdx+4):(statsIdx-1)));
    
    %Find the corresponding pixel
    yImgIdx = (yImageNum-1)*Param.yRoiNum + ceil(roiNum/Param.xRoiNum);
    xImgIdx = (xImageNum-1)*Param.xRoiNum + rem((roiNum-1),Param.xRoiNum) + 1;
    
%     yImgIdx = floor((imgNum-1)/Param.xImgNum)*Param.yRoiNum ...
%         + ceil(roiNum/Param.xRoiNum);
%     xImgIdx = rem((imgNum-1),Param.xImgNum)*Param.xRoiNum ...
%         + rem((roiNum-1),Param.xRoiNum) + 1;
    
    %Read in the stats file

    [~, col2, ~, col4] = textread(statsList(i,:), '%s %s %s %s');
    
    NewImg(yImgIdx,xImgIdx,1) = str2double(col2(1)); %Mean = 1
    NewImg(yImgIdx,xImgIdx,2) = str2double(col4(5)); % Alignement = 5
    
end

%% Figure formation and saving

analysisType = strcat('FibSegments_',num2str(Param.roiWidth),'x',num2str(Param.roiHeight));
resultName = inputdlg('Base File Name:','Results Naming',[1 50],{strcat(fileName_NE,'_',analysisType,'_Results')});


resultsDir = fullfile(filePath,strcat(fileName_NE,' Results')); %make a results directory
if ~(exist(resultsDir,'dir')) 
    mkdir(resultsDir);
end

% todo : write code to check for prior results and stop overwriting if so
save(fullfile(resultsDir,strcat(resultName{1},'.mat')),'NewImg'); %Save raw data
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