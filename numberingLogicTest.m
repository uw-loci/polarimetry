function [yScale, xScale] = numberingLogicTest(Param)

imgNum = 1;

yScale = zeros(Param.yImgNum*Param.yRoiNum, ...
    Param.xImgNum*Param.xRoiNum);

xScale = zeros(Param.yImgNum*Param.yRoiNum, ...
    Param.xImgNum*Param.xRoiNum);

for y = 1:Param.yImgNum
    
    for x = 1:Param.xImgNum
        roiNum = 1;
        idxY = 1 + (y-1)*Param.yRoiNum;
        for yr = 1:Param.yRoiNum
            idxX = 1 + (x-1)*Param.xRoiNum;
            for xr = 1:Param.xRoiNum
                
                xImgIdx = rem((imgNum-1),Param.xImgNum)*Param.xRoiNum ...
                    + rem((roiNum-1),Param.xRoiNum) + 1;
                
                yImgIdx = floor((imgNum-1)/Param.xImgNum)*Param.yRoiNum ...
                    + ceil(roiNum/Param.xRoiNum);
                
                if ~(xImgIdx == idxX)
                    calculatedX = xImgIdx
                    trueX = idxX
                    calculatedY = yImgIdx
                    trueY = idxY
                    
                    imgNum
                    roiNum
                    
                    return;
                end
                
                yScale(idxY,idxX) = yImgIdx;
                xScale(idxY, idxX) = xImgIdx; 
                
                roiNum = roiNum + 1;
                idxX = idxX+1;
            end
            
            if ~(yImgIdx == idxY)
                calculatedY = yImgIdx
                trueY = idxY
                imgNum
                roiNum
                
                return;
            end
            
            idxY = idxY+1;
        end
        
        imgNum = imgNum + 1;
    end
end


end