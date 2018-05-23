function create_stitching_document(unmodified_dir, modified_dir)
   
    original_dir = cd(unmodified_dir);
    tif_list = dir('*.tif');
    
    num_tifs = size(tif_list, 1);
    
    output_name = fullfile(modified_dir, 'TileConfiguration.txt');
    config_file = fopen(output_name,'w');
    
    fprintf(config_file, 'dim = 2\n');
    
    for i = 1:num_tifs
        image = bfopen(tif_list(i).name);
        omeMeta = image{1,4};
        
        pixel_size_x = omeMeta.getPixelsPhysicalSizeX(0).value;
        pixel_size_y = omeMeta.getPixelsPhysicalSizeY(0).value;
        pixel_size = double([pixel_size_x, pixel_size_y]);
        
        pos_x = omeMeta.getPlanePositionX(0, 0).value;
        pos_y = omeMeta.getPlanePositionY(0, 0).value;
        pos = double([pos_x, pos_y]);
        
        pixel_pos = pos/pixel_size;
        
        line_str = strcat(tif_list(i).name, '; ; (', ...
            num2str(pixel_pos(1)), ', ',...
            num2str(pixel_pos(2)), ')\n');
        
        fprintf(config_file, line_str);
        
    end
    
    fclose(config_file);
    
    cd(original_dir)
end
