
file_dir = "F:\\Box Sync\\Research\\Polarimetry\\Stitched Images - Co-register\\";
sample = "WP9";
file_ext = ".czi";
flat_field = file_dir + "Flat field.tif";
path = file_dir + sample + file_ext;

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

//Save unmodified images
for (i=0; i<nImages; i++) { 
        selectImage(i+1); 
        titles[i] = getTitle;
        
        stack_name = split(titles[i],"( - )");
		output_name = unmodified_dir + stack_name[1] + '.ome.tif';
		run("Bio-Formats Exporter", "save=[" + output_name + "] export compression=Uncompressed");
}

num_to_process = nImages;

//Divide by flat field and save modified images
open(flat_field);
flat_field_title = getTitle;

for (i = 0; i < num_to_process; i++){
	imageCalculator("Divide create 32-bit stack", titles[i], flat_field_title);
	
	stack_name = split(titles[i],"( - )");
	output_name = output_dir + stack_name[1] + '.ome.tif';
	run("Bio-Formats Exporter", "save=[" + output_name + "] export compression=Uncompressed");
	close(getTitle);
}




//ic = new ImageCalculator();
//corrected_image = ic.run("Divide create 32-bit stack", imp1, imp2);
//imp = IJ.openImage("F:\\Box Sync\\Research\\Polarimetry\\Stitched Images - Co-register\\Flat field.tif");


