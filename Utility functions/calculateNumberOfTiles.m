function [numberOfTiles, offset] = calculateNumberOfTiles(sizeOfImageDimension, sizeOfTileDimension, minimumBorder)

    if ~minimumBorder
        minimumBorder = sizeOfTileDimension;
    end

    numberOfTiles = fix(sizeOfImageDimension/sizeOfTileDimension);
    remainder = rem(sizeOfImageDimension,sizeOfTileDimension);  
    offset = fix(remainder/2);
    
    if (sizeOfTileDimension + offset) < minimumBorder
        offset = minimumBorder - sizeOfTileDimension;
        excessTiles = ceil(2*offset/sizeOfTileDimension) + 1;
        numberOfTiles = numberOfTiles - excessTiles;
        
    end
    
end