class retire_monitor extends uvm_monitor;
    `uvm_component_utils(retire_monitor)
    `uvm_component_new

    uvm_analysis_port#(uart_item) ap;
    retire_config cfg;

    virtual retire_if.MONITOR mon;
    retire_config cfg;


    int unsigned glb_order = 0;
    int unsigned glb_cycle = 0;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("item_collected_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        mon = cfg.vif;
        retire_item trans_collected;
        forever begin
            @(posedge mon.clk)
            if (mon.rvfi_res.valid) begin
                trans_collected = retire_item::type_id::create("trans_collected");
                trans_collected.cycle = gbl_cycle;
                trans_collected.rvfi = mon.rvfi_res;
                trans_collected.order = glb_order;
                ap.write(trans_collected);
                glb_order++;
            end
            glb_cycle++;
        end
    endtask

endclass
