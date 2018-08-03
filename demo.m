%demonstration script

%NOTE: this script assumes the existence of camL and camR (these are loaded
%in reconstruct.m. Without camL and camR reconstruct will fail.

%using modified reconstruct script, turns reconstruct into a function that
%can be passed a directory and an output filename. This will create 6
%reconstruct files to be used in the next step.
base_input_string = 'teapot/grab_%d/';
base_output_string = 'reconstruction%d.mat';
numfiles= 6;

for c= 0:numfiles
    input_file =(sprintf(base_input_string,c)); %when c = 0 this produces 'teapot/grab_0/'
    output_file =(sprintf(base_output_string,c)); %when c=0 this produces 'reconstruction0.mat'
    reconstruct(input_file,output_file);
end

%use modified reconstruction script that is passed a set of reconstructed
%points and a .ply file to generate
base_input_string = 'reconstruction%d.mat';
base_output_string = 'mesh%d.ply';
numfiles= 6;
for c= 0:numfiles
    input_file =(sprintf(base_input_string,c)); %when c = 0 this produces 'reconstruction0.mat'
    output_file =(sprintf(base_output_string,c)); %when c=0 this produces 'mesh0.ply'
    mesh(input_file,output_file);
end

%at this point we export each mesh as a .ply file into meshlab in order to
%be alligned and saved as finalmesh.ply, poisson reconstruction also done
%during this step.

%read finalmesh in and display it. 
%NOTE: this assumes that finalmesh.ply exists in the folder, so be sure to
%grab it from my Data file before trying to run the demo
clf;
ptCloud = pcread('finalmesh.ply');
pcshow(ptCloud);

%NOTE: ptCloud does not seem to
%accurately represent the mesh, in my final report I show how the final
%mesh appears in matlab.
