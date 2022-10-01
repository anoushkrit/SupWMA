#!/bin/bash
# Config files
Slicer=/home/ang/Documents/Slicer-5.0.2/Slicer
BRAINSFitCLI=/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/cli-modules/BRAINSFit

export LD_LIBRARY_PATH=/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/cli-modules/BRAINSFit
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ang/Documents/programs/ParaView-5.10.1-MPI-Linux-Python3.9-x86_64/lib

ORG_ATLASES=/media/ang/Data/dMRI_data/ORG_Atlases
subject_ID=779370
source_fibers_folder=/media/ang/Data/dMRI_data/105HCP/Fiber_Tracts/
TEST_PATH=${source_fibers_folder}${subject_ID}/vtp_tracts
mkdir $TEST_PATH

## convert the .trk files to .vtk files

# loop over all the .trk files
for filename in ${source_fibers_folder}${subject_ID}/tracts/*.trk; do
    fiber_name=`echo ${filename} | sed 's:.*/::'`
    echo $fiber_name
    echo _______CONVERSION:[.trk to .tck]_________
    # shift terminal directory to the .trk source and execute trk2tck
    (cd ${source_fibers_folder}${subject_ID}/tracts; trampolino convert -t ${filename} trk2tck)

    # cleaning up temporary files
    mv ${source_fibers_folder}${subject_ID}/tracts/trampolino/track.tck ${source_fibers_folder}${subject_ID}/tracts/${subject_ID}.tck
    sudo rm -rf ${source_fibers_folder}${subject_ID}/tracts/meta
    rm -rf ${source_fibers_folder}${subject_ID}/tracts/trampolino

    tckinfo ${source_fibers_folder}${subject_ID}/tracts/${subject_ID}.tck
    echo _________CONVERSION:[.tck to .vtk]_________
    tckconvert ${source_fibers_folder}${subject_ID}/tracts/${subject_ID}.tck ${source_fibers_folder}${subject_ID}/vtp_tracts/${fiber_name}.vtk -force
    echo _______________________________________________________
    echo ${source_fibers_folder}${subject_ID}/vtp_tracts/$fiber_name.vtk
done
