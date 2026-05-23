# RISC-V CPU Core (RV32IM)

## Overview

A clean, modular **pipelined RISC-V CPU** implementing the **RV32IM** instruction set in SystemVerilog.  
The project focuses on architectural correctness and clear RTL structure. Built stage by stage — from a single-cycle baseline to a full 5-stage pipeline with forwarding and hazard detection.

---

## Architecture

![CPU Architecture](architecture.png)

---

## Project Structure

```
.
├── rtl/
│   ├── common/              # Shared packages (ALU opcodes, CLINT, pipeline structs)
│   ├── clint/               # Core-Local Interruptor
│   ├── pipeline/            # Pipeline-specific units
│   │   ├── forwarding_unit.sv
│   │   ├── hazard_unit.sv
│   │   └── pipeline_reg.sv
│   └── core/
│       ├── branch/          # PC selection and update
│       ├── csr/             # Machine-Mode CSR register file & trap logic
│       ├── decode/          # Instruction decoder, immediate generator, register file
│       ├── execute/
│       │   ├── alu/         # ALU (add/sub, logic, shift, compare)
│       │   └── muldiv/      # SRT-2 radix-2 multiplier/divider
│       ├── fetch/           # Instruction memory
│       ├── memory/          # Data memory & bus interconnect
│       ├── writeback/       # Result select mux
│       ├── sc_cpu.sv        # Top-level single-cycle CPU
│       └── operand_select.sv
├── pl_cpu.sv                # Top-level pipelined CPU
├── verify/
│   ├── tb/                  # Testbenches
│   │   ├── alu/
│   │   ├── core/            # Single-cycle CPU testbench
│   │   ├── muldiv/srt2/
│   │   └── pipeline/        # Pipeline integration testbenches
│   ├── assertions/          # SVA assertion modules
│   │   ├── core/decode/     # Decoder / imm_gen assertions
│   │   └── pipeline/        # Forwarding & hazard assertions
│   └── bind/                # Bind files (attach assertions to DUT)
├── sim/                     # Waveform outputs (.vcd / .fst)
├── synth/                   # Yosys synthesis scripts & netlists
├── scripts/                 # Linker script and startup assembly
├── Makefile
└── synth.tcl                # Vivado synthesis script
```

---

## Module Descriptions

### Single-Cycle Core

| Module | Path | Function |
|---|---|---|
| `sc_cpu` | `rtl/core/sc_cpu.sv` | Top-level single-cycle CPU |
| `instruction_memory` | `rtl/core/fetch/` | Instruction ROM, synchronous read |
| `decoder` | `rtl/core/decode/` | Decodes instruction to control signals |
| `imm_gen` | `rtl/core/decode/` | Sign-extends all immediate formats (I/S/B/U/J) |
| `register_file` | `rtl/core/decode/` | 32×32-bit integer register file, x0 hardwired to 0 |
| `operand_select` | `rtl/core/execute/` | Mux for ALU operands A and B |
| `alu_top` | `rtl/core/execute/alu/` | ALU top — dispatches to sub-units |
| `alu_addsub` | `rtl/core/execute/alu/` | Addition and subtraction |
| `alu_logic` | `rtl/core/execute/alu/` | Bitwise AND/OR/XOR |
| `alu_shift` | `rtl/core/execute/alu/` | Logical and arithmetic shifts |
| `alu_compare` | `rtl/core/execute/alu/` | SLT / SLTU comparisons |
| `srt_top` | `rtl/core/execute/muldiv/srt2/` | SRT-2 radix-2 multiply/divide top |
| `normalize` | `rtl/core/execute/muldiv/srt2/` | Operand normalization |
| `LZD` | `rtl/core/execute/muldiv/srt2/` | Leading-zero detector |
| `DigitSelector` | `rtl/core/execute/muldiv/srt2/` | SRT-2 digit selection |
| `RemainderUpdate` | `rtl/core/execute/muldiv/srt2/` | Partial remainder update |
| `next_pc` | `rtl/core/branch/` | Computes next PC (sequential / branch / jump / trap) |
| `update_pc` | `rtl/core/branch/` | PC register |
| `csr_regfile` | `rtl/core/csr/` | Machine-Mode CSR registers and trap handler |
| `data_memory` | `rtl/core/memory/` | Data RAM with byte/half/word access |
| `bus_interconnect` | `rtl/core/memory/` | Memory-mapped I/O bus mux (RAM ↔ CLINT) |
| `result_select` | `rtl/core/writeback/` | Writeback result mux (ALU / memory / PC+4 / CSR) |
| `clint` | `rtl/clint/` | Core-Local Interruptor — `mtime` / `mtimecmp` |

