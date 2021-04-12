# Start with very recent nvidia + kaldi optimized cuda/GPU image.

# To develop, you could run hooked into your GPU like:
# docker run --rm -it --gpus all nvcr.io/nvidia/kaldi:21.03-py3 bash
FROM nvcr.io/nvidia/kaldi:21.03-py3
LABEL maintainer="Tracey Jaquith <tracey@archive.org>"

RUN apt-get -yqq update  &&  apt-get -yqq install  ffmpeg

RUN  cd /  &&  clone https://github.com/lowerquality/gentle
WORKDIR /gentle

ENV CUDA=true
ENV KALDI_SRC=/opt/kaldi/src
ENV KALDI_TOOLS=/opt/kaldi/tools
ENV KLIBS="$KALDI_TOOLS/openfst-1.6.7/lib/libfst.so \
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
$KALDI_SRC/util/libkaldi-util.so"

# LD_LIBRARY_PATH=$(echo "$KLIBS" |rev |cut -f2- -d/ _rev |tr '\n' :)
ENV LD_LIBRARY_PATH=/opt/kaldi/src/base:/opt/kaldi/src/chain:/opt/kaldi/src/cudamatrix:/opt/kaldi/src/decoder:/opt/kaldi/src/feat:/opt/kaldi/src/fstext:/opt/kaldi/src/gmm:/opt/kaldi/src/hmm:/opt/kaldi/src/ivector:/opt/kaldi/src/lat:/opt/kaldi/src/matrix:/opt/kaldi/src/nnet2:/opt/kaldi/src/nnet3:/opt/kaldi/src/online2:/opt/kaldi/src/transform:/opt/kaldi/src/tree:/opt/kaldi/src/util:/opt/kaldi/tools/openfst-1.6.7/lib

# fix missing include
RUN cd /gentle/ext  &&  \
    ( echo '#include "tree/context-dep.h"'; cat m3.cc ) >| x.cc  &&  mv x.cc m3.cc

RUN ( \
  for CC in k3 m3; do \
    echo " \
g++ -std=c++11 -O3 -DNDEBUG -I$KALDI_SRC/ -o $CC $CC.cc \
  -DKALDI_DOUBLEPRECISION=0 -DHAVE_EXECINFO_H=1 -DHAVE_CXXABI_H -DHAVE_OPENBLAS \
  -I$KALDI_TOOLS/openfst-1.6.7/include \
  -I$KALDI_SRC \
  -Wno-sign-compare -Wall -Wno-sign-compare -Wno-unused-local-typedefs -Wno-deprecated-declarations \
  -Winit-self \
  -msse -msse2 -pthread -g \
  -fPIC \
  -lgfortran -lm \
  $KLIBS \
" |tr '\n' ' ' \
  echo \
  done \
) |bash -ex

# fill 'exp' subdir
RUN cd /gentle  &&  ./install_models.sh


CMD /bin/bash
