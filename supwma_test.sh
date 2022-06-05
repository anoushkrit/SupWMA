Slicer=/home/ang/Documents/Slicer-5.0.2/Slicer
BRAINSFitCLI=/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/cli-modules/BRAINSFit

export LD_LIBRARY_PATH=/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/:$LD_LIBRARY_PATH

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/cli-modules/BRAINSFit
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/ang/Documents/Slicer-5.0.2/lib/Slicer-5.0/cli-modules/BRAINSFit
# echo $LD_LIBRARY_PATH

#model config
model_folder=./TrainedModel/
# echo $model_folder

#test_paths
subject_ID=101006
ukf_name=${subject_ID}_ukf_pp_with_region.vtp
subject_ukf=./TestData/${subject_ID}

# echo $subject_ID $ukf_name $subject_ukf

atlas_T2=./TestData/100HCP-population-mean-T2.nii.gz
baseline_b0=./TestData/${subject_ID}/${subject_ID}-dwi_meanb0.nrrd

# echo $atlas_T2 $baseline_b0

#output
subject_folder=./TestData/${subject_ID}

output_folder=./SupWMA_parcellation_results/${subject_ID}
# mkdir $output_folder && mkdir $subject_folder


#transform (from b0 to atlasT2)
subject_transform=./TestData/${subject_ID}_b0_to_atlasT2.tfm

echo $LD_LIBRARY_PATH
sudo $BRAINSFitCLI --fixedVolume $atlas_T2 --movingVolume $baseline_b0 --linearTransform ${subject_transform} --useRigid --useAffine 

## Python Snippet for using BRAINSFitCLI
import nipype
nipype.interfaces.slicer.registration.brainsfit --fixedVolume
# wm_harden_transform.py ${subject_ukf} $output_folder -t ${subject_transform} -j 1 $Slicer
wm_harden_transform.py ${subject_ukf} $output_folder $Slicer -t ${subject_transform} -j 1

# RAS feature extraction
python3 ./extract_tract_feat.py ${subject_folder}/${ukf_name} $output_folder -outPrefix ${subject_ID} -feature RAS -numPoints 15
# SWM parcellation
python3 ./test.py --weight_path ${model_folder} --feat_path $output_folder/${subject_ID}_featMatrix.h5 --out_path $output_folder --label_names ${model_folder}/label_names.h5 --out_prefix ${subject_ID} --tractography_path ${subject_ukf}/${ukf_name}
# Clean temp files
rm -r ${output_folder}/${subject_ID}_featMatrix.h5 ${output_folder}/${ukf_name}