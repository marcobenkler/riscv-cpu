# TOP LEVEL
| Module | Path | Function |
|---|---|---|
| `sc_cpu` | `rtl/core/sc_cpu.sv` | Top-level single-cycle CPU |
| `pl_cpu` | `rtl/pl_cpu.sv` | Top-level pipelined CPU (FPGA top, exposes UART pins) |

<p><br><br></p>

# PACKAGES
| Package | Path | Contents |
|---|---|---|
| `alu_pkg` | `rtl/common/alu_pkg.sv` | ALU opcode enum |
| `clint_pkg` | `rtl/common/clint_pkg.sv` | CLINT MMIO address constants |
| `uart_pkg` | `rtl/common/uart_pkg.sv` | UART MMIO address constants and state enum |
| `pipeline_pkg` | `rtl/common/pipeline_pkg.sv` | Pipeline register structs |
