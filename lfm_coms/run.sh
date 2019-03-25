#!/bin/bash

#This script runs a dockerfile while passing all Proxy Settings from the Host to the Container

#We need to create share folder on host if it does not exist
mkdir -p ${PWD}/output

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
	--mount type=bind,source=${PWD}/output,target=/root/share/ \
	lfm_coms

xhost -
