#!/bin/bash -ex

docker run --rm -it --name ccgpu  -v /home/tracey/.zshrc:/root/.zshrc -v /home/tracey/av/env/aliases:/root/.aliases ubuntu:focal bash # --gpus all

export DEBIAN_FRONTEND=noninteractive
apt-get update && \
apt-get install -y \
		gcc g++ gfortran \
		libc++-dev \
		zlib1g-dev \
		automake autoconf libtool \
		git subversion \
		libatlas3-base \
		ffmpeg \
		python3 python3-dev python3-pip \
		python2.7 python2-dev \
		wget unzip \
    \
    zsh libatlas-base-dev
    \
    python-is-python3
# python2-pip pkg replacement:
wget -q    https://github.com/pypa/get-pip/raw/20.3.4/get-pip.py
python2  get-pip.py --trusted-host pypi.python.org --no-setuptools --no-wheel
rm get-pip.py


cd /tmp
# https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&target_distro=Ubuntu&target_version=2004&target_type=deblocal
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.2.2/local_installers/cuda-repo-ubuntu2004-11-2-local_11.2.2-460.32.03-1_amd64.deb
dpkg -i cuda-repo-ubuntu2004-11-2-local_11.2.2-460.32.03-1_amd64.deb
apt-key add /var/cuda-repo-ubuntu2004-11-2-local/7fa2af80.pub
apt-get -yqq update

apt-get -y install nvidia-cuda-dev nvidia-cuda-toolkit
ls /usr/lib/cuda
export CUDA=true

cd /
git clone https://github.com/lowerquality/gentle
cd gentle
git submodule init  &&  git submodule update
#( cd ext/kaldi; git checkout 7ffc9ddeb3c8436e16aece88364462c89672a183 )
#perl -i -pe 's/openfst\.cs\.nyu\.edu/www\.openfst\.org/g'                  ext/kaldi/tools/Makefile
perl -i -pe 's|use\-cuda=no|use-cuda=yes --cudatk-dir=/usr/lib/cuda/|'     ext/install_kaldi.sh
perl -i -pe 's/make clean/make clean || echo make clean failed move on/'   ext/install_kaldi.sh
perl -i -pe 's/cu_device\.SetVerbose\(true\)/cu_device.SetVerbose(false)/' ext/k3.cc
perl -i -pe 's=#./bin/bash$=#!/bin/bash -ex='   install*.sh   ext/install_kaldi.sh   ext/kaldi/tools/extras/install_openblas.sh
perl -i -pe 's=#./usr/bin/env bash$=#!/usr/bin/env bash -ex='   install*.sh   ext/install_kaldi.sh   ext/kaldi/tools/extras/install_openblas.sh

cd ext
./install_kaldi.sh
# Unsupported CUDA_VERSION (CUDA_VERSION=10_1), please report it to Kaldi mailing list, together with 'nvcc -h' or 'ptxas -h' which lists allowed -gencode values...


export CXX=/usr/bin/g++-8
./configure --static --static-math=yes --static-fst=yes --use-cuda=yes --openblas-root=../tools/OpenBLAS/install


perl -i -pe 's/^.*SetVerbose.*$//; s/^.*cu_device.ActiveGpuId.*$//' k3.cc
( echo '#include "tree/context-dep.h"'; cat m3.cc ) >| x.cc  &&  mv x.cc m3.cc


# .. make
# to make `k3` - swap out final g++ back to std version /usr/bin/g++

# test
cd /gentle
python3 align.py examples/data/lucier.mp3 examples/data/lucier.txt

