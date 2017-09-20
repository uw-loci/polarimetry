function autoExtractSubImages()
%% Function explanation
% autoExtractSubImages.m - autoExtractSubImages is a module for the open-souorce
% software tool CurveAlign.  This function facilitates automatic analysis
% of large stitched images by splitting each image in a folder into a large number of
% sub-images, and then automatically producing ROIs for each of those
% sub-images.

% By Laboratory for Optical and Computational Instrumentation, UW-Madison
% Since 2017
% Developers:
%   Michael Pinkert (module developer, May 2017-)
%   Yuming Liu (primary contact and lead developer, May 2017-)

%% Open the image and define variables
% Get the file and its information
baseDir = uigetdir('','Directory of images to subdivide');
originalDir = cd(baseDir);

fileList = dir(fullfile(baseDir, '*.tif'));

%User input parameters
userInput = inputdlg(...
    {'Enter tiled image width:','Enter tiled image height',...
        'Enter pixel overlap buffer:','Enter ROI width:', 'Enter ROI height:',...
        'Enter grayscale intensity threshold:','Enter minimum number of pixels above threshold:'}, ...
    'Tiled Image Parameters', ...
    [1 50; 1 50; 1 50; 1 50; 1 50; 1 50; 1 50],...
    {'512', '512', '4', '32', '32', '5', '1000'});


Param.subImgWidth = floor(str2double(userInput(1)));
Param.subImgHeight  = floor(str2double(userInput(2)));
Param.ctBuffer  = floor(str2double(userInput(3)));
Param.roiWidth  = floor(str2double(userInput(4)));
Param.roiHeight  = floor(str2double(userInput(5)));
Param.intensityThresh  = floor(str2double(userInput(6)));
Param.pixelNumThresh  = floor(str2double(userInput(7)));


%Param.ctBuffer explanation: 4 is the number of border pixels for curvelet transform.
%This generates an overlap region for the subimages, which allows analysis
%over the full volume.  May not be necessary to change.

%% todo: Find out how to Check for proper input valuees in a simple way. 

%% CSV File for CHTC jobs
 isCHTC = questdlg('Do you want the output to be formatted for cluster analysis?','Center for High Throughput Computing');
 

 if strcmp(isCHTC,'Yes')
    Param.jobSize = floor(str2double(inputdlg('How many pictures per job?','Job size',1,{'1'})));
    if Param.jobSize < 1
        fprintf('Error: Job size is too small')
        return
    end
    
    Param.csvID = fopen('ClusterJobList.csv','w'); 
 end
 
 
 

%% Obtain sub-images and their ROIs

