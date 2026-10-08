class lsu_config extends uvm_object;
    `uvm_object_utils(lsu_config)
    `uvm_object_new

    virtual lsu_bfm bfm;
    uvm_active_passive_enum is_active = UVM_ACTIVE;


endclass
