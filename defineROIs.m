function ROIParams = defineROIs(initParams)
    
    ROIParams = initParams;

    userInput = inputdlg(...
        {'Enter ROI width:', 'Enter ROI height:'}, ...
        'Tiled Image Parameters', ...
        [1 50; 1 50],...
        {'512', '512'});

    ROIParams.roiWidth = floor(str2double(userInput(1)));
    ROIParams.roiHeight = floor(str2double(userInput(2)));

    ROIParams.xRoiNum = fix(initParams.subImgWidth/ROIParams.roiWidth);
    ROIParams.xRoiRem = rem(initParams.subImgWidth,ROIParams.roiWidth);
    ROIParams.xRoiOffset = 1 + initParams.ctBuffer + fix(ROIParams.xRoiRem/2);

    ROIParams.yRoiNum = fix((initParams.subImgHeight)/ROIParams.roiHeight);
    ROIParams.yRoiRem = rem((initParams.subImgHeight),ROIParams.roiHeight);
    ROIParams.yRoiOffset = 1 + initParams.ctBuffer + fix(ROIParams.yRoiRem/2);

return