function  generateROIs()
%UNTITLED2 Query the user to select an image file and then generate tiled
%ROIs for that image.

[fileName, pathName] = uigetfile({'*.tif';'*.*'});

info = imfinfo(strcat(fileName,pathName));

end

