import os
import sys
import shutil
import ctypes
from functools import lru_cache
from opendm import log

def gpu_disabled_by_user_env():
    return bool(os.environ.get('ODM_NO_GPU')) or  bool(os.environ.get('ODX_NO_GPU'))

@lru_cache(maxsize=None)
def get_cuda_compute_version(device_id = 0):
    cuda_lib = "libcuda.so"
    if sys.platform == 'win32':
        cuda_lib = os.path.join(os.environ.get('SYSTEMROOT'), 'system32', 'nvcuda.dll')
        if not os.path.isfile(cuda_lib):
            cuda_lib = "nvcuda.dll"

    nvcuda = ctypes.cdll.LoadLibrary(cuda_lib)

    nvcuda.cuInit.argtypes = (ctypes.c_uint32, )
    nvcuda.cuInit.restypes = (ctypes.c_int32)

    if nvcuda.cuInit(0) != 0:
        raise Exception("Cannot initialize CUDA")

    nvcuda.cuDeviceGetCount.argtypes = (ctypes.POINTER(ctypes.c_int32), )
    nvcuda.cuDeviceGetCount.restypes = (ctypes.c_int32)
    
    device_count = ctypes.c_int32()
    if nvcuda.cuDeviceGetCount(ctypes.byref(device_count)) != 0:
        raise Exception("Cannot get device count")

    if device_count.value == 0:
        raise Exception("No devices")

    nvcuda.cuDeviceComputeCapability.argtypes = (ctypes.POINTER(ctypes.c_int32), ctypes.POINTER(ctypes.c_int32), ctypes.c_int32)
    nvcuda.cuDeviceComputeCapability.restypes = (ctypes.c_int32)
    compute_major = ctypes.c_int32()
    compute_minor = ctypes.c_int32()

    if nvcuda.cuDeviceComputeCapability(ctypes.byref(compute_major), ctypes.byref(compute_minor), device_id) != 0:
        raise Exception("Cannot get CUDA compute version")

    return (compute_major.value, compute_minor.value)

def has_gpu(args):
    if gpu_disabled_by_user_env():
        log.INFO("Disabling GPU features (ODX_NO_GPU is set)")
        return False
    if args.no_gpu:
        log.INFO("Disabling GPU features (--no-gpu is set)")
        return False

    if sys.platform == 'win32':
        nvcuda_path = os.path.join(os.environ.get('SYSTEMROOT'), 'system32', 'nvcuda.dll')
        if os.path.isfile(nvcuda_path):
            log.INFO("CUDA drivers detected")
            return True
        else:
            log.INFO("No CUDA drivers detected")
            return False
    else:
        if shutil.which('nvidia-smi') is not None:
            log.INFO("nvidia-smi detected")
            return True
        else:
            log.INFO("No nvidia-smi detected")
            return False
