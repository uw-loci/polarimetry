
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

for (i=0; i<nImages; i++) { 
        selectImage(i+1); 
        temp_title = split(getTitle, "( - )"); 

		output_name = unmodified_dir + temp_title[1] + '.ome.tif';
		run("Bio-Formats Exporter", "save=[" + output_name + "] export compression=Uncompressed");
        
        titles[i] = temp_title[1];
        ids[i]=getImageID; 
}

//num_to_process = nImages;

//flat_image = open(flat_field)

//for (i = 0; i < num_to_process, i++){
	//corrected_image = imageCalculator("Divide create 32-bit stack", selectImage(ids[i]), flat_image);
	//output_name = output_dir + temp_title[1] + '.ome.tif';
	//run("Bio-Formats Exporter", "save=[" + output_name + "] export compression=Uncompressed");
//}




//ic = new ImageCalculator();
//corrected_image = ic.run("Divide create 32-bit stack", imp1, imp2);
//imp = IJ.openImage("F:\\Box Sync\\Research\\Polarimetry\\Stitched Images - Co-register\\Flat field.tif");


