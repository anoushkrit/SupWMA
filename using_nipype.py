from email.mime import base
import nipype
from nipype.interfaces import slicer

# bash commands

# wm_harden_transform.py ${subject_ukf} $output_folder -t ${subject_transform} -j 1 Slicer $Slicer

# nipype.interfaces.slicer.registration.brainsfit 

subject_id = 101006
atlas_t2 = "./TestData/100HCP-population-mean-T2.nii.gz"
baseline_b0 = "./TestData/{0}/{1}-dwi_meanb0.nrrd".format(subject_id, subject_id)
subject_transform = "./TestData/{}_b0_to_atlasT2.tfm".format(subject_id)
# subject_transform = "/home/ang/Documents/GitHub/SupWMA/TestData/{}_b0_to_atlasT2.tfm".format(subject_id)

print(subject_id, subject_transform, baseline_b0)

brains_input = slicer.registration.brainsfit.BRAINSFitInputSpec()

brains_input.fixedVolume = atlas_t2
brains_input.movingVolume = baseline_b0
brains_input.useRigid = True
brains_input.useAffine = True



# brains_input.save_inputs_to_json(json_file="./TestData/{}_inputs.json".format(subject_id)

brains_output = slicer.registration.brainsfit.BRAINSFitOutputSpec()
brains_output.linearTransform = subject_transform

# brains = slicer.registration.BRAINSFit()

# brainsfit = slicer.registration.brainsfit.BRAINSFit(inputs=brains_input, )
# brainsfit.aggregate_outputs()
# brainsfit.save_inputs_to_json(json_file="./TestData/{}_inputs.json".format(subject_id))

# print("At BRAINSFit execution")
# brains_object.BRAINSFit

# slicer.registration.brainsfit.BRAINSFitInputSpec(fixedVolumne = atlas_t2, movingVolume = baseline_b0, useRigid = True, useAffine= True)
# slicer.registration.brainsfit.BRAINSFitOutputSpec(linearTransform = subject_transform)