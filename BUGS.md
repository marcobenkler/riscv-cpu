# 1 - PC offset after branch
## Details
- After branch pc has offset by N cycles, with N as pipeline stalling duration. Only for 1 cycle then correct branch is taken.

## Reason
 - If the pipe is stalled while a branch is successfull, the branch itself flushes the id_ex_reg -> The branch operation is gone.
   - Through the stall the pc_update is delayed

## Fixing Commit
- a880426

# 2 - Dead Instruction after Jump
## Details
- After a `jar` the instruction coming 3 cycles later was performed before the jump

## Reason
- Missing flushing signal in first pipe_reg

## Fixing Commit
- 96f7aa7

# 3 - Like 2 but deeper
## Details
- Fix 2 only covered the cosim log. The error occured later as an wrong input in the regfile

## Fixing Commit
- eb0caa5

# 4 - Forwarding data deleted
## Details
- When the lsu stalled the pipe, it deleted the mem_wb reg which was used by forwarding partially

## Fix
- Adding buffer, which buffers mem_wb: rdata/rd/reg_write and deciding by, whether it's in stall or not

## Fixing Commit
- 3492bbb

# 5 - Wrong Mem Addr
- The address that was used by the mem file to access the data and write in register was wrong, strobe was wrong as well

## Fix
- Translate from byte -> word addresses by removing the 2 LSB bytes
- Implement the official strobe function from AMD

## Fixing Commit
- 0d77797

# 6 - Wrong SB/SH
## Details
- When using sb or sh the wrong address was used in the word

## Fix
- Add shifting to sb and sh