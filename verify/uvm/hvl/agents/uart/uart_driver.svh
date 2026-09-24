class uart_driver extends uvm_driver #(uart_item);
    virtual uart_bfm bfm;
    `uvm_component_utils(uart_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual uart_bfm)::get(this, "", "bfm", bfm))
            `uvm_fatal("NO_BFM", {"No BFM found for: ", get_full_name()});
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            // Wait on top in forever instead of before and at the end
            wait(bfm.rst_n);
            seq_item_port.get_next_item(req);
            fork begin : iso
                fork
                    drive();
                    @(negedge bfm.rst_n);
                join_any
                disable fork;
            end join
            seq_item_port.item_done();
        end
    endtask

    virtual task drive();
        // No timing like delay in driver, hdl/hvl wont work
        bfm.send(req.to_struct());
    endtask
endclass
