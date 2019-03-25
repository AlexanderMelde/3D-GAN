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

# Install Python, Git, Wget and Nano (Text editor only for easier debugging, can be removed in final version)
RUN apt update && apt install -y git python-dev python-pip python-tk wget nano

# Install GPU Support Packages
RUN apt install -y --no-install-recommends \
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

# Install Tool for Visualization
RUN apt install -y meshlab

###############################################################################
#                             INSTALL PYTHON MODULES                          #
###############################################################################

RUN pip install --upgrade pip
RUN pip install --upgrade tensorflow-gpu tensorlayer Keras path.py visdom logger

###############################################################################
#                            INSTALL coms4995-project                         #
###############################################################################

# Clone Project and Checkout to specific commit to ensure compability
Run git clone https://github.com/rp2707/coms4995-project.git /root/coms4995-project/ --recursive
RUN cd /root/coms4995-project/ && git checkout d0a063eb00a58b1e48123838d5c2e341200569e9

# Download example training set
RUN cd /root/coms4995-project && wget http://3dshapenets.cs.princeton.edu/3DShapeNetsCode.zip 
RUN cd /root/coms4995-project && unzip 3DShapeNetsCode.zip

# Create Output Folder needed for scripts later
RUN mkdir /root/coms4995-project/chairs/output
RUN mkdir /root/coms4995-project/chairs/train_sample

# TODO: Move this to other pip/apt installs above
RUN pip install numpy-stl trimesh
RUN apt install -y scrot

# Include modified files from Host
COPY include/ /root/

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
WORKDIR /root

# Just open Bash on run:
CMD ["bash"]

