
function generateROIs(imgName, Param)
%Generate and save tiled ROIs for a specified image, given ROI width/height/offset parameters

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