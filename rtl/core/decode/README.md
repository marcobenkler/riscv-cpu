# OVERVIEW  
<p align="center">
    <img src="../../../images/svg/id_stage.svg" alt="DECODE DIAGRAM">
    <br>
    <br>
    <br>
</p>


`WRITE_DATA` (`result`) and `WRITE_INFO` (`rd`, `reg_write`) come from the WB stage.

<p><br><br></p>

# COMPONENTS
## REGISTER
| Parameter  | Value                                               |
|------------|-----------------------------------------------------|
| Size       | 32 × 32 bit                                         |
| Read       | Combinational                                       |
| Write      | Rising clock edge                                   |
| `x0`       | Hardwired to 0, writes to `rd = 0` are ignored      |
| Reset      | Asynchronous, all registers set to 0                |

### WRITE-THROUGH
If WB writes to `rs1` / `rs2` in the same cycle, `result` is forwarded directly
to `rs1_data` / `rs2_data`. Therefore the forwarding unit needs no third path
for the WB stage.

<p><br><br></p>

## DECODER
Supports RV32IM. Only opcode bits `[6:2]` are decoded, bits `[1:0]` are not checked.

### CONTROL SIGNALS
| Signal      | Value | Meaning                 |
|-------------|-------|-------------------------|
| `pc_src`    | `00`  | PC + 4                  |
|             | `01`  | PC + imm (branch, JAL)  |
|             | `10`  | rs1 + imm (JALR)        |
| `res_src`   | `000` | ALU / EX result         |
|             | `001` | MEM                     |
|             | `010` | imm                     |
|             | `011` | PC + 4                  |
|             | `100` | CSR                     |
| `ex_src`    | `00`  | ALU                     |
|             | `01`  | MUL                     |
|             | `10`  | DIV                     |
| `alu_src_a` | `1`   | PC instead of rs1       |
| `alu_src_b` | `1`   | imm instead of rs2      |

### SPECIALTIES
- LUI bypasses the ALU via `res_src = imm`
- `mem_s_type` and `csr_op` are passed through directly as `funct3`, `csr_op[2]` selects the immediate variant
- Branches set `alu_op` to SUB / SLT / SLTU, see [ALU flags](../execute/README.md#flags)
- FENCE / FENCE.I are treated as NOP

### EXCEPTIONS
| Signal             | Triggered when                                                   |
|--------------------|------------------------------------------------------------------|
| `id_illegal_instr` | Unknown opcode                                                   |
|                    | SLLI with `imm[5] = 1`                                           |
|                    | SRLI / SRAI with invalid `funct7`                                |
| `id_ecall`         | SYSTEM, `funct3 = 000`, bit 20 = 0                               |
| `id_ebreak`        | SYSTEM, `funct3 = 000`, bit 20 = 1                               |
| `id_mret`          | Instruction equals `0x30200073`                                  |
| -                  | SYSTEM, `funct3 = 000`, bit 29 = 1 and no MRET (e.g. WFI) is NOP|

<p><br><br></p>

## IMM_GEN
Selects the immediate format based on the opcode and sign extends it.
For U-Type `imm` is already shifted left by 12, for B- and J-Type the LSB is 0.
