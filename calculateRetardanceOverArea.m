function [retMag,retAngle] = calculateRetardanceOverArea(retardance, orientation)
    
    % This gives me the orientation in 360 degrees, doubled to calculate alignment.
    circularOrientation = (2*pi/180)*(double(orientation)/100);
    complexOrientation = exp(1i*circularOrientation);
    
    retardanceWeightedByOrientation = retardance.*complexOrientation;
    
    numPixels = numel(retardance);
    
    averageRetardance = sum(sum(retardanceWeightedByOrientation))/numPixels;
    
    retMag = abs(averageRetardance);
    retAngle = angle(averageRetardance)/2; 

end