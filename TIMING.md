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

# 3 EX_MEM_OUT -> DIV
## Details
- ex_mem_out -> forwarding -> div -> norm -> LZN

## Fix
- Latch all div inputs, add 2 extra fsm stages

# 4 EX_MEM_OUT -> MUL
## Details
- ex_mem_out -> forwarding -> mul -> mul_res -> ex_mem_in

## Fix
- Latch all inputs, just 1 tick delay

# 5 EX_MEM_OUT -> PC_UPDATE
## Details
- ex_mem_out -> forwarding -> alu -> branch -> pc_update and flush 

## Fix
- latch the branch data. No stall used, instead flush one reg deeper in the pipeline, if branch was taken
- Add minor additions like div handling etc, because of the additional flush