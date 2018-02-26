function [startIndex, endIndex] = getTileStartEndIndex(tileNumber, tileStepSize, tileOffset,tileSize)
%Calculate the starting and ending index along a single dimension for a
%tile

    if ~exist('tileSize','var')
        tileSize = tileStepSize;
    end

    startIndex = ((tileNumber-1)*tileStepSize)+tileOffset;
    endIndex = startIndex + tileSize;
    
end