#!/bin/bash

#This script runs a dockerfile while passing all Proxy Settings from the Host to the Container

#We need to create ~/Documents/docker_share_lfm_tensorflow on host if it does not exist (as share folder for container)
mkdir -p ~/Documents/docker_share_lfm_tensorflow

xhost +
nvidia-docker run -it \
	--env http_proxy \
	--env HTTP_PROXY \
	--env https_proxy \
	--env HTTPS_PROXY \
	--env ftp_proxy \
	--env FTP_PROXY \
	--env no_proxy \
	--env NO_PROXY \
	-e "DISPLAY=unix:0.0" \
	-v="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	--privileged \
	--mount type=bind,source=/home/ADS/$USER/Documents/docker_share_lfm_tensorflow,target=/root/3dIWGAN/3D-Generation_shared \
	lfm_tensorflow

#--volume="~/Documents/docker_share_lfm_tensorflow:/root/3dIWGAN/3D-Generation" \
#cd ~/3dIWGAN/
#cd ~/3dIWGAN/3D-Generation/ && python 32-3D-IWGan.py --name "lfmTestChair" --data "data/train/chair"
#cd ~/3dIWGAN/scripts/ && python visualize.py ../3D-Generation/savepoint/lfmTestChair/1500.npy

# TO USE SHARED FOLDER: `cp -R 3D-Generation 3D-Generation_shared` like this:
#cd ~/3dIWGAN/3D-Generation/ && python 32-3D-IWGan.py --name "lfmTestChair" --data "data/train/chair" && cd .. && cp -R 3D-Generation 3D-Generation_shared

# FOR Z SAVING: 
#cd ~/3dIWGAN/3D-Generation/ && python IWGAN_own.py --name "ownLfmTestChair" --data "data/train/chair" && cd .. && cp -R 3D-Generation 3D-Generation_shared

#~/workbench  -> save into shared folder to not assemble again
# using tensorflow models, to generate objects with the generated zVectors in interpolation.py
#save models
#cd ~/3dIWGAN/3D-Generation/ && cp -R ./checkpoint/lfmTestChair/* ~/workbench/models 

#dont forget 
#cd ~/3dIWGAN/3D-Generation_shared/ && chmod 777 *

xhost -
