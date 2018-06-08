close("*")

file_dir = "F:\\Box Sync\\Research\\Polarimetry\\Data 02 - Python prepped images\\SHG_Large\\";
file_list = get_filetype_from_dir(file_dir, 'tif');

convert_images(file_list, file_dir);

function convert_images(file_list, file_dir){
	for (i = 0; i < file_list.length; i++){
		open(file_list[i]);
		run("8-bit");
		run("Save");
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