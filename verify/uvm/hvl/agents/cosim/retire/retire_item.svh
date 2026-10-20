class retire_item extends uvm_sequencer_item;
    bit        valid;
    bit [31:0] pc;
    bit [31:0] instr;
    bit [31:0] rd_addr;
    bit [31:0] rd_data;
    bit [31:0] mem_addr;
    bit [31:0] mem_wdata;
    bit [31:0] mem_wmask;
    bit [31:0] mem_rmask;
    bit [31:0] mem_rdata;
    // bit [63:0] counter;
    bit [31:0] rs1_addr;
    bit [31:0] rs2_addr;
    bit [31:0] rs1_data;
    bit [31:0] rs2_data;

    `uvm_object_utils_begin(retire_item)
    `uvm_field_int()
    `uvm_object_utils_end
    `uvm_object_new


endclass
