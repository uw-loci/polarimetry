//Divide by flat field and save modified images
num_to_process = nImages;

open(flat_field);
flat_field_title = getTitle;

for (i = 0; i < num_to_process; i++){
	imageCalculator("Divide create 32-bit stack", titles[i], flat_field_title);
	
	stack_name = split(titles[i],"( - )");
	output_name = output_dir + stack_name[1] + '.ome.tif';
	run("Bio-Formats Exporter", "save=[" + output_name + "] export compression=Uncompressed");
	close(getTitle);
}