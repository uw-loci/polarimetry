function saveTextImageWithSuffix(img, originalImgPath, suffix, outputDir)

        [~, originalImgName, ~] = fileparts(originalImgPath);
        outputImgName = strcat(originalImgName, suffix, '.csv'); 
        outputPath = fullfile(outputDir, outputImgName);
        
        csvwrite(outputPath,img);
end
