file_dir = "F:\\Box Sync\\Research\\Polarimetry\\Stitched Images - Co-register\\";
flat_field_dir = file_dir + "Flat-field images\\";
//Find all unmodified images in each sub directory
//For each timepoint
//Open the timepoints for all sub images
//combine the images
//run basic
//save basic


close("*")

all_file_list = getFileList(file_dir);

czi_list = get_czi_files_from_list(all_file_list);

unmodified_file_list = find_unmodified_images(czi_list, file_dir);

calculate_flat_field_images(unmodified_file_list, flat_field_dir);

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
  
function calculate_flat_field_images(file_list, flat_field_dir){
	for (timepoint = 0; timepoint < 24; timepoint++){
		open_timepoints(file_list, timepoint);
		perform_basic(timepoint, flat_field_dir);
	}
}

function open_timepoints(file_list, timepoint){
	options_str =" autoscale color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT ";
	timepoint_str = "t_begin=" + timepoint + " t_end=" + timepoint + " t_step=" + timepoint;
	
	for (i = 0; i < file_list.length; i++)
	{
		run("Bio-Formats Importer", "open=[" + file_list[i] + "]" + options_str + timepoint_str  );
	}
}

function perform_basic(timepoint, flat_field_dir){
	run("Images to Stack", "name=Stack title=[] use");
	
	shading_str = "shading_estimation=[Estimate shading profiles] shading_model=[Estimate flat-field only (ignore dark-field)] ";
	regularization_str = "setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50";
	run("BaSiC ", "processing_stack=Stack flat-field=None dark-field=None " + shading_str + regularization_str);

	selectWindow("Flat-field:Stack");
	flat_field_path = flat_field_dir + "flat_field_polarization-" + timepoint + ".tif";
	save(flat_field_path);

	close("*");
}


