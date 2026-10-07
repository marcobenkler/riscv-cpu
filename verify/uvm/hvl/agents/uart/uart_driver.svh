class uart_driver extends uvm_driver #(uart_item);
    `uvm_component_utils(uart_driver)

    uart_config cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // not needed, bfm handle per cfg in agent is better
        // if(!uvm_config_db#(virtual uart_bfm)::get(this, "", "bfm", bfm))
            // `uvm_fatal("NO_BFM", {"No BFM found for: ", get_full_name()});
    endfunction

    virtual task run_phase(uvm_phase phase);
        bit aborted;
        cfg.bfm.wait_reset_done();
        forever begin
            `uvm_info("DRV", $sformatf("Waited reset, now sending item"), UVM_DEBUG)
            seq_item_port.get_next_item(req);
            cfg.bfm.send(req.to_struct(), aborted);
            seq_item_port.item_done();
            if (aborted) cfg.bfm.wait_reset_done();
        end
    endtask

endclass
