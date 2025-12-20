# RISC-V CPU Core (RV32I)

## Overview

This repository contains the development of a **clean, modular RISC-V CPU core** implementing the **RV32IM base instruction set**.  
The project focuses on **architectural correctness**, **clear RTL structure**, and **ISA-conform behavior**, rather than maximum performance.

---

## Goals

- Correct implementation of the RISC-V **RV32IM ISA**
- Strict separation of fetch, decode, execute, memory, and writeback stages
- Modular RTL design suitable for incremental extension
- Clear, readable hardware structure aligned with professional design practices

---

## Design Philosophy

This is an **architecture-first project**.  
Correctness, clarity, and extensibility take priority over microarchitectural optimizations.

---

## Status

The core is under active development and serves as a foundation for future extensions such as pipelining, interrupts, and additional ISA features.