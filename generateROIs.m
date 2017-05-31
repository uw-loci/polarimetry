function  generateROIs(imgName)
%UNTITLED2 Query the user to select an image file and then generate tiled
%ROIs for that image.

% Get the file info
imgInfo = imfinfo(imgName);

%Define how big the ROIs will be
roiWidth = 64;
roiHeight = 64;
ctBuffer = 4;

%Calculate the number of tiles and the remainder
xTiles = int32((imgInfo.Width-2*ctBuffer)/roiWidth);
xOffset = 1 + ctBuffer;

yTiles = int32((imgInfo.Height-2*ctBuffer)/roiHeight);
yOffset = 1 + ctBuffer;

%Track which ROI we are on
roiNum = 1;

tempROI.date = datestr(now,'mm-dd-yyyy');
tempROI.time = datestr(now,13);
tempROI.shape = 1;


for y = 1:yTiles
    for x = 1:xTiles
        roiName = strcat('ROI', int2str(roiNum));
        
        xLow = xOffset+roiWidth*(x-1);
        yLow = yOffset+roiHeight*(y-1);
        xHigh = xLow + roiWidth-1;
        yHigh = yLow + roiHeight-1;
        
        separate_rois.(roiName) = tempROI;
        separate_rois.(roiName).roi = [yLow,xLow,roiHeight,roiWidth];
        separate_rois.(roiName).enclosing_rect = [yLow, xLow,...
            yHigh,xHigh];
        separate_rois.(roiName).xm = xLow+roiWidth/2;
        separate_rois.(roiName).ym = yLow+roiHeight/2;
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

