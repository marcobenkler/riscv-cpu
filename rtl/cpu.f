// Packages first, every module below may import them
rtl/common/alu_pkg.sv
rtl/common/clint_pkg.sv
rtl/common/uart_pkg.sv
rtl/common/pipeline_pkg.sv

// Pipeline infrastructure
rtl/pipeline/pipeline_reg.sv
rtl/pipeline/forwarding_unit.sv
rtl/pipeline/hazard_unit.sv

// IF
rtl/core/fetch/update_pc.sv
rtl/core/fetch/next_pc.sv
rtl/core/fetch/instruction_memory.sv

// ID
rtl/core/decode/decoder.sv
rtl/core/decode/imm_gen.sv
rtl/core/decode/register_file.sv

// EX
rtl/core/execute/operand_select.sv
rtl/core/execute/branch_unit.sv
rtl/core/execute/misaligned_detection.sv
rtl/core/execute/alu/alu_addsub.sv
rtl/core/execute/alu/alu_compare.sv
rtl/core/execute/alu/alu_logic.sv
rtl/core/execute/alu/alu_shift.sv
rtl/core/execute/alu/alu_top.sv
rtl/core/execute/muldiv/multiply.sv
rtl/core/execute/muldiv/srt2/LZD.sv
rtl/core/execute/muldiv/srt2/normalize.sv
rtl/core/execute/muldiv/srt2/DigitSelector.sv
rtl/core/execute/muldiv/srt2/RemainderUpdate.sv
rtl/core/execute/muldiv/srt2/srt_top.sv

// MEM
rtl/core/memory/bus_interconnect.sv
rtl/core/memory/csr_regfile.sv
rtl/core/memory/data_memory.sv

// WB
rtl/core/writeback/result_select.sv

// Peripherals
rtl/external/clint.sv
rtl/external/uart/uart_baud.sv
rtl/external/uart/uart_tx.sv
rtl/external/uart/uart_rx.sv
rtl/external/uart/uart_top.sv

// Top
rtl/pl_cpu.sv
