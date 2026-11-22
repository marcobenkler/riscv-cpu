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

## Commit
- ed16b8b

# 7 - Wrong SPIKE Flag | Wrong Trace assumtion
## Details
- Spike log was not set to m mode only. It changed mode and returned supervisor as current mode in csr
- Assumed csr_data was the input value into the csr_module. It is the register value, the cpu is writing to

## Fix
- Add `--priv=m` flag to spike call.
- Added register as csr_module output and wired rvfi to it

## Commit
- d019e11

# 8 - Wronge compare in trace
## Details
- Spike writs out mem_data as `0x00` if it's a `sb` and `0x0000` if it's a `sh`. I assuemd it was `0x00000000` all the time

## Fix
- In `spike-log` -> `jsonl` script the data is filled up at the MSB with 0, if the data is shortend

## Commit
- f5cbc3d

# 9 - Spike log missasumtion
## Details
- Spike does not log the csr_register when nothing is written. I assuemd it logs the accessed register, wheter written or read

## Fix
- Remove the logging of the rtl part, if nothing is written

## Commit
- a648d08

# 10 - Wrong data in mem_wdata
## Details
- Data was wrong in the mem_wdata at the mem, caused by still using the unbuffered result signal

## Fix
- Use the buffered one from Fix 4

## Commit
- e2a95b0

# 11 - Wrong mem_wdata
## Details
- mem_wdata was originally extended with 0 prefix as fix for bug 6. If mem_wdata was not 0 it compared spikes 0 prefix with the full 32 bit r2_data vecotr

## Fix
- Remove prefix in spike log, remove the first bits in the rtl log

## Commit
- 996e87b

# 12 - DIV error
## Details
- Div did not work, if dividend was 0. Caused by missing rs2_latch assignment

## Fix
- Latch rs2, if rs2_data == 0

## Commit
- 