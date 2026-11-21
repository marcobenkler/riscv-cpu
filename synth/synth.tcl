# =============================================================================
# RISC-V CPU — Vivado Project Build (Synth + Impl + Bitstream)
# Target: Zybo Z7-10 (xc7z010clg400-1)
#
# Location: <repo>/synth/build.tcl
# Usage:  vivado -mode batch -source synth/synth.tcl
# Then:   open synth/vivado/riscv_cpu.xpr in the Vivado GUI
#
# The project in vivado/ is recreated on every run (-force).
# Permanent changes (new files, settings) belong in this script.
# =============================================================================

# This script lives in <repo>/synth/, so the repo root is one level up
# (works on Windows and Linux, independent of the current working directory)
set script_dir  [file normalize [file dirname [info script]]]
set project_dir [file dirname ${script_dir}]
set proj_name   riscv_cpu
set proj_dir    ${script_dir}/vivado
set output_dir  ${project_dir}/output
set top_module  pl_cpu
set part        xc7z010clg400-1
set jobs        8

file mkdir ${output_dir}

# =============================================================================
# Create Project
# =============================================================================
create_project ${proj_name} ${proj_dir} -part ${part} -force

# =============================================================================
# Sources (referenced, not copied)
# =============================================================================
set rtl ${project_dir}/rtl

set sources [list \
    ${rtl}/common/alu_pkg.sv \
    ${rtl}/common/clint_pkg.sv \
    ${rtl}/common/pipeline_pkg.sv \
    ${rtl}/common/uart_pkg.sv \
    ${rtl}/core/fetch/next_pc.sv \
    ${rtl}/core/fetch/update_pc.sv \
    ${rtl}/core/fetch/instruction_memory.sv \
    ${rtl}/core/decode/decoder.sv \
    ${rtl}/core/decode/imm_gen.sv \
    ${rtl}/core/decode/register_file.sv \
    ${rtl}/core/execute/alu/alu_addsub.sv \
    ${rtl}/core/execute/alu/alu_compare.sv \
    ${rtl}/core/execute/alu/alu_logic.sv \
    ${rtl}/core/execute/alu/alu_shift.sv \
    ${rtl}/core/execute/alu/alu_top.sv \
    ${rtl}/core/execute/branch_unit.sv \
    ${rtl}/core/execute/misaligned_detection.sv \
    ${rtl}/core/execute/operand_select.sv \
    ${rtl}/core/execute/muldiv/multiply.sv \
    ${rtl}/core/execute/muldiv/srt2/DigitSelector.sv \
    ${rtl}/core/execute/muldiv/srt2/LZD.sv \
    ${rtl}/core/execute/muldiv/srt2/RemainderUpdate.sv \
    ${rtl}/core/execute/muldiv/srt2/normalize.sv \
    ${rtl}/core/execute/muldiv/srt2/srt_top.sv \
    ${rtl}/core/memory/csr_regfile.sv \
    ${rtl}/core/memory/axi_interconnect.sv \
    ${rtl}/core/memory/lsu.sv \
    ${rtl}/core/memory/mem.sv \
    ${rtl}/core/writeback/result_select.sv \
    ${rtl}/external/clint.sv \
    ${rtl}/external/uart/uart_baud.sv \
    ${rtl}/external/uart/uart_rx.sv \
    ${rtl}/external/uart/uart_top.sv \
    ${rtl}/external/uart/uart_tx.sv \
    ${rtl}/pipeline/forwarding_unit.sv \
    ${rtl}/pipeline/hazard_unit.sv \
    ${rtl}/pipeline/pipeline_reg.sv \
    ${rtl}/pl_cpu.sv \
]

# No longer used (add to the list above if needed):
#   ${rtl}/core/memory/bus_interconnect.sv
#   ${rtl}/core/memory/data_memory.sv

add_files -norecurse -fileset sources_1 ${sources}

# HEX file for BRAM initialization ($readmemh)
add_files -norecurse -fileset sources_1 ${project_dir}/program.hex
set_property file_type {Memory File} [get_files program.hex]

# Constraints
add_files -norecurse -fileset constrs_1 ${project_dir}/Zybo-Z7-Master.xdc

set_property top          ${top_module}        [get_filesets sources_1]
set_property include_dirs [list ${project_dir}] [get_filesets sources_1]
update_compile_order -fileset sources_1

# =============================================================================
# Run Settings (match the previous non-project script)
# =============================================================================
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY rebuilt [get_runs synth_1]
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED          true    [get_runs impl_1]

# =============================================================================
# Synthesis
# =============================================================================
puts "============================================"
puts " Starting Synthesis..."
puts "============================================"

launch_runs synth_1 -jobs ${jobs}
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    error "Synthesis failed – see ${proj_dir}/${proj_name}.runs/synth_1/runme.log"
}

# =============================================================================
# Implementation + Bitstream
# =============================================================================
puts "============================================"
puts " Starting Implementation + Bitstream..."
puts "============================================"

launch_runs impl_1 -to_step write_bitstream -jobs ${jobs}
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {
    error "Implementation failed – see ${proj_dir}/${proj_name}.runs/impl_1/runme.log"
}

# =============================================================================
# Reports + copy bitstream to output/
# =============================================================================
open_run impl_1
report_timing_summary            -file ${output_dir}/timing.rpt
report_utilization               -file ${output_dir}/utilization.rpt
report_utilization -hierarchical -file ${output_dir}/utilization_hier.rpt
report_power                     -file ${output_dir}/power.rpt

set impl_dir [get_property DIRECTORY [get_runs impl_1]]
file copy -force ${impl_dir}/${top_module}.bit ${output_dir}/pl_cpu.bit

set wns [get_property STATS.WNS [get_runs impl_1]]
puts "============================================"
puts " BUILD DONE: ${output_dir}/pl_cpu.bit"
puts " WNS: ${wns} ns"
if {${wns} < 0} {
    puts " WARNING: Timing not met (negative WNS)!"
}
puts " GUI: ${proj_dir}/${proj_name}.xpr"
puts "============================================"