function numberingLogicTest(Param)

imgNum = 1;

idxY = 1;
for y = 1:Param.yImgNum
    idxX = 1;
    for x = 1:Param.xImgNum
        roiNum = 1;
        for yr = 1:Param.yRoiNum
            for xr = 1:Param.xRoiNum
                
                xImgIdx = rem((imgNum-1),Param.xImgNum)*Param.xRoiNum ...
                    + rem((roiNum-1),Param.xRoiNum) + 1;
                
                yImgIdx = floor((imgNum-1)/Param.xImgNum)*Param.yRoiNum ...
                    + ceil(roiNum/Param.xRoiNum);
                
                if ~(xImgIdx == idxX && yImgIdx == idxY)
                    xs = [xImgIdx, idxX]
                    ys = [yImgIdx, idxY]
                    return;
                end
                
                roiNum = roiNum + 1;
                idxX = idxX+1;
            end
            idxY = idxY+1;
        end
        
        imgNum = imgNum + 1
    end
end

end