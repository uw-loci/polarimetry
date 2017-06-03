function extractSubImages()
%% Function explanation
% extractSubImages.m - extractSubImages is a module for the open-souorce
% software tool CurveAlign.  This function facilitates automatic analysis
% of large stitched images by splitting the image into a large number of
% sub-images, and then automatically producing ROIs for each of those
% sub-images.

% By Laboratory for Optical and Computational Instrumentation, UW-Madison
% Since 2017
% Developers:
%   Michael Pinkert (module developer, May 2017-)
%   Yuming Liu (primary contact and lead developer, May 2017-)

%% Open the image and define variables
% Get the file and its information
[fileName, filePath] = uigetfile({'*.tif';'*.*'},'Image to subdivide');
originalDir = cd(filePath);
img = imread(fileName);
Param.baseImgInfo = imfinfo(fileName);
[~, Param.fileName_NE] = fileparts(fileName); %File name without extension

%Define the sub-image directory
folderName = strcat(Param.fileName_NE,' Tiled Images');
subDir = fullfile(filePath, folderName);
if (~exist(subDir,'dir'))
    mkdir(subDir)
    fprintf('Folder created: %s \n',subDir)
else
    fprintf('Folder exists: %s \n',subDir)
end

%Define how big you want the sub files to be
Param.subImgWidth = 512;
Param.subImgHeight = 512;
Param.ctBuffer = 4; %Number of border pixels for curvelet transform.
%This generates an overlap region for the subimages, which allows analysis
%over the full volume

%Find out how many full size images there are
Param.xImgNum = fix((Param.baseImgInfo.Width-2*Param.ctBuffer)/Param.subImgWidth);
Param.yImgNum = fix((Param.baseImgInfo.Height-2*Param.ctBuffer)/Param.subImgWidth);
Param.totalImgNum = Param.xImgNum*Param.yImgNum;

%Define two thresholds to simplify analysis by eliminating empty images.
Param.intensityThresh = 10; %Threshold for pixel intensity
Param.pixelNumThresh = 3000; %How many pixels must be valid to anlayze the image

%Get the remainder to perform an offset, so as to obtain the center of the
%image and delete the sides
Param.xRem = rem(Param.baseImgInfo.Width - 2*Param.ctBuffer,Param.subImgWidth);
Param.yRem = rem(Param.baseImgInfo.Height- 2*Param.ctBuffer,Param.subImgHeight);
Param.xOffset = 1+fix(Param.xRem/2);
Param.yOffset = 1+fix(Param.yRem/2);

%Define how big the ROIs will be
Param.roiWidth = 64;
Param.roiHeight = 64;

%Calculate the number of ROIs and any necessary offset
Param.xRoiNum = fix(Param.subImgWidth/Param.roiWidth);
Param.xRoiRem = rem(Param.subImgWidth,Param.roiWidth);
Param.xRoiOffset = 1 + Param.ctBuffer + fix(Param.xRoiRem/2);

Param.yRoiNum = fix((Param.subImgHeight)/Param.roiHeight);
Param.yRoiRem = rem((Param.subImgHeight),Param.roiHeight);
Param.yRoiOffset = 1 + Param.ctBuffer + fix(Param.yRoiRem/2);

%% Obtain sub-images and their ROIs
imgNum = 1;

for y = 1:Param.yImgNum
    for x = 1:Param.xImgNum
        
        xLow = Param.xOffset+Param.subImgWidth*(x-1);
        yLow = Param.yOffset+Param.subImgHeight*(y-1);
        xHigh = xLow + Param.subImgWidth-1+2*Param.ctBuffer;
        yHigh = yLow + Param.subImgHeight-1+2*Param.ctBuffer;
       
        subImg = img(yLow:yHigh,xLow:xHigh);
        
        %Threshold for saving to stop analysis of empty regions
        if sum(sum(subImg>Param.intensityThresh)) > Param.pixelNumThresh %A little more than 1% of pixels for 512x512
            imgName = fullfile(subDir, sprintf('%s_%s.tif',Param.fileName_NE,num2str(imgNum)));
            imwrite(subImg,imgName);
            generateROIs(imgName, Param);
        end
        imgNum = imgNum+1;
    end
end

%% Saving

%Save the parameter file
paramName = fullfile(subDir,'Tiling Parameters');
save(paramName,'Param');

%Return to the old directory
cd(originalDir);

end


function generateROIs(imgName, Param)
%Generate and save tiled ROIs for a specified image and parameters

tempROI.date = datestr(now,'mm-dd-yyyy');
tempROI.time = datestr(now,13);
tempROI.shape = 1;

roiNum = 1;

for y = 1:Param.yRoiNum
    for x = 1:Param.xRoiNum
        roiName = strcat('ROI', int2str(roiNum));
        
        xLow = Param.xRoiOffset+Param.roiWidth*(x-1);
        yLow = Param.yRoiOffset+Param.roiHeight*(y-1);
        xHigh = xLow + Param.roiWidth-1;
        yHigh = yLow + Param.roiHeight-1;
        
        separate_rois.(roiName) = tempROI;
        separate_rois.(roiName).roi = [yLow,xLow,Param.roiHeight,Param.roiWidth];
        separate_rois.(roiName).enclosing_rect = [yLow, xLow,...
            yHigh,xHigh];
        separate_rois.(roiName).xm = xLow+Param.roiWidth/2;
        separate_rois.(roiName).ym = yLow+Param.roiHeight/2;
        separate_rois.(roiName).boundary = ...
            {[xLow,yLow;...
            xLow,yHigh;...
            xHigh,yHigh;...
            xHigh,yLow;...
            xLow,yLow]};
            
        roiNum = roiNum + 1;
    end
end

[path,name,~] = fileparts(imgName);

roiDir = fullfile(path,'ROI_management');
if (~exist(roiDir,'dir'))
    mkdir(roiDir)
    fprintf('Folder created: %s \n',roiDir)
end

oldFolder = cd(roiDir);
save(strcat(name,'_ROIs'),'separate_rois');

cd(oldFolder);

end