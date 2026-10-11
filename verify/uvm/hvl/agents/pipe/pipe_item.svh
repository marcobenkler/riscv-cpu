class pipe_item extends uvm_sequence_item;
    // DATA
    rand bit          is_store;
    rand bit [31:0]   addr;
    rand bit [31:0]   store_data;
    rand mem_type_e   mem_type;
    rand bit          stall_do;
    rand bit          flush_do;
    bit      [31:0]   load_data;
    lsu_excep_e       lsu_exception;
    bit      [2:0]    mcause;
    bit      [31:0]   mtval;

    // TIMING
    rand int unsigned      stall_at;
    rand int unsigned      stall_duration;
    rand int unsigned      flush_at;
    rand int unsigned      req_vld_at;
         int unsigned      out_vld_at;
         int unsigned      lsu_stall_at;
         int unsigned      lsu_stall_duration;

    `uvm_object_utils_begin(pipe_item)
    `uvm_field_int(is_store, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(store_data, UVM_ALL_ON)
    `uvm_field_enum(mem_type_e, mem_type, UVM_ALL_ON)
    `uvm_field_int(stall_do, UVM_ALL_ON)
    `uvm_field_int(stall_at, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(stall_duration, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(flush_do, UVM_ALL_ON)
    `uvm_field_int(flush_at, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(load_data, UVM_ALL_ON)
    `uvm_field_int(out_vld_at, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(lsu_stall_at, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(lsu_stall_duration, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_enum(lsu_excep_e, lsu_exception, UVM_ALL_ON)
    `uvm_field_int(mcause, UVM_ALL_ON)
    `uvm_field_int(mtval, UVM_ALL_ON)
    `uvm_field_int(req_vld_at, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function pipe_trans_t to_struct();

    endfunction

    function void from_struct(pipe_trans_t t);

    endfunction

    function pipe_trans_t to_struct();
        pipe_trans_t t;
    endfunction

    //constraints

endclass
