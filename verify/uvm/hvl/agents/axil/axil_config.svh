class axil_config extends uvm_object;
    `uvm_object_utils(axil_config)

    virtual axil_bfm bfm;
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    function new(string name = "axil_config");
        super.new(name);
    endfunction

endclass
