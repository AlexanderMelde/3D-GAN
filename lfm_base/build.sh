#!/bin/bash

#This script builds a dockerfile while passing all Proxy Settings from the Host to the Container

docker build -t lfm_base \
	--build-arg http_proxy="$http_proxy" \
	--build-arg HTTP_PROXY="$HTTP_PROXY" \
	--build-arg https_proxy="$https_proxy" \
	--build-arg HTTPS_PROXY="$HTTPS_PROXY" \
	--build-arg ftp_proxy="$ftp_proxy" \
	--build-arg FTP_PROXY="$FTP_PROXY" \
	--build-arg no_proxy="$no_proxy" \
	--build-arg NO_PROXY="$NO_PROXY" . && \
#
#Remove intermediate cached containers which might contain proxy passwords
docker system prune -f
