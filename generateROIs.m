
function generateROIs(Params, Image)
%Generate and save tiled ROIs for a specified image, given ROI width/height/offset parameters
    
    Image = imread(fullfile(Params.Path,Params.FileName);

    tempROI.date = datestr(now,'mm-dd-yyyy');
    tempROI.time = datestr(now,13);
    tempROI.shape = 1;

    roiNum = 1;

    for y = 1:Params.yRoiNum
        for x = 1:Params.xRoiNum
            roiName = strcat('ROI', int2str(roiNum));

            Params.xLow = Params.xRoiOffset+Params.roiWidth*(x-1);
            Params.yLow = Params.yRoiOffset+Params.roiHeight*(y-1);
            Params.xHigh = Params.xLow + Params.roiWidth-1;
            Params.yHigh = Params.yLow + Params.roiHeight-1;
               
            ROI_Image = Image(yLow:yHigh,xLow:xHigh);
            
            %if strcmp(thresholdROI(ROI_Image, pixelNumThres, pixelIntensityThresh), 'Yes')
                separate_rois.(roiName) = createCA_ROI(ROI_Image, Params);
            %end
            
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