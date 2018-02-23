function BatchDownsampleRetardance(scaleFactor)

    retDir = uigetdir('','Retardance image directory');
    orientDir = uigetdir('','Slow-axis orientation directory');
    outDir = uigetdir('','Output directory');
    % match ret to orient
    
    outputSuffix = strcat('Downsampled-by-', num2str(scaleFactor), 'x.tif');

    
    [retImgList orientImgList] = findSharedImages(retDir, orientDir);
    
    for i = 1:size(orientImgList(1))
        [downsampledRetImg downsampledOrientImg] = DownsampleRetardanceImage(retImgList(i), orientImgList(i));
        
        saveTextImageWithSuffix(downsampledRetImg, retImgList(i), outputSuffix, outputDir);
        saveTextImageWithSuffix(downsampledOrientImg, orientImgList(i), outputSuffix, outputDir);
    end

end