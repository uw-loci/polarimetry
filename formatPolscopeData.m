function formatPolscopeData()
%This function takes single image data from Polscope and formats it so
% an be stitched using the grid/collection stitching algorith.  This
% involves renaming all the files and making a metadata file that
% references each one.


%Select the base directory that holds all the sub-folders for each stage
%position.  Then get a list of the directories
baseDir = uigetdir(pwd, 'Select the base directory for the SMS images');
fileList = dir(baseDir);
dirList = fileList([fileList.isfolder]); %This gives a struct containing folder data

numDirs = max(size(dirList))-2; %Matlab dir returns . and ...

%This makes a list for the folder names, so that they can be referenced easily
dirNames = cell(numDirs, 1); 
for i = 1:numDirs
    dirNames(i) = cellstr(dirList(i+2).name);
end


%Get the pixel size in microns
pixelSize = str2double(inputdlg('Pixel Size in um:','Enter the pixel size'));
if (isnan(pixelSize) || (pixelSize <= 0))
    error('Please enter a number for the pixel size')
    return
end

%Create the new stitching metadata file
stitchID = fopen('StitchingMetadata.txt','w');

for i = 1:numDirs
    metaName = fullfile(dirNames(i),'Metadata.txt');
    retImg = fullfile(dirNames(i),'img_000000000_1_Retardance - Computed Image_000.tif');
    slowImg = fullfile(dirNames(i),'img_000000000_2_Slow Axis Orientation - Computed Image_000.tif');
    
    metaText = strrep(fileread(char(metaName)),'"','');
    
end

fclose('stitchID')




end