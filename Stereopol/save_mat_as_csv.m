function save_mat_as_csv(file_dir)
    original_dir = cd(file_dir);
    mat_list = ls(strcat('*LR.mat'));
    for i = 1:size(mat_list)
        file_path = mat_list(i, :);
        [~, mat_name, ~] = fileparts(file_path);
        csv_path = strcat(mat_name, '.csv');
        
        if exist(csv_path, 'file') == 2
            continue
        end
        
        load(file_path);
        csvwrite(csv_path, 'LR_final');
    end
    
    cd(original_dir)
end