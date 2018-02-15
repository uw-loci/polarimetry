function use = thresholdROI(ROI, pixelNumThresh, pixelIntensityThresh)
        if sum(sum(ROI>pixelIntensityThresh)) > pixelNumThresh
            use = 1;
        else
            use = 0;
        end
end