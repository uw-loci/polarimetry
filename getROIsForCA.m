function getROIsForCA()

BatchProcessMode = questdlg('Do you want to process a batch (directory) of images?',...
    'Batch mode or single image mode','Yes');

if strcmp(BatchProcessMode,'Yes')
    BaseParams = defineROIs();
    if any(structfun(@isnan, BaseParams))
       warning('Invalid Parameter inputs.  Please use integers.')
       return
    end

    inputDir = uigetdir('','Directory of images to be processed');
    fileList = dir(fullfile(inputDir,'*.tif'));
    
    for i = 1:size(fileList,1)
        Params = setupParams(fileList(i), BaseParams);
        generateROIs(Params)
    end

   
elseif strcmp(BatchProcessMode,'No')
    BaseParams = defineROIs();
    if any(structfun(@isnan, BaseParams))
       warning('Invalid Parameter inputs.  Please use integers.')
       return
    end
    
    [fileName, inputDir] = uigetfile({'*.tif';'*.*'},'Image to process');
 
    file.name = fileName;
    file.folder = inputDir;
    
    Params = setupParams(file, BaseParams);
    generateROIs(Params)
    
end

