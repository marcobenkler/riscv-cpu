# =============================================================================
# RISC-V CPU — Vivado Project synth (Synth + Impl + Bitstream)
# Target: Zybo Z7-10 (xc7z010clg400-1)
#
# Location: <repo>/synth/synth.tcl
# Usage:  vivado -mode batch -source synth/synth.tcl                 (full synth)
#         vivado -mode batch -source synth/synth.tcl -tclargs setup  (project only)
# Then:   open synth/vivado/riscv_cpu.xpr in the Vivado GUI
#
# Expects imem.hex and dmem.hex in the repo root (empty placeholders are
# created if they are missing).
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

# HEX files for BRAM initialization ($readmemh), Harvard: instruction + data memory.
# If a file does not exist yet, an empty placeholder is created so the project
# can be set up now. Generate the real files later at the same path; Vivado
# picks up the new contents on the next synthesis run.
foreach hex {imem.hex dmem.hex} {
    set hex_path ${project_dir}/${hex}
    if {![file exists ${hex_path}]} {
        puts "WARNING: ${hex_path} not found – creating empty placeholder (memory will be zero)."
        close [open ${hex_path} w]
    }
    add_files -norecurse -fileset sources_1 ${hex_path}
    set_property file_type {Memory File} [get_files ${hex}]
}

# Constraints
add_files -norecurse -fileset constrs_1 ${project_dir}/synth/Zybo-Z7-Master.xdc

set_property top          ${top_module}        [get_filesets sources_1]
set_property include_dirs [list ${project_dir}] [get_filesets sources_1]
update_compile_order -fileset sources_1

# =============================================================================
# Run Settings (match the previous non-project script)
# =============================================================================
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY rebuilt [get_runs synth_1]
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED          true    [get_runs impl_1]

# "setup" mode: only create the project, skip synthesis/implementation
if {[lsearch -exact ${argv} setup] >= 0} {
    puts "============================================"
    puts " PROJECT CREATED (setup only, no synth)"
    puts " GUI: ${proj_dir}/${proj_name}.xpr"
    puts "============================================"
    close_project
    return
}

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
puts " synth DONE: ${output_dir}/pl_cpu.bit"
puts " WNS: ${wns} ns"
if {${wns} < 0} {
    puts " WARNING: Timing not met (negative WNS)!"
}
puts " GUI: ${proj_dir}/${proj_name}.xpr"
puts "============================================"