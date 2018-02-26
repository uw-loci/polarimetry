function baseName = getBaseFileName(fileName)
    %This function extracts the 'base name' of a file, which is defined as
    %the string up until the first underscore, or until the extension if
    %there is no underscore
    
    [~, nameStr, ~] = fileparts(fileName);
    
    underscoreIndexes = strfind(nameStr,'_');
    
    if underscoreIndexes     
        baseNameIndex = underscoreIndexes(1)-1;
        baseName = nameStr(1:baseNameIndex); 
    else
        baseName = nameStr;
    end
end