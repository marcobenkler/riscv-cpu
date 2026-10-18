# RISC-V CPU Core (RV32IM)

## Use of AI  
This project was written entirely by me. AI did not write a single line in this project.  
I use it as a tool to understand concepts and help with debugging if I struggel for more than 1h. 

## Overview

A clean, modular **pipelined RISC-V CPU** implementing the **RV32IM** instruction set in SystemVerilog.  

---

## Design 

### Architecture

![CPU Architecture](images/svg/pipe_architecture.svg)  
Left out trivial connections, i.e. instruction_memory -> decoder for improved overview  


---

## Module Descriptions

### Top Level

| Module | Path | Function |
|---|---|---|
| `sc_cpu` | `rtl/core/sc_cpu.sv` | Top-level single-cycle CPU |
| `pl_cpu` | `rtl/pl_cpu.sv` | Top-level pipelined CPU (FPGA top, exposes UART pins) |

### Writeback

| Module | Path | Function |
|---|---|---|
| `result_select` | `rtl/core/writeback/` | Writeback result mux (ALU / memory / PC+4 / CSR) |

### CLINT

| Module | Path | Function |
|---|---|---|
| `clint` | `rtl/external/` | Core-Local Interruptor — `mtime` / `mtimecmp` |

### UART Peripheral

| Module | Path | Function |
|---|---|---|
| `uart_top` | `rtl/external/uart/` | UART top — instantiates TX, RX, and baud generators; exposes MMIO interface |
| `uart_tx` | `rtl/external/uart/` | Transmitter FSM (IDLE → START → DATA → STOP) |
| `uart_rx` | `rtl/external/uart/` | Receiver FSM with 16× oversampling for noise rejection |
| `uart_baud` | `rtl/external/uart/` | Baud rate tick generator (115 200 baud TX, 16× for RX) |

UART MMIO map (base `0x1000_0000`):

| Offset | Register | Description |
|---|---|---|
| `+0x00` | `UART_TX` | Write byte to transmit |
| `+0x04` | `UART_STATUS` | `[1]` rx_valid, `[0]` tx_ready |
| `+0x08` | `UART_RX` | Last received byte |

### Packages

| Package | Path | Contents |
|---|---|---|
| `alu_pkg` | `rtl/common/alu_pkg.sv` | ALU opcode enum |
| `clint_pkg` | `rtl/common/clint_pkg.sv` | CLINT MMIO address constants |
| `uart_pkg` | `rtl/common/uart_pkg.sv` | UART MMIO address constants and state enum |
| `pipeline_pkg` | `rtl/common/pipeline_pkg.sv` | Pipeline register structs |

---

## Toolchain

| Tool | Purpose |
|---|---|
| [Verilator](https://www.veripool.org/verilator/) | RTL simulation, capable of useful UVM since v.5050 |
| `riscv64-unknown-elf-gcc` | Compile assembly test programs |
| [Surfer](https://surfer-project.org/) | View `.vcd` / `.fst` waveforms |
| Vivado | FPGA synthesis, implementation and STA |

---

### FPGA (Zybo Z7)

Synthesize and implement with Vivado using `synth.tcl` and `Zybo-Z7-Master.xdc`.  
After programming the bitstream, connect via a serial terminal at **115 200 baud** to interact with the running CPU over UART.

---

## Implementation Status

| Feature | Status |
|---|---|
| RV32I base instruction set | ✅ |
| RV32M multiply/divide | ✅ |
| Machine-Mode CSRs (`mstatus`, `mepc`, `mcause`, …) | ✅ |
| Trap/exception handling (M-mode) | ✅ |
| Misaligned load/store/fetch exceptions | ✅ |
| CLINT (`mtime` / `mtimecmp`) | ✅ |
| Memory-mapped I/O bus | ✅ |
| Timer interrupts | ✅ |
| 6-stage pipeline (forwarding, hazard detection) | ✅ |
| UART peripheral (115 200 baud, TX + RX) | ✅ |
| SVA assertion coverage | ✅ |
| RISC-V ISA test suite (rv32ui / rv32um / rv32mi) | ✅ |
| Bare-Metal on FPGA with UART | ✅ |
| FreeRTOS bring-up | ⬜ |
| FreeRTOS on FPGA | ⬜ |

---

## Timing

Clock: 90 MHz (11.1 ns period)  
WNS: +0.361 ns, 0 timing violations  
