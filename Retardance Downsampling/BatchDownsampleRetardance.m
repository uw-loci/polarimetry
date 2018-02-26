function BatchDownsampleRetardance(scaleFactor, retDir, orientDir, outputDir, simulatedResolutionFactor)
    
    if ~exist('scaleFactor','var')
        warning('Please enter in a scaling factor to work with')
        return
    elseif ~exist('retDir','var')
        retDir = uigetdir('','Retardance image directory');
        orientDir = uigetdir('','Slow-axis orientation directory');
        outputDir = uigetdir('','Output directory');
    elseif ~exist('orientDir','var')
        orientDir = uigetdir('','Slow-axis orientation directory');
        outputDir = uigetdir('','Output directory');
    elseif ~exist('outputDir','var')
        outputDir = uigetdir('','Output directory');
    elseif ~exist('simulatedResolutionFactor','var')
        simulatedResolutionFactor = scaleFactor;
    end
    
    
    outputSuffix = strcat('_Downsampled-by-', num2str(scaleFactor), 'x');
    
    if simulatedResolutionFactor ~= scaleFactor
        outputSuffix = strcat(outputSuffix, '_Simulated-Resolution-', num2str(simulatedResolutionFactor), 'x');
    end
    
    
    [retImgList, orientImgList] = findSharedImages(retDir, orientDir);
    
    for i = 1:size(orientImgList,2)
        
        [downsampledRetImg, downsampledOrientImg] = ...
            DownsampleRetardanceImage(retImgList(i).basePath, orientImgList(i).basePath, scaleFactor, simulatedResolutionFactor);
        
        saveTextImageWithSuffix(downsampledRetImg, retImgList(i).basePath, outputSuffix, outputDir);
        saveTextImageWithSuffix(downsampledOrientImg, orientImgList(i).basePath, outputSuffix, outputDir);
    end

end