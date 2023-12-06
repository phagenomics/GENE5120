## Main docker image for 
FROM ubuntu
MAINTAINER Julio Cesar Espinoza julioespinoza@curative.com
USER root

#disable interactive prompts of ubuntu install
ARG DEBIAN_FRONTEND=noninteractive

#Neccecary build packages
ARG BUILD_PACKAGES="wget git"

#Install build packages
RUN apt-get update && \
    apt-get install --yes $BUILD_PACKAGES
    
#nextflow needs AWS CLI and docker install in the container
#Neccecary build packages
ARG BUILD_PACKAGES="wget apt-transport-https lsb-release curl systemctl apt-utils rsync autoconf automake libtool unzip gzip"
#Install build packages
RUN apt-get update && \
    apt-get install --yes $BUILD_PACKAGES

### INSTRUCTIONS FOR NEXTFLOW: AWS and DOCKER.
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN apt install unzip
RUN unzip awscliv2.zip
RUN ./aws/install

#Install docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh get-docker.sh

#install samtools

RUN apt-get update && apt-get -y upgrade && \
	apt-get install -y build-essential wget \
		libncurses5-dev zlib1g-dev libbz2-dev liblzma-dev libcurl3-dev && \
	apt-get clean && apt-get purge && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /usr/src

RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
	tar jxf samtools-1.9.tar.bz2 && \
	rm samtools-1.9.tar.bz2 && \
	cd samtools-1.9 && \
	./configure --prefix $(pwd) && \
	make

ENV PATH=${PATH}:/usr/src/samtools-1.9 

#Intall BWA

RUN apt-get install --yes git
WORKDIR /tmp
RUN git clone https://github.com/lh3/bwa.git
WORKDIR /tmp/bwa
RUN git checkout v0.7.15

# Compile
RUN make
RUN cp -p bwa /usr/local/bin

WORKDIR /tmp
RUN git clone https://github.com/swiftbiosciences/primerclip.git
WORKDIR /tmp/primerclip/.stack-work/install/x86_64-linux/lts-11.0/8.2.2/bin
RUN chmod a+x primerclip
RUN mv primerclip /usr/local/bin

# Cleanup
RUN rm -rf /tmp/bwa
RUN apt-get clean
RUN apt-get remove --yes --purge build-essential gcc-multilib apt-utils zlib1g-dev wget


###BCFtools 
LABEL \
  version="1.12" \
  description="bcftools image for use in Workflows"

RUN apt-get update && apt-get install -y \
  bzip2 \
  g++ \
  libbz2-dev \
  libcurl4-openssl-dev \
  liblzma-dev \
  make \
  ncurses-dev \
  wget \
  zlib1g-dev

ENV BCFTOOLS_INSTALL_DIR=/opt/bcftools
ENV BCFTOOLS_VERSION=1.12

WORKDIR /tmp
RUN wget https://github.com/samtools/bcftools/releases/download/$BCFTOOLS_VERSION/bcftools-$BCFTOOLS_VERSION.tar.bz2 && \
  tar --bzip2 -xf bcftools-$BCFTOOLS_VERSION.tar.bz2

WORKDIR /tmp/bcftools-$BCFTOOLS_VERSION
RUN make prefix=$BCFTOOLS_INSTALL_DIR && \
  make prefix=$BCFTOOLS_INSTALL_DIR install

WORKDIR /
RUN ln -s $BCFTOOLS_INSTALL_DIR/bin/bcftools /usr/bin/bcftools && \
  rm -rf /tmp/bcftools-$BCFTOOLS_VERSION

## Install bedtools 
ARG PACKAGE_VERSION=2.27.1
ARG BUILD_PACKAGES="git openssl python build-essential zlib1g-dev"
ARG DEBIAN_FRONTEND=noninteractive

# Update the repository sources list
RUN apt-get update && \
    apt-get install --yes \
              $BUILD_PACKAGES && \
    cd /tmp && \
    git clone https://github.com/arq5x/bedtools2.git && \
    cd bedtools2 && \
    git checkout v$PACKAGE_VERSION && \
    make && \
    mv bin/* /usr/local/bin && \
 
    cd /tmp \
      
    cd / && \
    rm -rf /tmp/* && \
    apt remove --purge --yes \
              $BUILD_PACKAGES && \
    apt autoremove --purge --yes && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*






