function Params = defineROIs(initParams)
    
    Params = initParams;

    userInput = inputdlg(...
        {'Enter ROI width:', 'Enter ROI height:'}, ...
        'Tiled Image Parameters', ...
        [1 50; 1 50],...
        {'512', '512'});

    Params.roiWidth = floor(str2double(userInput(1)));
    Params.roiHeight = floor(str2double(userInput(2)));

    Params.xRoiNum = fix(initParams.subImgWidth/Params.roiWidth);
    Params.xRoiRem = rem(initParams.subImgWidth,Params.roiWidth);
    Params.xRoiOffset = 1 + initParams.BorderSize + fix(Params.xRoiRem/2);

    Params.yRoiNum = fix((initParams.subImgHeight)/Params.roiHeight);
    Params.yRoiRem = rem((initParams.subImgHeight),Params.roiHeight);
    Params.yRoiOffset = 1 + initParams.BorderSize + fix(Params.yRoiRem/2);

return