"""Reference from https://github.com/zhangfanmark/DeepWMA"""
import numpy as np
import whitematteranalysis as wma
# refers https://github.com/SlicerDMRI/whitematteranalysis/blob/master/whitematteranalysis/fibers.py
import utils.fibers as fibers


def feat_RAS(pd_tract, number_of_points=15):
    """Convert input vtkPolyData to the fixed length fiber representation of this class.
        The polydata should contain the output of tractography.
        The output is downsampled fibers in array format and hemisphere info is also calculated.
        and then extract RAS coordinates from the fiberarray"""


    fiber_array = wma.fibers.FiberArray()
    fiber_array.convert_from_polydata(pd_tract, points_per_fiber=number_of_points)
    # fiber_array_r, fiber_array_a, fiber_array_s have the same size: [number of fibers, points of each fiber]
    
    feat = np.dstack((fiber_array.fiber_array_r, fiber_array.fiber_array_a, fiber_array.fiber_array_s))
    #dstack: depth stack, vstack: vertical stack, hstack: horizontal stack
    # dstack: [3,1], [3,1] : [3,1,2]
    # hstack: [3,1], [3,1] : [3,2]
    # vstack: [3,1], [3,1] : [6,1]

    return feat


def feat_curv_tors(pd_tract, number_of_points=15):
    """For extracting the curvature and torsion features in the fiber information"""

    fiber_array = fibers.FiberArray()
    fiber_array.convert_from_polydata_with_trafic(pd_tract, points_per_fiber=number_of_points)

    feat = np.dstack((fiber_array.fiber_array_cur, fiber_array.fiber_array_tor))

    return feat


def feat_RAS_curv_tors(pd_tract, number_of_points=15):
    """The most simple feature for initial test"""

    fiber_array = fibers.FiberArray()
    fiber_array.convert_from_polydata_with_trafic(pd_tract, points_per_fiber=number_of_points)
    
    # incorporates both RAS, curvature and torsion into one feature array
    feat = np.dstack((fiber_array.fiber_array_r, fiber_array.fiber_array_a, fiber_array.fiber_array_s,
                      fiber_array.fiber_array_cur, fiber_array.fiber_array_tor))
    # Would dstack work in this, since it works for upto 3 dimensional vectors? 
    

    return feat


def feat_RAS_3D(pd_tract, number_of_points=15, repeat_time=15):
    """The most simple feature for initial test"""

    feat = feat_RAS(pd_tract, number_of_points=number_of_points)  
    # size: [number of fibers, points on each fiber, RAS (three dimensions)]
    # aka:
    
#     [[[R,A,S], [R,A,S], ..... number of points]
#      .
#      .
#      .
#      .
#      number of fibers
#     ]

    feat_1221_2112_repeat = _feat_to_3D(feat, repeat_time=repeat_time)
    # feat_1221_2112_repeat?

    return feat_1221_2112_repeat


def _feat_to_3D(feat, repeat_time=15):
    # 1 first; 2 last
    # 12 is the original point order
    # 21 is the fliped point order
    feat_12 = feat
    # size: [number of fibers, points on each fiber, RAS (three dimensions)]
    feat_21 = np.flip(feat_12, axis=1)
#     array([[1, 2, 2, 3],
#            [9, 2, 3, 1]]) BECOMES array([[3, 2, 2, 1],
#                                          [1, 3, 2, 9]])

    # concatenate the different orders
    feat_1221 = np.concatenate((feat_12, feat_21), axis=1) # horizontal concatenation
    feat_2112 = np.concatenate((feat_21, feat_12), axis=1) # concatenation of flipped sequences

    # reshape to a 4D array
    feat_shape = (feat_1221.shape[0], 1, feat_1221.shape[1], feat_1221.shape[2])
    # why was it made a 4D array and a constant 1 was introduced in the feature shape?
    # what I think is: feat_shape = (number of fibers, 1, number of points per fibers, 3)
    # eg: (25000, 1, 100, 3)

    feat_1221 = np.reshape(feat_1221, feat_shape)
    feat_2112 = np.reshape(feat_2112, feat_shape)

    # Now the dimension is (# of fibers, 2, # of points, 3)
    # the second D is [1221; 2112]; the fourth D is RAS
    feat_1221_2112 = np.concatenate((feat_1221, feat_2112), axis=1)

    # Repeat the send D;
    # In the tmp variable, it is [1221; 1221; ...; 2112; 2112; ....],
    # but we want [1221; 2112; 1221; 2112; ....]
    feat_1221_2112_repeat_tmp = np.repeat(feat_1221_2112, repeat_time, axis=1)
    
    # 12212112|12212112|12212112|... 15 times

    feat_1221_2112_repeat = np.zeros(feat_1221_2112_repeat_tmp.shape)

    feat_1221_2112_repeat[:, 0::2, :, :] = feat_1221_2112_repeat_tmp[:, 0:repeat_time, :, :]
    # start at 0th value and jump by 2, take in every 0,2,4,6..14 (
    feat_1221_2112_repeat[:, 1::2, :, :] = feat_1221_2112_repeat_tmp[:, repeat_time:, :, :]
    # start from 1th value and feed every alternate position with the values from feat_1221_2112
    # 1,3,5,7,9,...15

    return feat_1221_2112_repeat


def downsample(ds_step, x_data, y_data=None):
    x_data_ds = x_data[::ds_step, :, :, :]

    y_data_ds = None
    if y_data is not None:
        y_data_ds = y_data[::ds_step]

    return (x_data_ds, y_data_ds)