for i = 1:max(size(fileList))
    %Read in the current image
    imgNum = 1;
    img = imread(fileList(i).name);
    Param.baseImgInfo = imfinfo(fileList(i).name);
    [Param.path, Param.fileName_NE] = fileparts(fileList(i).name); %File name without extension
    
    %We cannot have spaces in the file name for CHTC work
    if strcmp(isCHTC,'Yes')
        Param.fileName_NE = Param.fileName_NE(~isspace(Param.fileName_NE));
    end
    
    imgDir = fullfile(baseDir,Param.fileName_NE);
    if (~exist(imgDir,'dir'))
        mkdir(imgDir)
        fprintf('Folder created: %s \n',imgDir)
    end
    cd(imgDir)
    
    %Find out how many sub images there are
    Param.xImgNum = fix((Param.baseImgInfo.Width-2*Param.ctBuffer)/Param.subImgWidth);
    Param.yImgNum = fix((Param.baseImgInfo.Height-2*Param.ctBuffer)/Param.subImgWidth);
    Param.totalImgNum = Param.xImgNum*Param.yImgNum;
    
    %Get the remainder to perform an offset, so as to obtain the center of the
    %image and delete the sides
    Param.xRem = rem(Param.baseImgInfo.Width - 2*Param.ctBuffer,Param.subImgWidth);
    Param.yRem = rem(Param.baseImgInfo.Height- 2*Param.ctBuffer,Param.subImgHeight);
    Param.xOffset = 1+fix(Param.xRem/2);
    Param.yOffset = 1+fix(Param.yRem/2);
    
    %Calculate the number of ROIs and any necessary offset
    Param.xRoiNum = fix(Param.subImgWidth/Param.roiWidth);
    Param.xRoiRem = rem(Param.subImgWidth,Param.roiWidth);
    Param.xRoiOffset = 1 + Param.ctBuffer + fix(Param.xRoiRem/2);
    
    Param.yRoiNum = fix((Param.subImgHeight)/Param.roiHeight);
    Param.yRoiRem = rem((Param.subImgHeight),Param.roiHeight);
    Param.yRoiOffset = 1 + Param.ctBuffer + fix(Param.yRoiRem/2);
    

    if strcmp(isCHTC,'Yes') %Separate images into delineated batches 
        
    
        jobIdx = 0; %To name the tar file
        picIdx = 1; %To 
        
        for y = 1:Param.yImgNum
            for x = 1:Param.xImgNum
                
                xLow = Param.xOffset+Param.subImgWidth*(x-1);
                yLow = Param.yOffset+Param.subImgHeight*(y-1);
                xHigh = xLow + Param.subImgWidth-1+2*Param.ctBuffer;
                yHigh = yLow + Param.subImgHeight-1+2*Param.ctBuffer;
                
                subImg = img(yLow:yHigh,xLow:xHigh);
                
                %Threshold for saving to stop analysis of empty regions
                if sum(sum(subImg>Param.intensityThresh)) > Param.pixelNumThresh %A little more than 1% of pixels for 512x512
                    imgName = sprintf('%s_x%s-y%s',Param.fileName_NE,num2str(x),num2str(y));

                    imwrite(subImg,fullfile(Param.path,strcat(imgName,'.tif')));
                    generateROIs(imgName, Param);
            
                    
                    
                    if picIdx == 1 %Check for a new job                 
                        jobIdx = jobIdx + 1; %
                        tarName = strcat(Param.fileName_NE,'_Job-',num2str(jobIdx),'.tar');      

                        fprintf(Param.csvID, strcat(Param.fileName_NE, ', ', tarName, '\n'));
                        
                    elseif picIdx == Param.jobSize %Check if the job is full
                        picIdx = 0; %Reset the picture idx for the next loop
                                              
                        %Zip the tif files and ROI_Management folder into a single job
                        picList = dir('*.tif');
                        numPics = max(size(picList));
                        
                        tarList = cell(numPics+1 , 1);
                        
                        tarList(1) = cellstr('ROI_management');
                        
                        for j = 1:max(size(picList))
                            tarList(j+1) = cellstr(picList(j).name);
                        end
                        
                        tarName = strcat(Param.fileName_NE,'_Job-',num2str(jobIdx),'.tar');      
                        tar(tarName, tarList)
                        
                        %Remvoe untarred files for next job
                        
                        delete *.tif
                        
                        cd('ROI_management');
                        delete *.mat*
                        
                        cd(imgDir)
                    end
                    
                    picIdx = picIdx + 1;
                end
                imgNum = imgNum+1;
            end
        end
        
        %Write the last tar file, if it as incomplete job
        if picIdx > 1
            cd(imgDir)
            
            %Zip the tif files and ROI_Management folder into a single job
            picList = dir('*.tif');
            numPics = max(size(picList));
            
            tarList = cell(numPics+1 , 1);
            
            tarList(1) = cellstr('ROI_Management');
            
            for j = 1:max(size(picList))
                tarList(j+1) = cellstr(picList(j).name);
            end
            
            tarName = strcat(Param.fileName_NE,'_Job-',num2str(jobIdx),'.tar');
            tar(tarName, tarList)
            
            %Remove untarred files for next job
            
            delete *.tif
            
            cd('ROI_management');
            delete *.mat*
                        
            cd(imgDir)
        end
        
    else %Just write out the images
        for y = 1:Param.yImgNum
            for x = 1:Param.xImgNum
                
                xLow = Param.xOffset+Param.subImgWidth*(x-1);
                yLow = Param.yOffset+Param.subImgHeight*(y-1);
                xHigh = xLow + Param.subImgWidth-1+2*Param.ctBuffer;
                yHigh = yLow + Param.subImgHeight-1+2*Param.ctBuffer;
                
                subImg = img(yLow:yHigh,xLow:xHigh);
                
                %Threshold for saving to stop analysis of empty regions
                if sum(sum(subImg>Param.intensityThresh)) > Param.pixelNumThresh %A little more than 1% of pixels for 512x512
                    imgName = sprintf('%s_x%s-y%s',Param.fileName_NE,num2str(x),num2str(y));

                    imwrite(subImg,fullfile(Param.path,strcat(imgName,'.tif')));
                    generateROIs(imgName, Param);
                end
                imgNum = imgNum+1;
            end
        end
    end
    
    %% Saving
    cd(baseDir);
    
    %Save the parameter file
    paramName = fullfile(imgDir, strcat(Param.fileName_NE, ' Tiling-Parameters'));
    save(paramName,'Param');
    
end

if strcmp(isCHTC,'Yes') %Close the csv file
    fclose(Param.csvID);
end

%Return to the old directory
cd(originalDir);
end


function generateROIs(imgName, Param)
%Generate and save tiled ROIs for a specified image and parameters

tempROI.date = datestr(now,'mm-dd-yyyy');
tempROI.time = datestr(now,13);
tempROI.shape = 1;

roiNum = 1;

for y = 1:Param.yRoiNum
    for x = 1:Param.xRoiNum
        roiName = strcat('ROI', int2str(roiNum));
        
        xLow = Param.xRoiOffset+Param.roiWidth*(x-1);
        yLow = Param.yRoiOffset+Param.roiHeight*(y-1);
        xHigh = xLow + Param.roiWidth-1;
        yHigh = yLow + Param.roiHeight-1;
        
        separate_rois.(roiName) = tempROI;
        separate_rois.(roiName).roi = [yLow,xLow,Param.roiHeight,Param.roiWidth];
        separate_rois.(roiName).enclosing_rect = [yLow, xLow,...
            yHigh,xHigh];
        separate_rois.(roiName).xm = xLow+Param.roiWidth/2;
        separate_rois.(roiName).ym = yLow+Param.roiHeight/2;
        separate_rois.(roiName).boundary = ...
            {[xLow,yLow;...
            xLow,yHigh;...
            xHigh,yHigh;...
            xHigh,yLow;...
            xLow,yLow]};
            
        roiNum = roiNum + 1;
    end
end


roiDir = fullfile(Param.path,'ROI_management');
if (~exist(roiDir,'dir'))
    mkdir(roiDir)
    fprintf('Folder created: %s \n',roiDir)
end

oldFolder = cd(roiDir);
save(strcat(imgName,'_ROIs'),'separate_rois');

cd(oldFolder);

end