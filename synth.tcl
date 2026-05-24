# =============================================================================
# RISC-V CPU — Vivado Synthesis (No Place & Route, No Bitstream)
# Target: Zynq-7010 (xc7z010clg400-1)
# Usage:  vivado -mode batch -source synth.tcl -log synth.log -journal synth.jou
# =============================================================================

set project_dir /opt/projects/riscv-cpu
set top_module  pl_cpu
set part        xc7z010clg400-1
set output_dir  ${project_dir}/output

file mkdir ${output_dir}

read_verilog -sv [list \
    ${project_dir}/rtl/common/alu_pkg.sv \
    ${project_dir}/rtl/common/clint_pkg.sv \
    ${project_dir}/rtl/common/pipeline_pkg.sv \
    ${project_dir}/rtl/common/uart_pkg.sv \
    ${project_dir}/rtl/core/branch/next_pc.sv \
    ${project_dir}/rtl/core/branch/update_pc.sv \
    ${project_dir}/rtl/core/csr/csr_regfile.sv \
    ${project_dir}/rtl/core/decode/decoder.sv \
    ${project_dir}/rtl/core/decode/imm_gen.sv \
    ${project_dir}/rtl/core/decode/register_file.sv \
    ${project_dir}/rtl/core/execute/alu/alu_addsub.sv \
    ${project_dir}/rtl/core/execute/alu/alu_compare.sv \
    ${project_dir}/rtl/core/execute/alu/alu_logic.sv \
    ${project_dir}/rtl/core/execute/alu/alu_shift.sv \
    ${project_dir}/rtl/core/execute/alu/alu_top.sv \
    ${project_dir}/rtl/core/execute/branch_unit.sv \
    ${project_dir}/rtl/core/execute/misaligned_detection.sv \
    ${project_dir}/rtl/core/execute/muldiv/multiply.sv \
    ${project_dir}/rtl/core/execute/muldiv/srt2/DigitSelector.sv \
    ${project_dir}/rtl/core/execute/muldiv/srt2/LZD.sv \
    ${project_dir}/rtl/core/execute/muldiv/srt2/RemainderUpdate.sv \
    ${project_dir}/rtl/core/execute/muldiv/srt2/normalize.sv \
    ${project_dir}/rtl/core/execute/muldiv/srt2/srt_top.sv \
    ${project_dir}/rtl/core/execute/operand_select.sv \
    ${project_dir}/rtl/core/fetch/instruction_memory.sv \
    ${project_dir}/rtl/core/memory/bus_interconnect.sv \
    ${project_dir}/rtl/core/memory/data_memory.sv \
    ${project_dir}/rtl/core/writeback/result_select.sv \
    ${project_dir}/rtl/external/clint.sv \
    ${project_dir}/rtl/external/uart/uart_baud.sv \
    ${project_dir}/rtl/external/uart/uart_rx.sv \
    ${project_dir}/rtl/external/uart/uart_top.sv \
    ${project_dir}/rtl/external/uart/uart_tx.sv \
    ${project_dir}/rtl/pipeline/forwarding_unit.sv \
    ${project_dir}/rtl/pipeline/hazard_unit.sv \
    ${project_dir}/rtl/pipeline/pipeline_reg.sv \
    ${project_dir}/rtl/pl_cpu.sv \
]

synth_design -top ${top_module} -part ${part} -flatten_hierarchy rebuilt -generic MEM_DEPTH=15

report_utilization -file ${output_dir}/utilization.rpt

puts "============================================"
puts " Synthesis complete! Reports in: ${output_dir}/"
puts "============================================"
