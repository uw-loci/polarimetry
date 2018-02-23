function [startIndex, endIndex] = getTileStartEndIndex(tileNumber, tileSize, tileOffset)
%Calculate the starting and ending index along a single dimension for a
%tile

    startIndex = ((tileNumber-1)*tileSize)+tileOffset;
    endIndex = (tileNumber*tileSize)+tileOffset;

end