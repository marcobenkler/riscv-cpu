class lsu_monitor extends uvm_monitor;
    `uvm_component_utils(lsu_monitor)
    `uvm_component_new

    lsu_config cfg;

    uvm_analysis_port#(lsu_item) item_collected_port;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_port = new("item_collected_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        lsu_item    item_collected;
        lsu_trans_t t;
        forever begin
            cfg.bfm.wait_trans(t);
            item_collected = lsu_item::type_id::create("item_collected");
            item_collected.from_struct(t);
            item_collected_port.write(item_collected);
            `uvm_info("MNTR". $sformatf("LSU monitor wrote item on analysis port"), UVM_DEBUG);
        end
    endtask

endclass
