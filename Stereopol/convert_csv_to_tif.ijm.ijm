close("*")

file_dir = "F:\\Box Sync\\Research\\Polarimetry\\Data 01 - Raw and imageJ proccessed images\\New Mueller Data\\";
save_dir = "F:\\Box Sync\\Research\\Polarimetry\\Data 02 - Python prepped images\\SterLR_Large\\";

file_list = get_filetype_from_dir(file_dir, "csv");
Array.print(file_list)

convert_images(file_list, file_dir, save_dir);

function convert_images(file_list, file_dir, save_dir){
	for (i = 0; i < file_list.length; i++){
		file_parts = split(file_list[i], '_');
		sample_name = file_parts[0];
	
		csv_path = file_dir + file_list[i];
		tif_path = save_dir + sample_name + "_SterLR_Large.tif";

		if (File.exists(tif_path) == 0) {
			run("Text Image... ", "open=[" + csv_path + "]");
			run("Rotate 90 Degrees Left");
			run("Save", "save=[" + tif_path + "]");
		}

		close();
	}
}


function get_filetype_from_dir(dir, ext){
	all_file_list = getFileList(dir);

	filetype_list = newArray();

	for (i = 0; i < all_file_list.length; i++){
		split_str = split(all_file_list[i], ".");
		if (split_str.length > 1){
			if (split_str[1] == ext){
				filetype_list = append(filetype_list, all_file_list[i]);
			}
		}
	}
	
	return filetype_list;
}

function append(arr, value) {
     arr2 = newArray(arr.length+1);
     for (i=0; i<arr.length; i++)
        arr2[i] = arr[i];
     arr2[arr.length] = value;
     return arr2;
}