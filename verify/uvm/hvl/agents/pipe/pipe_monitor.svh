class pipe_monitor extends uvm_monitor;
    `uvm_component_utils(pipe_monitor)

    pipe_config bfm;

    uvm_analysis_port#(pipe_item) item_port_collected;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_port_collected = new("item_port_collected", this);
    endfunction

    function void run_phase(uvm_phase phase);
        super.run_phase(phase);
        pipe_item    item_collected;
        pipe_trans_t t;
        forever begin
            cfg.bfm.wait_trans(t);
            item_collected = pipe_item::type_id::create("item_collected");
            item_collected.from_struct(t);
            item_port_collected.write(item_collected);
            `uvm_info("MNFT", $sformatf("Pipe item was written on ana_port"), UVM_DEBUG);
        end
    endfunction

endclass
