import nibabel as nib
trk_tract = nib.streamlines.load(fileobj="/home/ang/Documents/GitHub/SupWMA/merged_tracks.trk")
print(trk_tract)
nib.streamlines.save(tractogram=trk_tract, filename="/home/ang/Documents/GitHub/SupWMA/merged_tracks.tck")