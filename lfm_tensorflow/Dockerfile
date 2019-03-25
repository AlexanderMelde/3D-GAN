FROM nvidia/cudagl:9.0-base
#TODO: Try out tensorflow/tensorflow-gpu image instead (see https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/gpu.Dockerfile)
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
RUN apt update && apt install -y git python-dev python-pip python-tk wget

RUN pip install --upgrade pip

###############################################################################
#                                INSTALL TENSORFLOW                           #
###############################################################################

RUN pip install --upgrade tensorflow-gpu tensorlayer Keras path.py
#TODO: install tensorflow-gpu !
#RUN pip install tensorlayer
#RUN pip install Keras
#RUN pip install path.py

###############################################################################
#                            INSTALL 3DIWGAN-RELEASE                          #
###############################################################################
Run git clone https://github.com/EdwardSmith1884/3D-IWGAN.git ~/3dIWGAN --recursive

#RUN sed -i -e 's/import keras.backend as K/from keras import backend as K/g' ~/3dIWGAN/scripts/models.py
# now called utils
RUN sed -i -e 's/tl.ops.set_gpu_fraction(sess=sess, gpu_fraction=0.998)/tl.utils.set_gpu_fraction(gpu_fraction=0.998)/g' ~/3dIWGAN/3D-Generation/32-3D-IWGan.py
RUN sed -i -e 's/tl.ops.set_gpu_fraction(sess=sess, gpu_fraction=0.998)/tl.utils.set_gpu_fraction(gpu_fraction=0.998)/g' ~/3dIWGAN/3D-Generation/32-3D-Gan.py
# delete this line, unnecessary else?
RUN sed -i -e '/else:/d' ~/3dIWGAN/3D-Generation/32-3D-Gan.py
#TODO: need to delete indent
#RUN sed -i -e 's/^	dis = discriminator/dis = discriminator/' ~/3dIWGAN/3D-Generation/32-3D-Gan.py
RUN sed -i -e 's/[ \t]dis = discriminator/dis = discriminator/' ~/3dIWGAN/3D-Generation/32-3D-Gan.py
# delete this line, deprecated
RUN sed -i -e '/tl.layers.set_name_reuse(reuse)/d' ~/3dIWGAN/scripts/models.py
# changed name, deprecated
RUN sed -i -e 's/tl.activation.leaky_relu/tf.nn.leaky_relu/g' ~/3dIWGAN/scripts/models.py

RUN cd ~/3dIWGAN/3D-Generation/ && chmod 777 ./Make_Data.sh && sed -i -e '/python convert_shapenet10.py 3DShapeNets/d' ./Make_Data.sh
Run apt install -y unzip
RUN cd ~/3dIWGAN/3D-Generation/ && ./Make_Data.sh
RUN cd ~/3dIWGAN/3D-Generation/ && chmod 777 ./convert_shapenet10.py && python ./convert_shapenet10.py 3DShapeNets

#TODO provide arguments
#[-h] [-n NAME] [-d DATA] [-e EPOCHS] [-b BATCHSIZE][-sample SAMPLE] [-save SAVE] [-l] [-le LOAD_EPOCH] [-graph GRAPH]
RUN apt-get install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-9-0 \
        cuda-cublas-9-0 \
        cuda-cufft-9-0 \
        cuda-curand-9-0 \
        cuda-cusolver-9-0 \
        cuda-cusparse-9-0 \
        curl \
        libcudnn7=7.2.1.38-1+cuda9.0 \
        libnccl2=2.2.13-1+cuda9.0 \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        rsync \
        software-properties-common \
	unzip
# run with 3 epochs for a quick test, but nothing useful for production
# EDIT: Unfortunately, there is no way to support cuda/gpu during docker build time, so we need to finish building and then use theese commands using nvidia-docker run. nvidia-docker build is doing nothing different than regular docker build.
#RUN cd ~/3dIWGAN/3D-Generation/ && python ./32-3D-IWGan.py -e 3
#RUN cd ~/3dIWGAN/3D-Generation/ && python 32-3D-IWGan.py --name "lfmTestChair" --data "data/train/chair" -e 1500

#Install Text editor for easier debugging, can be removed in final version
RUN apt install -y nano
#Install Tool for Visualization
RUN apt install -y meshlab

RUN git clone https://github.com/rp2707/coms4995-project.git ~/interpolation/
RUN pip install visdom logger

RUN mkdir ~/workbench && mkdir ~/workbench/zvectors && mkdir ~/workbench/models && mkdir ~/workbench/chairData

COPY ./utils/generate.sh /root/3dIWGAN/

RUN cd /root/interpolation && wget http://3dshapenets.cs.princeton.edu/3DShapeNetsCode.zip 


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
