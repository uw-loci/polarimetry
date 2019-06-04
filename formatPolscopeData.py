# @File(label='Select the base directory for the SMS images', style="directory") baseDir 
# @Float(label='Pixel size in um') pixelSize

import os
from shutil import copyfile
import json

directories = [name for name in os.listdir(str(baseDir)) if os.path.isdir(os.path.join(str(baseDir), name))]
numDirs = len(directories)

retDir = os.path.join(str(baseDir), 'Retardance')
if not os.path.exists(retDir):
	os.mkdir(retDir)
	print("Directory " + retDir + " created")
else:    
    print("Directory " + retDir  + " already exists")
    
orientDir = os.path.join(str(baseDir), 'Orientation')
if not os.path.exists(orientDir):
	os.mkdir(orientDir)
	print("Directory " + orientDir + " created")
else:    
    print("Directory " + orientDir + " already exists")

    
# Create the new stitching metadata files
retID = open(os.path.join(retDir, 'TileConfiguration.txt'),'w')
slowID = open(os.path.join(orientDir, 'TileConfiguration.txt'),'w')

# Write down the number of dimensions to the stitch. By default, this is 2D,
# but a prompt can be added to make it 3D.
retID.write('dim = 2\n')
slowID.write('dim = 2\n')

for i in range(numDirs):
	metaName = os.path.join(str(baseDir), directories[i], 'Metadata.txt')
	if not os.path.isfile(metaName):
		continue
	
	meta = open(metaName, 'r')
	
	# Copy and rename the retardance img
	retImg = os.path.join(str(baseDir), directories[i],'img_000000000_1_Retardance - Computed Image_000.tif')
		
	print(retImg)
	retName = directories[i] + '-R.tif'
	retPath = os.path.join(retDir, retName)
	copyfile(retImg, retPath)
	
	# copy and rename the slow axis img
	slowImg = os.path.join(str(baseDir), directories[i],'img_000000000_2_Slow Axis Orientation - Computed Image_000.tif')
	slowName = directories[i] + '-O.tif'
	slowPath = os.path.join(orientDir, slowName)
	copyfile(slowImg, slowPath)
	
	# Read in the metadata to get the stage position in um
	metaText = meta.read()
	metaDict = json.loads(metaText)
	
	ypos = float(metaDict['FrameKey-0-2-0']['YPositionUm'])/pixelSize
	xpos = float(metaDict['FrameKey-0-2-0']['XPositionUm'])/pixelSize
	
	pos = [xpos, ypos]
	
	retID.write(retName + '; ; (' + str(pos[0]) + ', ' + str(pos[1]) + ')\n')
	slowID.write(slowName + '; ; (' + str(pos[0]) + ', ' + str(pos[1]) + ')\n')
	#Convert the stage position to pixels, as the stitching algorithm
	# position input is pixels.
	
	meta.close()


retID.close()
slowID.close()