// Config for runtime settings that are set by the test

class uart_config extends uvm_object;
    `uvm_object_utils(uart_config)

    virtual uart_bfm bfm;
    bit              is_active = UVM_ACTIVE;

    function new(string name = "uart_config");
        super.new(name);
    endfunction

endclass
