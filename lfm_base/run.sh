#!/bin/bash

#This script runs a dockerfile while passing all Proxy Settings from the Host to the Container


xhost +local:root
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
	lfm_base
	#--env="DISPLAY" \
	#--env="QT_X11_NO_MITSHM=1" \
	#--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \

#python /root/3dgan/visualization/python/visualize.py /root/3dgan/output/chair_demo.mat -u 0.9 -t 0.1 -i 1 -mc 2

xhost -local:root
