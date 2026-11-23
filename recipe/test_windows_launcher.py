import os
import sysconfig
import tempfile

from triton.backends.nvidia import driver
from triton.runtime import build
from triton.windows_utils import find_cuda

cc = build._find_compiler("c")
print("C compiler:", cc)
assert build.is_tcc(cc), cc

cuda_bin, cuda_inc, cuda_lib = find_cuda()
print("CUDA:", cuda_bin, cuda_inc, cuda_lib)
assert cuda_bin and cuda_inc and cuda_lib

src = os.path.join(driver.dirname, "driver.c")
with tempfile.TemporaryDirectory() as tmpdir:
    pyd = build._build("cuda_utils", src, tmpdir, driver.library_dirs(), driver.include_dirs, driver.libraries, [])
    print("built", pyd, os.path.getsize(pyd), "bytes")
    with open(pyd, "rb") as f:
        data = f.read().lower()
    python_dll = f"python{sysconfig.get_python_version().replace('.', '')}.dll".encode()
    assert b"nvcuda.dll" in data, "launcher does not import nvcuda.dll"
    assert python_dll in data, f"launcher does not import {python_dll!r}"
