#!/bin/sh -x

# this script trains a chair-model using the code from 
# https://github.com/rp2707/coms4995-projectcoms-project
# and then uses this model to interpolate between two 3d objects

##############################
#         VARIABLES          #
##############################

name="1912chair02"
from="2"
to="4"
epochs="30200" # nr. of epochs, saves checkpoint every 200, so epochs%200 should be zero.

echo "TASK: Train model with ${epochs} epochs and interpolate from object ${from} to ${to} using name=${name}."

##############################
#         PREPARATION        #
##############################

# Copy previous results from share folder to working directories
cp /root/share/models/* /root/coms4995-project/chairs/models
cp /root/share/output/* /root/coms4995-project/chairs/output
cp /root/share/train_sample/* /root/coms4995-project/chairs/train_sample

##############################
#  TRAINING & INTERPOLATION  #
##############################

# Train a Model M (we actually train ($epochs+1) epochs as the first checkpoint contains 201 epochs, as we start counting epochs at 0)
#TODO: Always run from latest checkpoint
cd /root/coms4995-project/chairs
#only train if not already trained (=model does not exist already)
if [ ! -f "/root/coms4995-project/chairs/models/biasfree_tfbn.ckpt-${epochs}.index" ]; then
    python 3dgan_mit_biasfree.py --train True --epochs "$((epochs + 1))"
fi


# Generate 3D-Objects O_M based on M and randomly generated ZVectors Z_M (O_M and Z_M are saved as npy files)
cd /root/coms4995-project/chairs
python 3dgan_mit_biasfree.py --ckpath "models/biasfree_tfbn.ckpt-${epochs}" --savename "${name}_${epochs}"

# Optional: Visualize O_M using meshlab
# python /root/visualize.py "/root/coms4995-project/chairs/output/${name}_${epochs}.npy"
# TODO: Save Images of the two 3D-Objects we interpolate between

# Create a new Z-Vector Z_I that interpolates between two Z-Vectors of Z_M:
cd /root/coms4995-project
python interpolation.py -p chairs/output -n "${name}_${epochs}" -f "$from" -t "$to"
# --> this outputs zvectors in file chairs/output/${name}_${epochs}_intpol_${from}_${to}_zvectors.npy

# Generate 3D-Objects based on Z_I and M
cd /root/coms4995-project/chairs
python 3dgan_mit_biasfree.py --ckpath "models/biasfree_tfbn.ckpt-${epochs}" --interpolatd_zs "output/${name}_${epochs}_intpol_${from}_${to}_zvectors.npy" --savename "${name}_${epochs}_intpol_${from}_${to}"
# --> saves 3D-Objects to ${name}_${epochs}_intpol_${from}_${to}__interpolated_results.npy and their z-vectors to ${name}_${epochs}_intpol_${from}_${to}__interpolated_results_zvectors.npy (this file is identical to ${name}_${epochs}_intpol_${from}_${to}_zvectors.npy)
# --> THEESE LAST RESULTING 3D OBJECTS CAN BE DOWNLOADED FROM https://anonfile.com/HdX6b4o4b2/lfmTest4200_intpol_2_4_interpolated_results_npy


##############################
#   SAVING & VISUALIZATION   #
##############################

# Copy results to share folder on host
mkdir -p /root/share/models && cp /root/coms4995-project/chairs/models/* /root/share/models
mkdir -p /root/share/output && cp /root/coms4995-project/chairs/output/* /root/share/output
mkdir -p /root/share/train_sample && cp /root/coms4995-project/chairs/train_sample/* /root/share/train_sample
cd /root/share && chmod -R 777 *

# Visualize using meshlab
python /root/visualize.py "/root/coms4995-project/chairs/output/${name}_${epochs}_intpol_${from}_${to}__interpolated_results.npy"

echo "###> Done <###"
