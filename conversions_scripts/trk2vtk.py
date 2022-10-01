import vtk
from dipy.tracking.streamline import Streamlines
from dipy.io.streamline import load_trk
import nibabel 

def saveStreamlinesVTK(streamlines, pStreamlines):
    polydata = vtk.vtkPolyData()

    lines = vtk.vtkCellArray()
    points = vtk.vtkPoints()
    
    ptCtr = 0
       
    for i in range(0,len(streamlines)):
        if((i % 10000) == 0):
                print(str(i) + "/" + str(len(streamlines)))

        
        line = vtk.vtkLine()
        line.GetPointIds().SetNumberOfIds(len(streamlines[i]))
        for j in range(0,len(streamlines[i])):
            points.InsertNextPoint(streamlines[i][j])
            linePts = line.GetPointIds()
            linePts.SetId(j,ptCtr)
            
            ptCtr += 1
            
        lines.InsertNextCell(line)
                               
    polydata.SetLines(lines)
    polydata.SetPoints(points)
    
    writer = vtk.vtkPolyDataWriter()
    writer.SetFileName(pStreamlines)
    writer.SetInputData(polydata)
    writer.Write()
    
    print("Wrote streamlines to " + writer.GetFileName())

tracks_for_visualisation = "/home/ang/Documents/GitHub/SupWMA/merged_tracks.trk"

# streams = nibabel.streamlines.trk.TrkFile(tracks_for_visualisation)
# print(streams.streamlines)
# streams.load_trk(tracks_for_visualisation)
streams = load_trk(tracks_for_visualisation, reference='same')
streamlines = Streamlines(streams)
saveStreamlinesVTK(streamlines,"/home/ang/Documents/GitHub/SupWMA/merged_tracks.vtk")
