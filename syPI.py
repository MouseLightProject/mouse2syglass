import requests
import json
import code

###############################################################################
###############################################################################
# Creates a project with an empty tiff file in the center of it
# createEmptyProject('projectName', 'C:/syPI/')

def createEmptyProject(name, pathToSYGFolder):
	import tifffile
	import numpy as np
	import os

	cwd = os.getcwd()
	empty = np.zeros((1,1,1))
	tifffile.imsave('empty.tif', np.uint8(empty))
	pathToFile = cwd + '\\empty.tif'

	if '/' in pathToSYGFolder:
		pathToSYGFolder = pathToSYGFolder.replace('/','\\')

	data = {'numChannels': 1, 'name': name, 'convertMax': '255.0', \
'showFrameTemplateString': 0, 'convertMin': '0.0', \
'dataEnum': 'UINT8', 'voxelZ': '1', 'voxelX': '1', \
'voxelY': '1', 'showSliceTemplateString': 0, \
'masterFileList': [[pathToFile]], \
'pathText1': pathToFile, \
'path': pathToSYGFolder, 'extractChannel': 0, 'overwrite': 0, \
'convertType': 'NONE'}
	r = requests.post('http://127.0.0.1:8000/syglass/createProject', json.dumps(data))
	print(r.status_code, r.reason)

	fullPath = pathToSYGFolder + name + '\\' + name + '.syg'

	dataForLibrary = {'body': {'path': fullPath, \
'type': 'NONE', 'modality': 'OTHER', 'voxelSize': '(1, 1, 1)',\
'name': name}, 'name': name}

	r = requests.post('http://127.0.0.1:8000/syglass/VolumeLibrary/putEntry', json.dumps(dataForLibrary))
	print(r.status_code, r.reason)

###############################################################################
###############################################################################
# Create a project with a single tiff stacks
# Example
# createProject('projectName', 'C:/syPI/empty.tif', 'C:/syPI/')

def createProject(name, pathToFile, pathToSYGFolder):
	if '/' in pathToFile:
		pathToFile = pathToFile.replace('/','\\')

	if '/' in pathToSYGFolder:
		pathToSYGFolder = pathToSYGFolder.replace('/','\\')

	data = {'numChannels': 1, 'name': name, 'convertMax': '255.0', \
'showFrameTemplateString': 0, 'convertMin': '0.0', \
'dataEnum': 'UINT8', 'voxelZ': '1', 'voxelX': '1', \
'voxelY': '1', 'showSliceTemplateString': 0, \
'masterFileList': [[pathToFile]], \
'pathText1': pathToFile, \
'path': pathToSYGFolder, 'extractChannel': 0, 'overwrite': 0, \
'convertType': 'NONE'}
	r = requests.post('http://127.0.0.1:8000/syglass/createProject', json.dumps(data))
	print(r.status_code, r.reason)

	fullPath = pathToSYGFolder + name + '\\' + name + '.syg'

	dataForLibrary = {'body': {'path': fullPath, \
'type': 'NONE', 'modality': 'OTHER', 'voxelSize': '(1, 1, 1)',\
'name': name}, 'name': name}

	r = requests.post('http://127.0.0.1:8000/syglass/VolumeLibrary/putEntry', json.dumps(dataForLibrary))
	print(r.status_code, r.reason)

###############################################################################
###############################################################################
# Add a list of OBJ files to the project
# EXAMPLE:
# import glob
# l = glob.glob('C:/syPI/meshes/*.obj')
# l = [i.replace('/','\\') for i in l]
# print(l)
# addMeshesToProject('C:/syPI/projectName/projectName.syg', 'default', l)

def addMeshesToProject(pathToProject, nameOfExperiment, listOfMeshes):
#{'projectPath': 'C:\\syPI\\name4\\name4.syg', 'dir': 'default', 'path': 'C:\\Users\\mmore\\Downloads\\SevenSisters\\VCN_c09_Axon01.obj\r\nC:\\Users\\mmore\\Downloads\\SevenSisters\\VCN_c09_cellbody.obj\r\nC:\\Users\\mmore\\Downloads\\SevenSisters\\VCN_c09_Dendrite01.obj\r\nC:\\Users\\mmore\\Downloads\\SevenSisters\\VCN_c09_myelin01.obj\r\nC:\\Users\\mmore\\Downloads\\SevenSisters\\VCN_c09_nucleus01.obj\r\n'}

	if '/' in pathToProject:
		pathToProject = pathToProject.replace('/','\\')
	data = {'projectPath': pathToProject, 'dir': nameOfExperiment, 'path': '\r\n'.join(listOfMeshes)}
	r = requests.post('http://127.0.0.1:8000/syglass/importMeshOBJs', json.dumps(data))
	print(r.status_code, r.reason)

###############################################################################
###############################################################################
# Add DVID data to a project
# Example:
# addDVIDToProject('emdata.janelia.org:80', '90823d3056a044608ebbb5740b6b46c1', 'grayscalejpeg', 'default', 'C:/syPI/projectName/projectName.syg')
def addDVIDToProject(url, uuid, dvidLabelName, nameOfExperiment, pathToProject):
	if '/' in pathToProject:
		pathToProject = pathToProject.replace('/','\\')
	data = {'url': url, 'uuid': uuid, 'dataType': dvidLabelName, 'dir': nameOfExperiment, 'projectPath': pathToProject}
	r = requests.post('http://127.0.0.1:8000/syglass/setDVIDFields', json.dumps(data))
	print(r.status_code, r.reason)

###############################################################################
###############################################################################
#need to do three things
# 1. read transform data file, convert
# 2. add json file to folder with top level data
# 3. append project path to VolumeLibrary

def buildMouseLightProject(path, name, pathToTransformationFile):
	# read transform data file
	transformData = dict(line.strip().split(':', 1) for line in open(pathToTransformationFile, 'r'))
	level = int(transformData['nl'])
	sx = float(transformData['sx']) / 1000.0 / 2**(level-1)
	sy = float(transformData['sy']) / 1000.0 / 2**(level-1)
	sz = float(transformData['sz']) / 1000.0 / 2**(level-1)
	ox = int(transformData['ox']) / 1000.0
	oy = int(transformData['oy']) / 1000.0
	oz = int(transformData['oz']) / 1000.0

	# add json data to folder with top level data
	data = {'voxelsize_used_um': [sx, sy, sz], 'origin_um': [ox, oy, oz], 'levels': level-1, 'block_filename': "default.tif"}
	with open(path + name + '.json', 'w') as outfile:
		json.dump(data, outfile)

	dataForLibrary = {'body': {'path': path + name + '.json', \
'type': 'dense', 'modality': 'OTHER', 'voxelSize': '',\
'name': name}, 'name': name}

	r = requests.post('http://127.0.0.1:8000/syglass/VolumeLibrary/putEntry', json.dumps(dataForLibrary))
	print(r.status_code, r.reason)


buildMouseLightProject('Y:/SAMPLES/2017-09-25/syglass-ch0/', '2017-09-25_ch0.json', 'Y:/SAMPLES/2017-09-25/transform.txt')
