# Config files
Slicer=/home/ang/Documents/Slicer-5.0.2/Slicer
BRAINSFitCLI=/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/cli-modules/BRAINSFit

export LD_LIBRARY_PATH=/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/cli-modules/BRAINSFit
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ang/Documents/programs/ParaView-5.10.1-MPI-Linux-Python3.9-x86_64/lib

ORG_ATLASES=/media/ang/Data/dMRI_data/ORG_Atlases

## Model Config 
### where the trained model needs to saved 
model_folder=./NewTrainedModel
source_fibers_folder=/media/ang/Data/dMRI_data/105HCP/Fiber_Tracts/
# subject_ID=784565 # based on the folder name in the source fibers folder
subject_ID=779370
TEST_PATH=${source_fibers_folder}${subject_ID}/800FC
mkdir $TEST_PATH
# Input files from 105 HCP dataset
## performs trk-tck-vtk for cases where the .trk file is an input
## merge the trk files 

python3 /home/ang/Documents/GitHub/SupWMA/merge_trk.py --path_with_trks  ${source_fibers_folder}${subject_ID}

## convert the .trk files to .vtk files
echo _______CONVERSION:[.trk to .tck]_________
(cd ${source_fibers_folder}${subject_ID}; trampolino convert -t ${source_fibers_folder}${subject_ID}/${subject_ID}.trk trk2tck)

mv ${source_fibers_folder}${subject_ID}/trampolino/track.tck ${source_fibers_folder}${subject_ID}/${subject_ID}.tck
sudo rm -rf ${source_fibers_folder}${subject_ID}/meta
rm -rf ${source_fibers_folder}${subject_ID}/trampolino

tckinfo ${source_fibers_folder}${subject_ID}/${subject_ID}.tck
echo _________CONVERSION:[.tck to .vtk]_________
tckconvert ${source_fibers_folder}${subject_ID}/${subject_ID}.tck ${source_fibers_folder}${subject_ID}/${subject_ID}.vtk -force

## .vtk files to labels via ATLAS
wm_apply_ORG_atlas_to_subject.sh -i ${source_fibers_folder}${subject_ID}/${subject_ID}.vtk -o ${TEST_PATH} -a ${ORG_ATLASES} -s ${Slicer}


    #  -i:  Input tractography data stored in VTK (.vtk or .vtp). Note: fiber streamlines need to be in the RAS coordinates.
    #  -o:  Output directory to save all fiber clustering outputs.
    #  -a:  Path to the ORG atlas (the anatomically curated atlas ORG-800FC-100HCP), within which there should be 
    #       two folders named: ORG-RegAtlas-100HCP and ORG-800FC-100HCP 
    #  -s:  Path to 3D Slicer, e.g., under MacOS, it is /Applications/Slicer.app/Contents/MacOS/Slicer







