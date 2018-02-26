function [dirOneImagePaths, dirTwoImagePaths] = findSharedImages(dirOne, dirTwo)
    %Base image names derived from directory one, are mapped to images from
    %directory two.
    
    %todo: modify dirOne_baseFileNames into a list of names, and then
    %implement a .txt file?
    
    %todo: make a check for different categories of name, if there are multiple instances of a single name?
    
    originalDir = cd(dirOne);
    fileListOne = dir('*.tif');
   
    cd(dirTwo)
    fileListTwo = dir('*.tif');
    
    numberOfPairedImages = 0;
    

    for i = 1:size(fileListOne)
        
        baseNameOne = getBaseFileName(fileListOne(i).name);
        
        for j = 1:size(fileListTwo)
            
            baseNameTwo = getBaseFileName(fileListTwo(j).name);
          
            if strcmp(baseNameOne, baseNameTwo)
                numberOfPairedImages = numberOfPairedImages + 1;
                                
                tempCellOne.basePath = fullfile(fileListOne(i).folder, fileListOne(i).name);
                dirOneImagePaths(numberOfPairedImages) = tempCellOne;
                
                tempCellTwo.basePath = fullfile(fileListTwo(j).folder, fileListTwo(j).name);
                dirTwoImagePaths(numberOfPairedImages) = tempCellTwo;
            end
            
        end
        
    end
    
    cd(originalDir);
    
end