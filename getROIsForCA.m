function getROIsForCA()

BatchProcessMode = questdlg('Do you want to process a batch (directory) of images?',...
    'Batch mode or single image mode','No')

if strcmp(BatchProcessMode,'Yes')
    inputDir = uigetdir('','Directory of images to be processed');
    fileName = dir(fullfile(inputDir,'*.tif'));
elseif strcmp(BatchProcessMode,'No')
    [fileName, inputDir] = uigetfile({'*.tif';'*.*'},'Image to process');
end


for i = 1:1:size(fileName,1)
    
    defineROIs
    generateROIs
end