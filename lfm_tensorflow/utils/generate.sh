#!/bin/bash

#this script trains a model, copies all data into workbench
#keep this in shared folder, much easier to execute

name="1512chair05"
epochs="110" # file name, only saves every 5
epochArg="111" # to generate the intended epoch add one
zvectorName="./${name}_zvectors.npy"
netd="net_d_${epochs}.npz"
netg="net_g_${epochs}.npz"
interpolatedName="${name}_interpolated"

echo "########################################"
echo "Name: $name"
echo $zvectorName
echo $interpolatedName
echo "Training for $epochs"
echo "########################################"

#edit to save zvector
cd ~/3dIWGAN/3D-Generation_shared/3D-Generation/ && python ownIWGan.py -e "$epochArg" -b 32 --name "$name" --data "data/train/chair" #&& cd .. && cp -R 3D-Generation 3D-Generation_shared

#edit interpolation.py to use z vector
cd ~/3dIWGAN/3D-Generation_shared/ && python interpolation.py -n "${name}"

#copy models
cd ~/3dIWGAN/3D-Generation_shared/3D-Generation/checkpoint/ && mkdir -p ${interpolatedName} && cp ./${name}/${netd} ./${interpolatedName}/ && cp ./${name}/${netg} ./${interpolatedName}/

#copy plots
cd ~/3dIWGAN/3D-Generation_shared/3D-Generation/savepoint/ && mkdir -p ${interpolatedName} && cp -R ./${name}/plots/ ./${interpolatedName}/

#run again, edit to use load previous models
cd ~/3dIWGAN/3D-Generation_shared/3D-Generation/ && python ownIWGan.py -e "$epochArg" -b 32 --name "$interpolatedName" -l -le "${epochs}" --data "data/train/chair" --zvector "${interpolatedName}.npy" -t

#finally
cd ~/3dIWGAN/3D-Generation_shared && chmod -R 777 *

echo "###> Done <###"


