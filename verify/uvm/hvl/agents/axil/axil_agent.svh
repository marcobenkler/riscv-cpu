class axil_agent extends uvm_agent;
    `uvm_component_utils(axil_agent)

    lsu_sequencer seqcr;
    lsu_monitor   mntr;
    lsu_driver    drv;

    lsu_config cfg;

    uvm_analysis_port#(axil_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        is_active = cfg.is_active;
        if (get_is_active() == IS_ACTIVE) begin
            seqcr = lsu_sequencer::type_id::create("seqcr", this);
            drv   = lsu_driver::type_id::create("drv", this);
            // No set ... get, instead get handles from config
            drv.cfg = cfg;
        end
        mntr = lsu_monitor::type_id::create("mntr", this);
        mntr.cfg = cfg;
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == IS_ACTIVE)
            drv.seq_item_port.connect(seqcr.seq_item_export);
        ap = mntr.item_collected_port;
    endfunction

endclass
