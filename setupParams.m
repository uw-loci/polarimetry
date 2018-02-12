function Params = setupParams(file)
    %Initial parameters, assuming just ROIs and no sub-divided images
    
    [~, name, ~] = fileparts(file.name);
    fileInfo = imfinfo(fullfile(file.folder,file.name));
   
    
    Params.FileInfo = fileInfo;
    Params.Path = file.folder;
    Params.ImageName = name;
    
    Params.xImgNum = 1;
    Params.yImgNum = 1;
    Params.BorderSize = 0;
    
    Params.subImgWidth = fileInfo.Width;
    Params.subImgHeight = fileInfo.Height;
    
end