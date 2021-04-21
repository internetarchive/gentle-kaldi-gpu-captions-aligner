#include "online2/online-nnet3-decoding.h"
#include "online2/online-nnet2-feature-pipeline.h"
#include "online2/onlinebin-util.h"
#include "online2/online-timing.h"
#include "online2/online-endpoint.h"
#include "fstext/fstext-lib.h"
#include "lat/lattice-functions.h"
#include "lat/word-align-lattice.h"
#include "nnet3/decodable-simple-looped.h"

#ifdef HAVE_CUDA
#include "cudamatrix/cu-device.h"
#endif


int main(int argc, char *argv[]) {
    using namespace kaldi;
    using namespace fst;

    setbuf(stdout, NULL);

#ifdef HAVE_CUDA
    int deviceCount = 666;
    cudaError err = cudaGetDeviceCount(&deviceCount);
    printf("dc: %d\n", deviceCount);
    printf("error %d\n", err);

    fprintf(stdout, "Cuda enabled\n");
    CuDevice &cu_device = CuDevice::Instantiate();
    // cu_device.SetVerbose(true);
    cu_device.SelectGpuId("yes");
    // fprintf(stdout, "active gpu: %d\n", cu_device.ActiveGpuId());
#endif
}