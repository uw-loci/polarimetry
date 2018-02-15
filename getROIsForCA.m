function getROIsForCA()

BatchProcessMode = questdlg('Do you want to process a batch (directory) of images?',...
    'Batch mode or single image mode','Yes')

BaseParams = defineROIs();

if strcmp(BatchProcessMode,'Yes')
    %Params = defineROIs();
    
    inputDir = uigetdir('','Directory of images to be processed');
    fileList = dir(fullfile(inputDir,'*.tif'));
    
    for i = 1:size(fileList,1)
        Params = setupParams(fileList(i), BaseParams);
        generateROIs(Params)
    end

   
elseif strcmp(BatchProcessMode,'No')
    %Params = defineROIs();
    
    [fileName, inputDir] = uigetfile({'*.tif';'*.*'},'Image to process');
 
    file.name = fileName;
    file.folder = inputDir;
    
    Params = setupParams(file, BaseParams);
    generateROIs(Params)
    
end

