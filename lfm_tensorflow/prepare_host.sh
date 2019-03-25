#!/bin/bash

#This script configures the proxy on the host computer

printf "This Script will configure the proxy on the host which is needed to get internet on the host as well as inside the container\n\n"
printf "This can only be done when running 'sourced', so please call this script like this:\n\n"
printf "source ./prepare_host.sh\n\n"
read -p "Are you running 'sourced'? (y/n): " -n 1 -r
printf "\n\n"
if [[ $REPLY =~ ^[Yy]$ ]]
then
	printf "Please enter your Proxy credentials:\n"
	printf "Username: "
	read username
	stty -echo
	printf "Password: "
	read password
	stty echo
	printf "\n"

	proxyurl="http://$username:$password@193.196.64.2:8888"
	noproxy="127.0.0.1, localhost, 193.196.64.0/18, .hs-karlsruhe.de"

	export http_proxy="$proxyurl"
	export HTTP_PROXY="$proxyurl"
	export https_proxy="$proxyurl"
	export HTTPS_PROXY="$proxyurl"
	export ftp_proxy="$proxyurl"
	export FTP_PROXY="$proxyurl"
	export no_proxy="$noproxy"
	export NO_PROXY="$noproxy"

	printf "All Proxys configured sucessfully.\n"
fi