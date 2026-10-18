# MODULES
## CLINT
| Module | Path | Function |
|---|---|---|
| `clint` | `rtl/external/` | Core-Local Interruptor — `mtime` / `mtimecmp` |

<p><br><br></p>

## UART
| Module | Path | Function |
|---|---|---|
| `uart_top` | `rtl/external/uart/` | UART top — instantiates TX, RX, and baud generators; exposes MMIO interface |
| `uart_tx` | `rtl/external/uart/` | Transmitter FSM (IDLE → START → DATA → STOP) |
| `uart_rx` | `rtl/external/uart/` | Receiver FSM with 16× oversampling for noise rejection |
| `uart_baud` | `rtl/external/uart/` | Baud rate tick generator (115 200 baud TX, 16× for RX) |
