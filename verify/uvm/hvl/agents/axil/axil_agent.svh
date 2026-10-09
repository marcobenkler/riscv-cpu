class axil_agent extends uvm_agent;
    `uvm_component_utils(axil_agent)

    axil_sequencer seqcr;
    axil_monitor   mntr;
    axil_driver    drv;

    axil_config cfg;

    uvm_analysis_port#(axil_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        is_active = cfg.is_active;
        if (get_is_active() == IS_ACTIVE) begin
            seqcr = axil_sequencer::type_id::create("seqcr", this);
            drv   = axil_driver::type_id::create("drv", this);
            // No set ... get, instead get handles from config
            drv.cfg = cfg;
        end
        mntr = axil_monitor::type_id::create("mntr", this);
        mntr.cfg = cfg;
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == IS_ACTIVE)
            drv.seq_item_port.connect(seqcr.seq_item_export);
        ap = mntr.item_collected_port;
    endfunction

endclass
