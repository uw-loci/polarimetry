function extractSubImages()
%% Open the image and define variables
% Get the file and its information
[fileName, filePath] = uigetfile({'*.tif';'*.*'});
oldFolder = cd(filePath);
img = imread(fileName);
imgInfo = imfinfo(fileName);
[~, fileName_NE] = fileparts(fileName) %File name without extension

%Define the sub-image directory
folderName = strcat(fileName_NE,' Sub Images');
subDir = fullfile(filePath, folderName);
if (~exist(subDir,'dir'))
    mkdir(subDir)
    fprintf('Folder created: %s \n',subDir)
else
    fprintf('Folder exists: %s \n',subDir)
end

%Define how big you want the sub files to be
imgWidth = 512;
imgHeight = 512;

%Find out how many full size images there are
xImgNum = fix(imgInfo.Width/imgWidth);
yImgNum = fix(imgInfo.Height/imgWidth);

%Get the remainder to perform an offset, so as to obtain the center of the
%image and delete the sides
xRem = rem(imgInfo.Width,imgWidth);
yRem = rem(imgInfo.Height,imgHeight);
xOffset = 1+fix(xRem/2);
yOffset = 1+fix(yRem/2);

%% Divide and save the sub images
imgNum = 1;

for y = 1:yImgNum
    for x = 1:xImgNum
        imgName = fullfile(subDir, sprintf('%s_%s.tif',fileName_NE,imgNum));
        
        xLow = xOffset+imgWidth*(x-1);
        yLow = yOffset+imgHeight*(y-1);
        xHigh = xLow + imgWidth-1;
        yHigh = yLow + imgHeight-1;
       
        subImg = img(xLow:xHigh,yLow:yHigh);
        
        %Threshold for saving to stop analysis of empty regions
        pixelNum = s(subImg>10);
        if pixelNum > 3000 %A little more than 1% of pixels
            
        
        end
        
        imgNum = imgNum+1;
    end
end

%Crop 

%% Generate ROIS
% Query whether or not to generate and save the ROIs



%% Finish
cd(oldFolder);
end