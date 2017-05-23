function  separate_rois = generateROIs()
%UNTITLED2 Query the user to select an image file and then generate tiled
%ROIs for that image.

% Get the file
[fileName, pathName] = uigetfile({'*.tif';'*.*'});
oldFolder = cd(pathName);

info = imfinfo(fileName);
cd(oldFolder);

%Calculate the number of tiles and the remainder
xTiles = int32(info.Width/64);
%xOffset = 1 + int8(rem(info.Width,64)/2);
xOffset = 1;

yTiles = int32(info.Height/64);
%yOffset = 1+int8(rem(info.Height,64)/2);
yOffset = 1;

%Track which ROI we are on
roiNum = 1;

tempROI.date = datestr(now,'mm-dd-yyyy');
tempROI.time = datestr(now,13);
tempROI.shape = 1;

roiWidth = 64;
roiHeight = 64;


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
            [xLow,yLow;...
            xLow,yHigh;...
            xHigh,yHigh;...
            xHigh,yLow;...
            xLow,yLow];
            
        roiNum = roiNum + 1;
    end
end

end

