# syntax = docker/dockerfile:1.0-experimental
# https://docs.docker.com/develop/develop-images/build_enhancements/#overriding-default-frontends


# Start with very recent nvidia + kaldi optimized cuda/GPU image.

# pick/toggle each of these two pairs:

FROM nvcr.io/nvidia/kaldi:21.03-py3
# FROM kaldiasr/kaldi:gpu-latest

ENV LIBCUDA_DIR=/usr/local/cuda/compat/lib.real
# ENV LIBCUDA_DIR=/usr/local/cuda/compat


LABEL maintainer="Tracey Jaquith <tracey@archive.org>"

RUN apt-get -yqq update  &&  apt-get -yqq install  ffmpeg  zsh

RUN  cd /  &&  git clone https://github.com/lowerquality/gentle
WORKDIR /gentle


# populate 'exp' subdir (w/ less verbose wget)
RUN perl -i -pe 's/wget/wget -q/' ./install_models.sh  &&  ./install_models.sh


# fix missing include
RUN cd ext  &&  ( echo '#include "tree/context-dep.h"'; cat m3.cc ) >| x.cc  &&  mv x.cc m3.cc


# NOTE: final needed .so lib file comes from nvidia base container
ENV CUDA=true
ENV KALDI_SRC=/opt/kaldi/src
ENV KALDI_TOOLS=/opt/kaldi/tools
ENV KLIBS="\
$KALDI_TOOLS/openfst-1.6.7/lib/libfst.so \
$KALDI_SRC/base/libkaldi-base.so \
$KALDI_SRC/chain/libkaldi-chain.so \
$KALDI_SRC/cudamatrix/libkaldi-cudamatrix.so \
$KALDI_SRC/decoder/libkaldi-decoder.so \
$KALDI_SRC/feat/libkaldi-feat.so \
$KALDI_SRC/fstext/libkaldi-fstext.so \
$KALDI_SRC/gmm/libkaldi-gmm.so \
$KALDI_SRC/hmm/libkaldi-hmm.so \
$KALDI_SRC/ivector/libkaldi-ivector.so \
$KALDI_SRC/lat/libkaldi-lat.so \
$KALDI_SRC/matrix/libkaldi-matrix.so \
$KALDI_SRC/nnet2/libkaldi-nnet2.so \
$KALDI_SRC/nnet3/libkaldi-nnet3.so \
$KALDI_SRC/online2/libkaldi-online2.so \
$KALDI_SRC/transform/libkaldi-transform.so \
$KALDI_SRC/tree/libkaldi-tree.so \
$KALDI_SRC/util/libkaldi-util.so \
$LIBCUDA_DIR/libcuda.so"


# LD_LIBRARY_PATH=$(echo "$KLIBS" |tr ' ' '\n' |rev |cut -f2- -d/ |rev |grep / |perl -ne 'chop; print; print ":\\\n"'; echo)
ENV LD_LIBRARY_PATH=\
/opt/kaldi/tools/openfst-1.6.7/lib:\
/opt/kaldi/src/base:\
/opt/kaldi/src/chain:\
/opt/kaldi/src/cudamatrix:\
/opt/kaldi/src/decoder:\
/opt/kaldi/src/feat:\
/opt/kaldi/src/fstext:\
/opt/kaldi/src/gmm:\
/opt/kaldi/src/hmm:\
/opt/kaldi/src/ivector:\
/opt/kaldi/src/lat:\
/opt/kaldi/src/matrix:\
/opt/kaldi/src/nnet2:\
/opt/kaldi/src/nnet3:\
/opt/kaldi/src/online2:\
/opt/kaldi/src/transform:\
/opt/kaldi/src/tree:\
/opt/kaldi/src/util:\
$LIBCUDA_DIR


# build the `k3` and `m3` binaries
RUN \
  # patch older cuda API calls out, then compile
  cd /gentle/ext  && \
  perl -i -pe 's/^.*cu_device.SetVerbose.*$//'  k3.cc  && \
  perl -i -pe 's/^.*cu_device.ActiveGpuId.*$//' k3.cc  && \
  for CC in k3 m3; do \
    g++ -std=c++11 -O3 -DNDEBUG -o $CC $CC.cc \
      -DKALDI_DOUBLEPRECISION=0 -DHAVE_EXECINFO_H=1 -DHAVE_CXXABI_H \
      -DHAVE_CUDA \
      -DHAVE_ATLAS \
      -I $KALDI_SRC \
      -I $KALDI_TOOLS/openfst-1.6.7/include \
      -I /usr/local/cuda-*/targets/x86_64-linux/include \
      -msse -msse2 -pthread -g \
      -fPIC \
      -lgfortran -lm -lpthread -ldl \
      $KLIBS  ||  exit 1; \
  done


# test like:
#  python3 align.py examples/data/lucier.mp3 examples/data/lucier.txt

CMD /bin/zsh
