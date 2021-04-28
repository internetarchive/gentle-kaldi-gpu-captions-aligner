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

- https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Flowerquality%2Fgentle%2Fissues%2F187%3F_pjax%3D%2523js-repo-pjax-container
- https://github.com/pshved/timeout/blob/master/timeout


## build, run & test
```bash
docker build -t gentle-kaldi-gpu-captions-aligner .

docker run --rm -it --gpus all gentle-kaldi-gpu-captions-aligner
  # test, inside running container:
  python3 align.py examples/data/lucier.mp3 examples/data/lucier.txt
```


## results:
Tesla T4, Turing architecture
exclusive access to GPU (nothing else running)

3min video, 280 words (1676 characters)

### container with GPU enabled:
RAM usage:
RES:   30GB
VIRT: 360GB

barely engages GPU, only at the beginning
```bash
nvidia-smi dmon -s uc

# gpu    sm   mem   enc   dec  mclk  pclk
# Idx     %     %     %     %   MHz   MHz
    0     7     1     0     0  5000   585
    0     0     0     0     0  5000   585
    0     0     0     0     0   405   300
    0     1     0     0     0  5000   585
    0     7     1     0     0  5000   585
    0     1     0     0     0  5000   585
    0     1     0     0     0  5000   585
    0     2     0     0     0  5000   585
    0     2     0     0     0  5000   585
    0    10     0     0     0  5000   585
    0    30     1     0     0  5000   585
    0    42     1     0     0  5000   690
    0    35     2     0     0  5000  1275
    0    46     4     0     0  5000  1590
    0    32     3     0     0  5000  1590
    0    26     2     0     0  5000  1380
    0    31     2     0     0  5000  1140
    0     3     0     0     0  5000   735
    0     0     0     0     0  5000   585
    0     0     0     0     0  5000   585
    ...
    0     0     0     0     0  5000   585
    ...
    0     0     0     0     0   405   300
```

runs for 8m11s wallclock, crashes out (I believe during the `m3` step)

### container without GPU enabled:
RES: 12GB
VIRT: 114GB

runs for 30s wallclock
