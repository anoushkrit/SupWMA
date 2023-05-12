Slicer=/home/ang/Documents/Slicer-5.0.2/Slicer
BRAINSFitCLI=/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/cli-modules/BRAINSFit

export LD_LIBRARY_PATH=/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/:$LD_LIBRARY_PATH

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/cl i-modules/BRAINSFit
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/cli-modules/BRAINSFit
# echo $LD_LIBRARY_PATH

#model config
model_folder=./TrainedModel/
# echo $model_folder
source_fibers_folder=/media/ang/Data/dMRI_data/105HCP/Fiber_Tracts/
# echo $source_fibers_folder
subject_ID=784565

echo ${subject_ID}
   
# performs trk-tck-vtk-vtp
# cd ${source_fibers_folder}${subject_ID}

## INPUT other DATA
# giving input a .trk file from HCP dataset and then converting to .vtk to feed into the trained model
echo _______CONVERSION:[.trk to .tck]_________
(cd ${source_fibers_folder}${subject_ID}; trampolino convert -t ${source_fibers_folder}${subject_ID}/${subject_ID}.trk trk2tck)
sleep 5
mv ${source_fibers_folder}${subject_ID}/trampolino/track.tck ${source_fibers_folder}${subject_ID}/${subject_ID}.tck
sudo rm -rf ${source_fibers_folder}${subject_ID}/meta
rm -rf ${source_fibers_folder}${subject_ID}/trampolino

tckinfo ${source_fibers_folder}${subject_ID}/${subject_ID}.tck
echo _________CONVERSION:[.tck to .vtk]_________
tckconvert ${source_fibers_folder}${subject_ID}/${subject_ID}.tck ${source_fibers_folder}${subject_ID}/${subject_ID}.vtk -force
# echo _________CONVERSION:[.vtk to .vtp]_________
# python3 ./conversions/vtk2vtp.py ${source_fibers_folder}${subject_ID}/${subject_ID}.vtk


## TRACTOGRAHY PATH
# subject_ID=101006
# ukf_name=${subject_ID}_ukf_pp_with_region.vtp
ukf_name=${source_fibers_folder}${subject_ID}/${subject_ID}.vtk
subject_ukf=./TestData/${subject_ID}

## ATLAS
# Only 100 HCP Atlas Available
atlas_T2=./TestData/100HCP-population-mean-T2.nii.gz
# baseline_b0, passing baseline-b0 for 101006
baseline_b0=./TestData/101006/101006-dwi_meanb0.nrrd
# passing baseline as same as the previous test data available

echo $atlas_T2 $baseline_b0

## OUTPUT
subject_folder=./TestData/${subject_ID}
output_folder=./SupWMA_parcellation_results/${subject_ID}
mkdir $output_folder && mkdir $subject_folder

#transform (from b0 to atlasT2)
subject_transform=./TestData/${subject_ID}_b0_to_atlasT2.tfm

echo $LD_LIBRARY_PATH
sudo $BRAINSFitCLI --fixedVolume $atlas_T2 --movingVolume $baseline_b0 --linearTransform ${subject_transform} --useRigid --useAffine 

## Python Snippet for using BRAINSFitCLI
# import nipype
# nipype.interfaces.slicer.registration.brainsfit --fixedVolume
# wm_harden_transform.py ${subject_ukf} $output_folder -t ${subject_transform} -j 1 $Slicer
wm_harden_transform.py ${subject_ukf} $output_folder $Slicer -t ${subject_transform} -j 1

# RAS feature extraction (DeepWMA FiberMap (Fiber Descriptor))
python3 ./extract_tract_feat.py ${ukf_name} $output_folder -outPrefix ${subject_ID} -feature RAS -numPoints 15
# SWM parcellation
python3 ./test.py --weight_path ${model_folder} --feat_path $output_folder/${subject_ID}_featMatrix.h5 --out_path $output_folder --label_names ${model_folder}/label_names.h5 --out_prefix ${subject_ID} --tractography_path ${ukf_name}
# Clean temp files
# rm -r ${output_folder}/${subject_ID}_featMatrix.h5 ${output_folder}
