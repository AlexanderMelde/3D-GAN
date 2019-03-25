FROM nvidia/cudagl:9.0-base
###############################################################################
# 			ENVIRONMENT PROXY CONFIGURATION                       #
###############################################################################
ENV http_proxy="$http_proxy"   HTTP_PROXY="$HTTP_PROXY"   \
    https_proxy="$https_proxy" HTTPS_PROXY="$HTTPS_PROXY" \
    ftp_proxy="$ftp_proxy"     FTP_PROXY="$FTP_PROXY"     \
    no_proxy="$no_proxy"       NO_PROXY="$NO_PROXY"
RUN export http_proxy="$http_proxy"   && export HTTP_PROXY="$HTTP_PROXY"    \
 && export https_proxy="$https_proxy" && export HTTPS_PROXY="$HTTPS_PROXY" \
 && export ftp_proxy="$ftp_proxy"     && export FTP_PROXY="$FTP_PROXY"     \
 && export no_proxy="$no_proxy"       && export NO_PROXY="$NO_PROXY"
###############################################################################
#                           APT PROXY CONFIGURATION                           #
###############################################################################
RUN printf \
"Acquire::http::proxy \"$http_proxy\";\n"\
"Acquire::https::proxy \"$https_proxy\";\n"\
"Acquire::HTTP::proxy \"$HTTP_PROXY\";\n"\
"Acquire::HTTPS::proxy \"$HTTPS_PROXY\";\n"\
"Acquire::ftp::proxy \"$ftp_proxy\";\n"\
"Acquire::FTP::proxy \"$FTP_PROXY\";\n"\
>> /etc/apt/apt.conf.d/80proxy.conf
###############################################################################
#                        INSTALL REQUIRED APT PACKAGES                        #
###############################################################################
RUN apt update && apt install -y git libmatio2 sudo libatlas-base-dev libatlas3-base
###############################################################################
#                                INSTALL TORCH                                #
###############################################################################
RUN git clone https://github.com/torch/distro.git ~/torch --recursive
#Modify downloaded file to be docker-compatible: 
#Remove OpenBlas Installation, instead we use Atlas loaded via atp earlier.
RUN sed -i -e 's/install_openblas || true//g' ~/torch/install-deps
RUN bash ~/torch/install-deps
RUN cd ~/torch && ./install.sh
# Manually set environment Variables via Docker instead of sourcing bashrc
# RUN cat /root/torch/install/bin/torch-activate
# RUN bash -c "source /root/torch/install/bin/torch-activate" #todo:replace source by .
ENV LUA_PATH="/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/root/torch/install/share/lua/5.1/?.lua;/root/torch/install/share/lua/5.1/?/init.lua;./?.lua;/root/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua" \
    LUA_CPATH="/root/.luarocks/lib/lua/5.1/?.so;/root/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so" \
    PATH=/root/torch/install/bin:$PATH \
    LD_LIBRARY_PATH=/root/torch/install/lib:$LD_LIBRARY_PATH \
    DYLD_LIBRARY_PATH=/root/torch/install/lib:$DYLD_LIBRARY_PATH \
    LUA_CPATH="/root/torch/install/lib/?.so;"$LUA_CPATH
# Continue Torch Installation
#Configure git: Use https instead of git protocol because proxy blocks git://.
#               (Needed for luarocks package manager)
RUN git config --global url.https://github.com/.insteadOf git://github.com/
RUN luarocks install matio

###############################################################################
#                            INSTALL 3DGAN-RELEASE                            #
###############################################################################
RUN git clone https://github.com/zck119/3dgan-release.git ~/3dgan --recursive
RUN apt install wget
RUN  cd ~/3dgan && ./download_models_cpu.sh
RUN  cd ~/3dgan && ./download_models_gpu.sh
RUN  cd ~/3dgan && ./download_demo_inputs.sh

RUN apt install -y python-pip
RUN pip install --upgrade pip
RUN pip install numpy matplotlib scipy vtk
#==5.10.1
RUN cd ~/3dgan && th main.lua -gpu 0 -class chair
#TODO: Test GPU Version
# Modify visualization file, as we use a more recent version of vtk than the
# authors of 3dgan-release.
RUN sed -i -e 's/cubeMapper.SetInput(cube)/cubeMapper.SetInputData(cube)/g' ~/3dgan/visualization/python/util_vtk.py

#RUN apt-get install -y kmod mesa-utils
#RUN apt install -y x11-xserver-utils mesa-utils

###############################################################################
#                        REMOVE APT PROXY CONFIGURATION                       #
###############################################################################
RUN rm /etc/apt/apt.conf.d/80proxy.conf
###############################################################################
#                REMOVE ENVIRONMENT PROXY CONFIGURATION FOR APT               #
###############################################################################
ENV http_proxy=""  HTTP_PROXY=""  \
    https_proxy="" HTTPS_PROXY="" \
    ftp_proxy=""   FTP_PROXY=""   \
    no_proxy=""    NO_PROXY=""
RUN unset http_proxy  && unset HTTP_PROXY  \
 && unset https_proxy && unset HTTPS_PROXY \
 && unset ftp_proxy   && unset FTP_PROXY   \
 && unset no_proxy    && unset NO_PROXY
###############################################################################
#                        SET RUN-BEHAVIOUR (STARTUP SCRIPT)                   #
###############################################################################
CMD ["bash"]