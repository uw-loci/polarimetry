function formatPolscopeData()
%This function takes single image data from Polscope and formats them so
%that they can be stitched using the grid/collection stitching algorith.  This
% involves renaming all the files and making a metadata file that
% references each one.


%Select the base directory that holds all the sub-folders for each stage
%position.  Then get a list of the directories
baseDir = uigetdir(pwd, 'Select the base directory for the SMS images');
originalDir = cd(baseDir);
fileList = dir(baseDir);
dirList = fileList([fileList.isdir]); %This gives a struct containing folder data

numDirs = max(size(dirList))-2; %The -2 is because Matlab dir returns . and ...

%This makes a list for the folder names, so that they can be referenced easily
dirNames = cell(numDirs, 1); 
for i = 1:numDirs
    dirNames(i) = cellstr(dirList(i+2).name);
end


%Get the pixel size in microns
pixelSize = 0.677; %str2double(inputdlg('Pixel Size in um:','Enter the pixel size'));
if (isnan(pixelSize) || (pixelSize <= 0))
    error('Please enter a number for the pixel size')
end

newDir = 'Retardance';
if (~exist(newDir,'dir'))
    mkdir(newDir)
    fprintf('Folder created: %s \n',newDir)
end

newDir = 'Orientation';
if (~exist(newDir,'dir'))
    mkdir(newDir)
    fprintf('Folder created: %s \n',newDir)
end

%Create the new stitching metadata files
retID = fopen('Retardance\TileConfiguration.txt','w');
slowID = fopen('Orientation\TileConfiguration.txt','w');

%Write down the number of dimensions to the stitch. By default, this is 2D,
%but a prompt can be added to make it 3D.
fprintf(retID, 'dim = 2\n');
fprintf(slowID, 'dim = 2\n');

for i = 1:numDirs
    metaName = fullfile(dirNames(i),'Metadata.txt');
    
    %Copy and rename the retardance img
    retImg = fullfile(dirNames(i),'img_000000000_1_Retardance - Computed Image_000.tif');
    retName = strcat(dirNames{i},'-R.tif');
    retPath = strcat('Retardance\', retName);
    copyfile(retImg{1},retPath)
    
    %copy and rename the slow axis img
    slowImg = fullfile(dirNames(i),'img_000000000_2_Slow Axis Orientation - Computed Image_000.tif');
    slowName = strcat(dirNames{i},'-O.tif');
    slowPath = strcat('Orientation\', slowName);
    copyfile(slowImg{1},slowPath)
    
    %Read in the metadata to get the stage position in um
    metaText = strrep(strrep(strrep(fileread(char(metaName)),'"',''),',',''),':',',');
    textInCells = textscan(metaText, '%s');
    
    pos = [0 0];
    
    for j = 1:size(textInCells{1},1)
        if strcmp(textInCells{1}{j}, 'YPositionUm,')
            pos(2) = str2double(textInCells{1}{j+1});
            break
        end
    end
    
    for j = 1:size(textInCells{1},1)
        if strcmp(textInCells{1}{j}, 'XPositionUm,')
            pos(1) = str2double(textInCells{1}{j+1});
            break
        end
    end
    
    %Convert the stage position to pixels, as the stitching algorithm
    %position input is pixels.
    pixelPos = pos/pixelSize;
    
    fprintf(retID, strcat(retName,'; ; (', num2str(pixelPos(1)), ', ',...
        num2str(pixelPos(2)), ')\n'));
    
    fprintf(slowID, strcat(slowName,'; ; (', num2str(pixelPos(1)), ', ',...
        num2str(pixelPos(2)), ')\n'));

end

fclose('all');

cd(originalDir);


end