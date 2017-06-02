function reconstructSubImages()
%% Function explanation
% reconstructSubImages.m - reconstructSubImages is a module for the
% open-source software tool CurveAlign.  It is meant to be paired with the
% function extractSubImages, after CurveAlign analysis has been run on the
% resulting images.

% This function takes the results from extractSubImages and
% constructs new parametric images, using the ROIs defined in
% extractSubImages as the pixel size.

% By Laboratory for Optical and Computational Instrumentation, UW-Madison
% Since 2017
% Developers:
%   Michael Pinkert (module developer, May 2017-)
%   Yuming Liu (primary contact and lead developer, May 2017-)

%% Image and batch selection
%Query the user to select a file
[fileName, filePath] = uigetfile({'*.tif';'*.*'},'Image to reconstruct');
originalDir = cd(filePath);

%Find the corresponding parameter file and subFolder
[~, fileName_NE] = fileparts(fileName);
subFolderName = fullfile(filePath, strcat(fileName_NE, ' Tiled Images'));
paramFileName = fullfile(filePath,subFolderName,'Tiling Parameters.m');

try Param = load(paramFileName,'Param');
catch %todo: Allow for moved parameter files 
    disp('Error: Could not find the parameter file for %s', ...
        fileName)
    disp('Please check that the file TilingParameters.m is in %s', ...
        subFolderName)
    return;
end

%Get and read the batch file
[batchFile, batchFilePath] = uigetfile({'*.xlsx*','*.*'},'CurveAlign batch file');
try [~,~,batchData] = xlsread(fullfile(batchFilePath,batchFile), 'CA ROI alignment analysis');
catch
    disp('Error: Batch data file is not formatted correctly')
    return;
end

%Instantatiate the new parametric image.  Currently 2 dimensions, for
%orientation (1) and alignment (2)
NewImg = zeros(Param.yImgNum*Param.yRoiNum,Param.xImgNum*Param.xRoiNum,2);

%Check to see if the analyzed images are for the correct base file
if ~(NewImg{2,2}(1:size(fileName,2)) == fileName)
    disp('Error: This is not the correct batch file for %s', fileName)
    disp('This batch file has images from %S', NewImg{2,2})
end

%Replace corresponding values in NewImg
for line = 2:size(batchData,1)
    imgNum = str2double(extractAfter(NewImg{line,2},size(fileName,2)+1));
    roiNum = str2double(extractAfter(NewImg{line,3},3));
    
    yImgIdx = fix(imgNum/Param.xImgNum)*Param.yRoiNum ... 
        +fix(roiNum/Param.yroiNum) + 1;
    xImgIdx = imgNum-Param.yImgNum*fix(imgNum/Param.yImgNum);
    
end

cd(originalDir) %Return to the original directory

end