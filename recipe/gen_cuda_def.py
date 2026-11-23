import re
import shutil
import subprocess
import sys

cuda_lib, out = sys.argv[1], sys.argv[2]

dumpbin = shutil.which("dumpbin")
cmd = [dumpbin] if dumpbin else [shutil.which("link"), "/dump"]
members = subprocess.check_output(cmd + ["/linkermember:2", cuda_lib], text=True, errors="replace")

symbols = sorted({m.group(1) for m in re.finditer(r"^\s+[0-9A-F]+\s+(cu[A-Z][A-Za-z0-9_]+)$", members, re.M)})
if len(symbols) < 400 or "cuInit" not in symbols or "cuLaunchKernel" not in symbols:
    sys.exit(f"unexpected CUDA driver symbols in {cuda_lib}: found {len(symbols)}")

with open(out, "w", encoding="ascii", newline="\r\n") as f:
    f.write("LIBRARY nvcuda.dll\n\nEXPORTS\n")
    f.writelines(f"{s}\n" for s in symbols)
print(f"wrote {len(symbols)} symbols to {out}")
