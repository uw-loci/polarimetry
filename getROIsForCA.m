function getROIsForCA()

BatchProcessMode = questdlg('Do you want to process a batch (directory) of images?',...
    'Batch mode or single image mode','Yes')

if strcmp(BatchProcessMode,'Yes')
    inputDir = uigetdir('','Directory of images to be processed');
    fileList = dir(fullfile(inputDir,'*.tif'));
    
    for i = 1:size(fileList,1)
        Params = setupParams(fileList(i));
        Params = defineROIs(Params); %todo: Make it ask for ROI params once, instead of each time
        generateROIs(Params)
    end

   
elseif strcmp(BatchProcessMode,'No')
    [fileName, inputDir] = uigetfile({'*.tif';'*.*'},'Image to process');
 
    file.name = fileName;
    file.folder = inputDir;
    
    Params = setupParams(file);
    Params = defineROIs(Params);
    generateROIs(Params)
    
end

