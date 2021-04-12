# gentle-kaldi-gpu-captions-aligner

Gentle project (using Kaldi) able to leverage nvidia/cuda GPU.

Similar to:
- https://hub.docker.com/r/lowerquality/gentle/
- https://github.com/lowerquality/gentle

but leveraging an nvidia/kaldi GPU optimized docker image.


## helpful links
- https://github.com/lowerquality/gentle/issues/187?_pjax=%23js-repo-pjax-container
- https://docs.nvidia.com/deeplearning/frameworks/kaldi-release-notes/rel_21-02.html#rel_21-02
- https://medium.com/voicetube/build-gentle-w-cuda-enabled-kaldi-cb9eac86afc3
- https://kaldi-asr.org/doc/cudamatrix.html
- https://hub.docker.com/r/lowerquality/gentle/dockerfile



## build, run & test
```bash
docker build -t gentle-kaldi-gpu-captions-aligner .

docker run --rm -it --gpus all gentle-kaldi-gpu-captions-aligner
  # test, inside running container:
  python3 align.py examples/data/lucier.mp3 examples/data/lucier.txt
```
