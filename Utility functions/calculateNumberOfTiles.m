function [numberOfTiles, offset] = calculateNumberOfTiles(sizeOfImageDimension, sizeOfTileDimension)
    
    numberOfTiles = fix(sizeOfImageDimension/sizeOfTileDimension);
    remainder = rem(sizeOfImageDimension,sizeOfTileDimension);  
    offset = fix(remainder/2);
    
end
