function BatchDownsampleRetardance(scaleFactor, retDir, orientDir, outputDir)
    
    if ~scaleFactor
        warning('Please enter in a scaling factor to work with')
        return
    elseif ~retDir
        retDir = uigetdir('','Retardance image directory');
        orientDir = uigetdir('','Slow-axis orientation directory');
        outputDir = uigetdir('','Output directory');
    elseif ~orientDir
        orientDir = uigetdir('','Slow-axis orientation directory');
        outputDir = uigetdir('','Output directory');
    elseif ~outputDir
        outputDir = uigetdir('','Output directory');
    end
    
    
    outputSuffix = strcat('_Downsampled-by-', num2str(scaleFactor), 'x');
    
    [retImgList, orientImgList] = findSharedImages(retDir, orientDir);
    
    for i = 1:size(orientImgList,2)
        
        [downsampledRetImg, downsampledOrientImg] = ...
            DownsampleRetardanceImage(retImgList(i).basePath, orientImgList(i).basePath, scaleFactor);
        
        saveTextImageWithSuffix(downsampledRetImg, retImgList(i).basePath, outputSuffix, outputDir);
        saveTextImageWithSuffix(downsampledOrientImg, orientImgList(i).basePath, outputSuffix, outputDir);
    end

end