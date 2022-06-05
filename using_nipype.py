import nipype

# bash commands
# $BRAINSFitCLI --fixedVolume $atlas_T2 --movingVolume $baseline_b0 --linearTransform ${subject_transform} --useRigid --useAffine
# wm_harden_transform.py ${subject_ukf} $output_folder -t ${subject_transform} -j 1 Slicer $Slicer

nipype.interfaces.slicer.registration.brainsfit 