# 1 CLINT -> DIVIDER
## Details
- Dead path from clint's mtip -> csr -> forwarding to ex-stage -> div_input -> div_register
- Path would never be taken, but to satisfy STA and build it cleaner path is registerd

## Fix
- Add register to mip computation, reduces path by ~10ns

# 2 DIV -> EX_RES
## Details
- Path from computed calulation to q_maq -> adjusting -> div_res computing
- Each alone takes long du to sub & shifts, mult etc

## Fix
- Move them in a seperate state. Each compute intense step gets it's own stage, q_maq, adjusting ...