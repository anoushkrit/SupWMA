# Take in the NIFTI file for the brain image, bvel, bvec, and NIFTI file of the brain mask 
# dHCP

path_dwi=/media/ang/Data/dMRI_data/dHCP/sub-CC00542XX15/ses-165800/dwi/
cd ${path_dwi}
patient_id=165800
nifti=sub-CC00542XX15_ses-165800_desc-preproc_dwi.nii.gz
bvec=sub-CC00542XX15_ses-165800_desc-preproc_dwi.bvec
bval=sub-CC00542XX15_ses-165800_desc-preproc_dwi.bval
mask=sub-CC00542XX15_ses-165800_desc-preproc_space-dwi_brainmask.nii.gz
nhdr_data=$path_dwi$patient_id.nhdr
# UKF_path=

convert_path=/home/ang/Documents/GitHub/SupWMA/conversion/conversion
# conda activate SupWMA

python3 $convert_path/nhdr_write.py --nifti $nifti --bval $bval --bvec $bvec --nhdr $nhdr_data
python3 $convert_path/nhdr_write.py --nifti $nifti --nhdr $mask

# Convert all the NIFTI files to NHDR using NIFTI->NHDR write form the conversion pipeline in the UKFTractography 




# Pass the .vtk file in the subject specific parcellation to clusters and the tracts 


# Create the input training data for SupWMA



# Create the label files

