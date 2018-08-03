# Reconstruction-Pipeline


StereoCalibration.m:  Performs Calibration on images, returns result as StereoParams

saveParams.m: uses StereoParams in order to find the intrinsic parameters for camL and camR

reconstruct.m: given the name of a directory containing structured light scans and a name of a file to output , decodes the images and saves the reconstructed points as a file.

mesh.m: given the name of an input file and an output file, reads in an input file and creates a mesh from it and performs mesh cleanup. The mesh is then saved as a .ply file.

decode.m: decodes a set of images (called in reconstruct.m)

triangulate.m: given a set of points xL and xR as well as camera parameters camL and camR, triangulates the points into a set of 3D points X

mesh_2_ply.m: saves a mesh as a .ply file.

demo.m: provides a full demonstration of the project: decoding, reconstruction and meshing all performed. Runs everything that can be done in matlab except for the StereoCalibration script (not needed since we save camL and camR).
