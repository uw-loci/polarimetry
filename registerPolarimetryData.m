function [registeredMMP, maskPol] = registerPolarimetryData(polscope, MMP)
%Input = base polscope image, base MMP linear retardance image
%Output = registered MMP image, degree polscope image with mask applied to it

%Check the linear retardance ceiling of the polscope scan, which can vary
%and which determines what the image values mean.  This is in the
%metadata .txt files in the SMS directories, if you need to look for it.
retCeil = str2double(inputdlg('Linear retardance ceiling (nm):','Enter the linear retardance ceiling'));
%Polscope data in degrees
degreePol = double(polscope) *1.0* (retCeil/65535) * (4/546)*90;

%Polscope resolution
resMMP = 6; %6 micron resolution.  Change if this is wrong

%I've used two different pixel sizes.  WP4 is 0.337, everything else is
%0.677 so far.  I'll keep a note near the files.
pixelSize = str2double(inputdlg('Polscope pixel size:','Pixel size'));
if (isnan(pixelSize) || (pixelSize <= 0))
    error('Please enter a number for the pixel size')
end

%Resize the polscope image so it is the same size as the MMP.
resizePol = imresize(degreePol,pixelSize/resMMP); 

%Define the registration
metric = registration.metric.MeanSquares; %Mean squares, because the polscope and MMP values are supposed to be equivalent.  Mutual Information is better if they are not supposed to be equivalent.
optimizer = registration.optimizer.OnePlusOneEvolutionary; %This one has worked so far.
optimizer.MaximumIterations = 500; %I increased the number of iterations, but it doesn't seem to make much difference so far.

%Perform the registration
registeredMMP = imregister(MMP, resizePol,'affine',optimizer,metric);

%Define the mask as anywhere there are nonzero values in the MMP image.
mask = registeredMMP > 0;

%Apply the mask
maskPol = mask.*resizePol;


end