# 1 CLINT -> DIVIDER
## Details
- Dead path from clint's mtip -> csr -> forwarding to ex-stage -> div_input -> div_register
- Path would never be taken, but to satisfy STA and build it cleaner path is registerd

## Fix
- Add register to mip computation, reduces path by ~10ns