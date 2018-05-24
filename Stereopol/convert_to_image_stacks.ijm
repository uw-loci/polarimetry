
file_dir = "F:\\Box Sync\\Research\\Polarimetry\\Stitched Images - Co-register\\";


all_file_list = getFileList(file_dir);
czi_list = get_czi_files_from_list(all_file_list);

for (i = 0; i < czi_list.length; i++){
	save_unmodified_images(file_dir, czi_list[i]);
}


function get_czi_files_from_list(list){
	czi_list = newArray();
	
	for (i = 0; i < list.length; i++){
		split_str = split(list[i], ".");
		if (split_str.length > 1){
			if (split_str[1] == "czi"){
				czi_list = append(czi_list, list[i]);
			}
		}
	}
	
	return czi_list;
}


function save_unmodified_images(file_dir, sample_file){
	sample_split = split(sample_file, ".");
	sample = sample_split[0];
	path = file_dir + sample_file;
	
	output_dir = file_dir + sample + "\\";
	if (File.exists(output_dir) == 0) {
		File.makeDirectory(output_dir);
	}
	
	unmodified_dir = output_dir + "unmodified position images\\";
	if (File.exists(unmodified_dir) == 0) {
		File.makeDirectory(unmodified_dir);
	}
	
	run("Bio-Formats Importer", "open=[" + path + "] color_mode=Default open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	ids = newArray(nImages); 
	titles = newArray(nImages);
	
	for (i=0; i<nImages; i++) { 
	        selectImage(i+1); 
	        titles[i] = getTitle;
	        
	        stack_name = split(titles[i],"( - )");
			output_name = unmodified_dir + stack_name[1] + '.ome.tif';
			run("Bio-Formats Exporter", "save=[" + output_name + "] export compression=Uncompressed");
	}
}
