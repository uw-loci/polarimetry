function [downRet, downOrient] = DownsampleRetardanceImage(retImgPath, orientImgPath, scaleFactor)
    
    retImg = imread(retImgPath);
    orientImg = imread(orientImgPath);

    if size(retImg) ~= size(orientImg)
        warning('The retardance and orientation image sizes do not match.Please select inputs from the same image')    
        return
    end

    if rem(scaleFactor,1) ~= 0
        warning('The scale factor needs to be a positive integer, representing the number of pixels that compose the new pixel value')
        return
        %todo: allow non-integer resolution scaling
    end
    
    imgSize = size(retImg);
    
    [xPixelNum, xOffset] = calculateNumberOfTiles(imgSize(1), scaleFactor);
    [yPixelNum, yOffset] = calculateNumberOfTiles(imgSize(2), scaleFactor);
    
    downRet = nan(xPixelNum, yPixelNum);
    downOrient = downRet; 

    for y = 1:yPixelNum
        for x = 1:xPixelNum
            
            [xStart, xEnd] = getTileStartEndIndex(x, scaleFactor, xOffset);
            [yStart, yEnd] = getTileStartEndIndex(y, scaleFactor, yOffset);

            retNeighborhood = retImg(xStart:xEnd,yStart:yEnd);
            orientNeighborhood = orientImg(xStart:xEnd,yStart:yEnd);
            
            [retPixel, orientPixel] = calculateRetardanceOverArea(retNeighborhood,orientNeighborhood);
           
            downRet(x,y) = retPixel;
            downOrient(x,y) = orientPixel;
        end
    end

    

end
