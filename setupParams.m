function Params = setupParams(file, Params)
    %Initial parameters, assuming just ROIs and no sub-divided images
    
    [~, name, ~] = fileparts(file.name);
    fileInfo = imfinfo(fullfile(file.folder,file.name));

    Params.FileInfo = fileInfo;
    Params.Path = file.folder;
    Params.ImageName = name;
    Params.FileName = file.name;
    
    Params.xImgNum = 1;
    Params.yImgNum = 1;
    Params.BorderSize = 0;
    
    Params.subImgWidth = fileInfo.Width;
    Params.subImgHeight = fileInfo.Height;

    Params.xRoiNum = fix(Params.subImgWidth/Params.roiWidth);
    Params.xRoiRem = rem(Params.subImgWidth,Params.roiWidth);
    Params.xRoiOffset = 1 + Params.BorderSize + fix(Params.xRoiRem/2);

    Params.yRoiNum = fix((Params.subImgHeight)/Params.roiHeight);
    Params.yRoiRem = rem((Params.subImgHeight),Params.roiHeight);
    Params.yRoiOffset = 1 + Params.BorderSize + fix(Params.yRoiRem/2);
    
end