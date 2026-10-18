# OVERVIEW

<p align="center">
    <img src="../../../images/svg/mem_stage.svg" alt="MEM STAGE WITH AXI INTERCONNECT">
    <br>
    <br>
    <br>
</p>
  
| AREA   | BASE          | END           | SIZE   |  
|--------|---------------|---------------|--------|  
| MEM    | `0x8000_0000` | `0x8000_7FFF` | 32 KiB |  
| UART   | `0x1000_0000` | `0x1000_000B` | 12 B   |  
| CLINT  | `0x0200_0000` | `0x0200_BFFF` | 48 KiB |   

<p><br><br></p>  


# COMPONENTS
## LSU

### BUS INTERFACE
AXI4-LITE, see [AMBA AXI Specification](https://developer.arm.com/documentation/ihi0022/latest).

| Parameter          | Value                                  |
|--------------------|----------------------------------------|
| Address width      | 32 bit                                 |
| Data width         | 32 bit                                 |
| Outstanding        | 1 transaction (blocking)               |
| Write strobes      | Used for SB / SH                       |
| Error response     | SLVERR / DECERR raise access fault     |

While a transaction is pending (no R / B response yet), the LSU requests a
stall from the hazard unit, so the pipeline waits until the response arrives.

### DATA ALIGNMENT
The LSU shifts store data to the addressed byte lane and sets the matching
write strobes. On loads it extracts the addressed byte / halfword from the
32-bit read data and performs the sign or zero extension.

### Supported Instructions
| Instruction | Width   | Extension | Alignment     |
|-------------|---------|-----------|---------------|
| LB / LBU    | 8 bit   | sign/zero | any           |
| LH / LHU    | 16 bit  | sign/zero | 2-byte        |
| LW          | 32 bit  | -         | 4-byte        |
| SB          | 8 bit   | -         | any           |
| SH          | 16 bit  | -         | 2-byte        |
| SW          | 32 bit  | -         | 4-byte        |

### CSR CONTROL
| Direction  | Signal                  | Meaning                                         |
|------------|-------------------------|-------------------------------------------------|
| LSU → CSR  | Access fault            | SLVERR / DECERR received, raise mcause 5 / 7    |

<p><br><br></p>  

## AXI INTERCONNECT
1 manager (LSU), 3 subordinates (MEM, UART, CLINT).

| Parameter       | Value                                          |
|-----------------|------------------------------------------------|
| Address decode  | Base / end per subordinate, see memory map     |
| Unmapped access | DECERR                                         |
| Latency         | Combinational, no additional cycles            |

<p><br><br></p>  

## MEM
| Parameter     | Value                                 |
|---------------|---------------------------------------|
| Type          | Block RAM                             |
| Size          | 32 KiB (`MEM_DEPTH` = 8192 words)     |
| Write strobes | Used directly as byte enables         |
| Latency       | 1 cycle (synchronous BRAM access)     |

<p><br><br></p>  

## UART
115200 baud, 8N1, RX with 16× oversampling.

| KIND   | Offset        | ACCESS | DESCRIPTION            |
|--------|---------------|--------|------------------------|
| TX     | `0x0000_0000` | W      | Data to send           |
| STATUS | `0x0000_0004` | R      | Status of transmission |
| RX     | `0x0000_0008` | R      | Received data          |  

### STATUS
| Bit    | Name       | DESCRIPTION                   |
|--------|------------|-------------------------------|
| 0      | `tx_ready` | Transmitter can accept data   |
| 1      | `rx_valid` | Received data is valid        |
| 31:2   | -          | Reserved, read as 0           |

<p><br><br></p>  

## CLINT
`mtime` increments every CPU clock cycle, no prescaler.
The timer interrupt is pending while `mtime >= mtimecmp`.
MSIP is a plain register and does not trigger a software interrupt.

| KIND        | Offset        | DESCRIPTION                                      |
|-------------|---------------|--------------------------------------------------|
| MSIP        | `0x0000_0000` | Flag for software interrupt                      |
| MTIMECMP_LO | `0x0000_4000` | Lower part of compare value for timer interrupt  |
| MTIMECMP_HI | `0x0000_4004` | Higher part of compare value for timer interrupt |
| MTIME_LO    | `0x0000_BFF8` | Lower part of free-running clock                 |
| MTIME_HI    | `0x0000_BFFC` | Higher part of free-running clock                |

<p><br><br></p>  

## CSR

### EXCEPTIONS

| mcause | Cause                    | mtval          |
|--------|--------------------------|--------------- |
| 0      | Instruction misaligned   | Fault address  |
| 2      | Illegal Instruction      | Instruction    |
| 3      | Breakpoint               | 0              |
| 4      | Load address misaligned  | Fault address  |
| 5      | Load access fault        | Fault address  |
| 6      | Store address misaligned | Fault address  |
| 7      | Store access fault       | Fault address  |
| 11     | Environment call         | 0              |

Priority (highest first): instruction misaligned > illegal instruction >
load / store misaligned > load / store access fault > ecall / ebreak.

### INTERRUPTS

| mcause        | Cause                  | mepc                         |
|---------------|------------------------|------------------------------|
| `0x8000_0007` | Machine timer (CLINT)  | PC of next instruction (IF)  |

Taken when `mstatus.MIE && mie.MTIE && mip.MTIP`.

### TRAP ENTRY / MRET
On trap:
1. mepc   ← PC of trapping instruction
2. mcause ← cause
3. mtval  ← see table
4. MPIE   ← MIE, MIE ← 0
5. MPP    ← 11
6. PC     ← mtvec

On mret: MIE ← MPIE, MPIE ← 1, MPP ← 11, PC ← mepc

<p><br><br></p>

# MODULES
| Module | Path | Function |
|---|---|---|
| `csr_regfile` | `rtl/core/memory/` | Machine-Mode CSR registers and trap handler |
| `data_memory` | `rtl/core/memory/` | Data RAM with byte/half/word access |
| `bus_interconnect` | `rtl/core/memory/` | Memory-mapped I/O bus mux (RAM ↔ CLINT ↔ UART) |
