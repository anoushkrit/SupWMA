import nipype.interfaces.diffusion_toolkit as dtk
import os, sys
trk_merge = dtk.TrackMerge()

path_with_trk_files = "/media/ang/Data/dMRI_data/599671/tracts"

path_list = list()
sys.path.append(path_with_trk_files)

for i in os.listdir(path_with_trk_files):
    path_list.append(os.path.join(path_with_trk_files, i))

trk_merge.inputs.track_files = path_list
trk_merge.run()