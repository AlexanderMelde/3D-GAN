import bpy
from mathutils import Vector
import math
import sys
import os
from subprocess import call

#sys.path.append('/home/jonas/.local/lib/python2.7/site-packages')
import numpy as np

def voxel2mesh(voxels, threshold=.3):
    cube_verts = [[0, 0, 0], [0, 0, 1], [0, 1, 0], [0, 1, 1], [1, 0, 0], [1, 0, 1], [1, 1, 0],
                  [1, 1, 1]]  # 8 points

    cube_faces = [[0, 1, 2], [1, 3, 2], [2, 3, 6], [3, 7, 6], [0, 2, 6], [0, 6, 4], [0, 5, 1],
                  [0, 4, 5], [6, 7, 5], [6, 5, 4], [1, 7, 3], [1, 5, 7]]  # 12 face

    cube_verts = np.array(cube_verts)
    cube_faces = np.array(cube_faces) + 1

    l, m, n = voxels.shape

    scale = 0.01
    cube_dist_scale = 1.1
    verts = []
    faces = []
    curr_vert = 0

    positions = np.where(voxels > threshold) # recieves position of all voxels
    offpositions = np.where(voxels < threshold) # recieves position of all voxels
    voxels[positions] = 1 # sets all voxels values to 1
    voxels[offpositions] = 0
    for i,j,k in zip(*positions):
        if np.sum(voxels[i-1:i+2,j-1:j+2,k-1:k+2])< 27 : #identifies if current voxels has an exposed face
            verts.extend(scale * (cube_verts + cube_dist_scale * np.array([[i, j, k]])))
            faces.extend(cube_faces + curr_vert)
            curr_vert += len(cube_verts)
    return np.array(verts), np.array(faces)

def voxel2obj(filename, pred, threshold=.3):
    verts, faces = voxel2mesh(pred, threshold )
    write_obj(filename, verts, faces)

def write_obj(filename, verts, faces):
    """ write the verts and faces on file."""
    with open(filename, 'w') as f:
        # write vertices
        f.write('g\n# %d vertex\n' % len(verts))
        for vert in verts:
            f.write('v %f %f %f\n' % tuple(vert))

        # write faces
        f.write('# %d faces\n' % len(faces))
        for face in faces:
            f.write('f %d %d %d\n' % tuple(face))




# useful shortcut
scene = bpy.context.scene

# this shows you all objects in scene
scene.objects.keys()

# when you start default Blender project, first object in scene is a Cube
kostka = scene.objects[0]

# this will make object cease from current scene
scene.objects.unlink(kostka)

# clear everything for now
scene.camera = None
for obj in scene.objects:
    scene.objects.unlink(obj)

# for every object add material - here represented just as color
#for col, ob in zip([(1, 0, 0), (0,1,0), (0,0,1)], [kule, kostka, plane]):
#    mat = bpy.data.materials.new("mat_" + str(ob.name))
#    mat.diffuse_color = col
#    ob.data.materials.append(mat)

# now add some light
lamp_data = bpy.data.lamps.new(name="lampa", type='POINT')
lamp_object = bpy.data.objects.new(name="Lampicka", object_data=lamp_data)
scene.objects.link(lamp_object)
lamp_object.location = (0, 0, 1)

# and now set the camera
cam_data = bpy.data.cameras.new(name="cam")
cam_ob = bpy.data.objects.new(name="Kamerka", object_data=cam_data)
cam_ob.location = (0.343, -0.26583, 0.597)
cam_ob.rotation_mode = 'XYZ'
scene.objects.link(cam_ob)
cam = bpy.data.cameras[cam_data.name]
cam.lens = 10

scene.camera = cam_ob
scene.camera.rotation_euler = (math.radians(65.0),math.radians(-10.0),math.radians(60.0))

#loading and processing npy-files
arg = sys.argv.index("--") + 1
if len(sys.argv) <1:
    print('you need to specify what set of voxels to use')
print("using arg: " + sys.argv[arg])
models = np.squeeze(np.load(sys.argv[arg]))
print(models.shape[0])
i = 0
if not os.path.exists("./OBJ/"):
	os.makedirs("OBJ")

number_of_frame = 0
for i,m in enumerate(models):
	fileName = './OBJ/current' + str(i+1) +'.obj'
	voxel2obj(fileName, m)
	bpy.ops.import_scene.obj(filepath=fileName)
	bpy.data.objects['current' + str(i+1)].rotation_euler = (math.radians(4.0), 0, 0)
	i += 1

for i in range(1, models.shape[0] +1):
	fileName = './OBJ/current' + str(i) +'.obj'

	scene.frame_set(number_of_frame)
	for k in range(1, models.shape[0] +1):
		if(k != i):
			bpy.data.objects['current' + str(k)].location = (0,0,500) #bpy.data.objects['current' + str(k)].hide = True
			bpy.data.objects['current' + str(k)].keyframe_insert(data_path="location", index=-1)

        #bpy.data.objects['current' + str(i)].hide = False
	bpy.data.objects['current' + str(i)].location = (-0.35,-0.382,0)
	bpy.data.objects['current' + str(i)].keyframe_insert(data_path="location", index=-1)
	#obj_object = bpy.context.selected_objects[0]
	os.remove(fileName)
	number_of_frame += 1

scene.frame_set(0)
scene.frame_end = number_of_frame
#scene.frame_step = 6

bpy.context.scene.render.fps = 6

print("##########> start rendering <##########")

bpy.context.scene.render.filepath = './output/'
bpy.context.scene.render.image_settings.file_format='AVI_RAW'

bpy.ops.render.render(animation=True)
