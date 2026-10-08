class axil_driver extends uvm_driver #(axil_item);
    `uvm_component_utils(axil_driver)
    `uvm_component_new

    axil_config cfg;

    virtual task run_phase(uvm_phase phase);
        bit aborted;
        cfg.bfm.wait_reset_done();
        forever begin
            `uvm_info("DRV", $sformatf("Waited reset, now sending axil item"), UVM_DEBUG)
            seq_item_port.get_next_item(req);
            cfg.bfm.send(req.to_struct(), aborted);
            seq_item_port.item_done();
            if (aborted) cfg.bfm.wait_reset_done();
        end
    endtask

endclass
