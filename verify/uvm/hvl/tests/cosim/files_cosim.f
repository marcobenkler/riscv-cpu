// UVM
/Users/marcobenkler/Dev/UVM/uvm-core-2020/src/uvm_pkg.sv

// Verilator
verilator.vlt

// DEPS
+incdir+verify/uvm/hvl/agents/cosim/retire
+incdir+verify/uvm/hvl/envs/cosim_env
+incdir+verify/uvm/hvl/tests/cosim
+incdir+verify/utils

-f rtl/cpu.f

// PKG
verify/uvm/hvl/agents/cosim/retire/retire_agent_pkg.sv
verify/uvm/hvl/envs/cosim_env/cosim_env_pkg.sv
verify/uvm/hvl/tests/cosim/cosim_test_pkg.sv

// Top
verify/tb/tb_cosim.sv

// HDL
verify/uvm/hdl/bfm/retire_if.sv
verify/uvm/hdl/top/cosim_hdl_top.sv

// HVL
verify/uvm/hvl/top/cosim_hvl_top.sv