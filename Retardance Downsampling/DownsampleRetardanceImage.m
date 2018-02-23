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

    for y = 0:(yPixelNum-1)
        for x = 0:(xPixelNum-1)
            
            xStart = (x*scaleFactor)+xOffset;
            xEnd = ((x+1)*scaleFactor)+xOffset;
            
            yStart = (y*scaleFactor)+yOffset;
            yEnd = ((y+1)*scaleFactor)+yOffset;
            
            retNeighborhood = retImg(xStart:xEnd,yStart:yEnd);
            orientNeighborhood = orientImg(xStart:xEnd,yStart:yEnd);
            
            [tempRetPixel, tempOrientPixel] = calculateRetardanceOverArea(retNeighborhood,orientNeighborhood);
           
            downRet(x+1,y+1) = tempRetPixel;
            downOrient(x+1,y+1) = tempOrientPixel;
        end
    end

    

end
