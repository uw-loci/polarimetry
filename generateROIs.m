
function generateROIs(Params)
%Generate and save tiled ROIs for a specified image, given ROI width/height/offset parameters

    tempROI.date = datestr(now,'mm-dd-yyyy');
    tempROI.time = datestr(now,13);
    tempROI.shape = 1;

    roiNum = 1;

    for y = 1:Params.yRoiNum
        for x = 1:Params.xRoiNum
            roiName = strcat('ROI', int2str(roiNum));

            xLow = Params.xRoiOffset+Params.roiWidth*(x-1);
            yLow = Params.yRoiOffset+Params.roiHeight*(y-1);
            xHigh = xLow + Params.roiWidth-1;
            yHigh = yLow + Params.roiHeight-1;

            separate_rois.(roiName) = tempROI;
            separate_rois.(roiName).roi = [yLow,xLow,Params.roiHeight,Params.roiWidth];
            separate_rois.(roiName).enclosing_rect = [yLow, xLow,...
                yHigh,xHigh];
            separate_rois.(roiName).xm = xLow+Params.roiWidth/2;
            separate_rois.(roiName).ym = yLow+Params.roiHeight/2;
            separate_rois.(roiName).boundary = ...
                {[xLow,yLow;...
                xLow,yHigh;...
                xHigh,yHigh;...
                xHigh,yLow;...
                xLow,yLow]};

            roiNum = roiNum + 1;
        end
    end
    
    roiDirName = strcat('ROI_management_',num2str(Params.roiWidth),'x',num2str(Params.roiHeight));
    
    roiDir = fullfile(Params.Path,roiDirName);
    if (~exist(roiDir,'dir'))
        mkdir(roiDir)
        fprintf('Folder created: %s \n',roiDir)
    end

    oldFolder = cd(roiDir);
    save(strcat(Params.ImageName,'_ROIs'),'separate_rois');

    cd(oldFolder);

end