### Pipeline Extensions

| Module | Path | Function |
|---|---|---|
| `pl_cpu` | `rtl/pl_cpu.sv` | Top-level pipelined CPU |
| `pipeline_reg` | `rtl/pipeline/pipeline_reg.sv` | IF/ID, ID/EX, EX/MEM, MEM/WB pipeline registers |
| `forwarding_unit` | `rtl/pipeline/forwarding_unit.sv` | EX/MEM and MEM/WB forwarding to EX stage |
| `hazard_unit` | `rtl/pipeline/hazard_unit.sv` | Load-use stall detection and control-flow flush |

### Packages

| Package | Path | Contents |
|---|---|---|
| `alu_pkg` | `rtl/common/alu_pkg.sv` | ALU opcode enum |
| `clint_pkg` | `rtl/common/clint_pkg.sv` | CLINT MMIO address constants |
| `pipeline_pkg` | `rtl/common/pipeline_pkg.sv` | Pipeline register structs |

---

## Toolchain

| Tool | Purpose |
|---|---|
| [Verilator](https://www.veripool.org/verilator/) | RTL simulation |
| `riscv64-unknown-elf-gcc` | Compile assembly test programs |
| [GTKWave](https://gtkwave.sourceforge.net/) / [Surfer](https://surfer-project.org/) | View `.vcd` / `.fst` waveforms |
| [Yosys](https://yosyshq.net/yosys/) | Open-source synthesis |
| Vivado | FPGA synthesis (`synth.tcl`) |

---

## How to Run

### Prerequisites

```bash
# macOS (Homebrew)
brew install verilator riscv-gnu-toolchain

# 64-bit toolchain supports RV32 via `-march=rv32i -mabi=ilp32`
```

### Simulate

```bash
make sim          # single-cycle CPU
make sim-pl       # pipelined CPU
```

### View waveforms

```bash
surfer sim/pip_cpu.fst
```

---

## Testing & Verification

### Testbenches

| Testbench | Path | Covers |
|---|---|---|
| `tb_sc_cpu` | `verify/tb/core/` | Full single-cycle CPU |
| `tb_pl_cpu` | `verify/tb/pipeline/` | Full pipelined CPU |
| `tb_fwd_integration` | `verify/tb/pipeline/` | Forwarding unit integration |
| `tb_hazard_integration` | `verify/tb/pipeline/` | Hazard unit integration |
| `tb_alu` | `verify/tb/alu/` | ALU top-level |
| `tb_STR2` | `verify/tb/muldiv/srt2/` | SRT-2 divider end-to-end |
| `tb_LZD` | `verify/tb/muldiv/srt2/` | Leading-zero detector |
| `tb_normalize` | `verify/tb/muldiv/srt2/` | Operand normalizer |
| `tb_DigitSelector` | `verify/tb/muldiv/srt2/` | Digit selector |
| `tb_RemainderUpdate` | `verify/tb/muldiv/srt2/` | Remainder update |

### SVA (SystemVerilog Assertions)

Formal/simulation assertions are in `verify/assertions/` and attached to the DUT via bind files in `verify/bind/`.

| Assertion Module | Bind File | Covers |
|---|---|---|
| `assert_fwd_integration` | `fwd_bind.sv` | Forwarding correctness — correct data selected for EX operands under all hazard combinations |
| `assert_hazard_integration` | `hazard_bind.sv` | Hazard detection — stall and flush signals asserted at the right cycles for load-use and control hazards |
| `assert_imm_gen` | *(core/decode)* | Immediate sign-extension for all formats |

---

## Implementation Status

| Feature | Status |
|---|---|
| RV32I base instruction set | ✅ |
| RV32M multiply/divide (SRT-2) | ✅ |
| Machine-Mode CSRs (`mstatus`, `mepc`, `mcause`, …) | ✅ |
| Trap/exception handling (M-mode) | ✅ |
| CLINT (`mtime` / `mtimecmp`) | ✅ |
| Memory-mapped I/O bus | ✅ |
| Timer interrupts | ✅ |
| 5-stage pipeline (forwarding, hazard detection) | ✅ |
| SVA assertion coverage | ✅ |
| FreeRTOS bring-up | ⬜ |
| FreeRTOS on FPGA | ⬜ |

---

## Design Philosophy

Architecture-first: correctness, clarity, and extensibility take priority over microarchitectural optimizations. The single-cycle implementation provides a clean, debuggable baseline; the pipelined design builds directly on that structure with minimal added complexity.
