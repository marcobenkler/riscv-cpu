`ifndef DV_MACROS
`define DV_MACROS

`define uvm_component_new \
  function new(string name, uvm_component parent); \
    super.new(name, parent); \
  endfunction : new

`define uvm_object_new \
  function new(string name = ""); \
    super.new(name); \
  endfunction : new

`define gfn get_full_name()

`endif
