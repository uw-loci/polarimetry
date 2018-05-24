//Divide by flat field and save modified images
close("*");

file_dir = "F:\\Box Sync\\Research\\Polarimetry\\Stitched Images - Co-register\\";
flat_field_dir = file_dir + "Flat-field images\\";



all_file_list = getFileList(file_dir);
czi_list = get_czi_files_from_list(all_file_list);
unmodified_file_list = find_unmodified_images(czi_list, file_dir);

for (i = 0; i < unmodified_file_list.length; i++){
	correct_flat_field(unmodified_file_list[i], flat_field_dir);
}

function correct_flat_field(image, flat_field_dir){
	sampledir = split(image, "(unmodified)");
	position = File.getName(image);
	
	for (timepoint = 0; timepoint < 24; timepoint++){
		correct_timepoint(image, timepoint);
	}

	run("Images to Stack", "name=" + position + " title=[] use");

	output_name = sampledir[0] + position;
	run("16-bit");
	run("Properties...", "channels=1 slices=1 frames=24 unit=micron pixel_width=2.016 pixel_height=2.016 voxel_depth=1.0000000");
	run("Bio-Formats Exporter", "save=[" + output_name + "] export compression=Uncompressed");

	close("*");
}

function correct_timepoint(image, timepoint){
	options_str =" autoscale color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT ";
	timepoint_str = "t_begin=" + timepoint + " t_end=" + timepoint + " t_step=" + timepoint;
	run("Bio-Formats Importer", "open=[" + image + "]" + options_str + timepoint_str  );

	image_title = getTitle;
	sample_ext = split(image_title, "(.ome)");
		
	flat_field_str = flat_field_dir + "flat_field_polarization-" + timepoint + ".tif";
	open(flat_field_str);
	flat_field_title = getTitle;

	imageCalculator("Divide create 32-bit stack", image_title, flat_field_title);
	timepoint_name = sample_ext[0] + " P-" + timepoint; 
	rename(timepoint_name);
		
	close(image_title);
	close(flat_field_title);

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


function find_unmodified_images(czi_list, base_dir){
	unmod_list = newArray();
	
	for (i = 0; i < czi_list.length; i++){
		split_str = split(czi_list[i], ".");
		sample = split_str[0];
		unmod_dir = base_dir + sample + "\\unmodified position images\\";

		sample_img_list = getFileList(unmod_dir);

		for (j = 0; j < sample_img_list.length; j++){
			unmod_list = append(unmod_list, unmod_dir + sample_img_list[j]);
		}
	}

	return unmod_list;
}


function append(arr, value) {
     arr2 = newArray(arr.length+1);
     for (i=0; i<arr.length; i++)
        arr2[i] = arr[i];
     arr2[arr.length] = value;
     return arr2;
}