class axil_driver extends uvm_driver #(axil_item);
    `uvm_component_utils(axil_driver)
    `uvm_component_new

    axil_config cfg;

    virtual task run_phase(uvm_phase phase);
        bit aborted;
        axil_trans_t t;
        cfg.bfm.wait_reset_done();
        forever begin
            `uvm_info("DRV", $sformatf("Waited reset, now sending axil item"), UVM_DEBUG)
            seq_item_port.get_next_item(req);
            cfg.bfm.get_request(t, aborted);
            req.from_struct(t);
            seq_item_port.item_done();
            // If rst was pulled, skip this one
            if (aborted) begin
                cfg.bfm.wait_reset_done();
                continue;
            end
            seq_item_port.get_next_item(req); // Still the same req
            cfg.bfm.put_response(req.to_struct());
            seq_item_port.item_done();
        end
    endtask

endclass
