import nipype.interfaces.diffusion_toolkit as dtk
import argparse
import os, sys

def merge_trks(path_with_trk_files):
    trk_merge = dtk.TrackMerge()

    path_with_trk_files = "/media/ang/Data/dMRI_data/599671/tracts"

    path_list = list()
    sys.path.append(path_with_trk_files)

    for i in os.listdir(path_with_trk_files):
        path_list.append(os.path.join(path_with_trk_files, i))

    trk_merge.inputs.track_files = path_list
    trk_merge.run()
    return 

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Merge the .trk files into one .trk file",
                                     epilog="Referenced from Diffusion Toolkit"
                                            "by Anoushkrit Goel anoushkritgoel@gmail.com")
    # Paths
    parser.add_argument('--path_with_trks', type=str, required=True, default="/media/ang/Data/dMRI_data/599671/tracts",
                        help='Input the path containing the divided track files')
                        
    args = parser.parse_args()
    merge_trks(args.path_with_trks)