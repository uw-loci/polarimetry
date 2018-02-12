function getROIsForCA()

BatchProcessMode = questdlg('Do you want to process a batch (directory) of images?',...
    'Batch mode or single image mode','Yes')

Params = defineROIs();

if strcmp(BatchProcessMode,'Yes')
    inputDir = uigetdir('','Directory of images to be processed');
    fileList = dir(fullfile(inputDir,'*.tif'));
    
    for i = 1:size(fileList,1)
        Params = setupParams(fileList(i), Params);
        generateROIs(Params)
    end

   
elseif strcmp(BatchProcessMode,'No')
    [fileName, inputDir] = uigetfile({'*.tif';'*.*'},'Image to process');
 
    file.name = fileName;
    file.folder = inputDir;
    
    Params = setupParams(file);
    generateROIs(Params)
    
end

