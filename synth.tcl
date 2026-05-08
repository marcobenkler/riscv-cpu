# =============================================================================
# RISC-V CPU — Vivado Synthesis (No Place & Route, No Bitstream)
# Target: Zynq-7010 (xc7z010clg400-1)
# Usage:  vivado -mode batch -source synth.tcl -log synth.log -journal synth.jou
# =============================================================================

set project_dir /opt/projects/riscv-cpu
set top_module  sc_cpu
set part        xc7z010clg400-1
set output_dir  ${project_dir}/output

# Create output directory
file mkdir ${output_dir}

# --- Read ALL files in a single call (shared compilation unit) ---
# Packages MUST come first in the list
read_verilog -sv [list \
    ${project_dir}/rtl/common/alu_pkg.sv \
    ${project_dir}/rtl/common/clint_pkg.sv \
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
    ${project_dir}/rtl/core/execute/operand_select.sv \
    ${project_dir}/rtl/core/fetch/instruction_memory.sv \
    ${project_dir}/rtl/core/memory/data_memory.sv \
    ${project_dir}/rtl/core/writeback/result_select.sv \
    ${project_dir}/rtl/core/sc_cpu.sv \
]

# --- Synthesize ---
synth_design -top ${top_module} -part ${part} -flatten_hierarchy rebuilt \
    #Override variable
    -generic MEM_DEPTH=15

# --- Reports ---
report_utilization -file ${output_dir}/utilization.rpt
#report_timing_summary -file ${output_dir}/timing_summary.rpt consumes too much RAM
report_hierarchy -file ${output_dir}/hierarchy.rpt

puts "============================================"
puts " Synthesis complete!"
puts " Reports in: ${output_dir}/"
puts "============================================"