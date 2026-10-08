class pipe_agent extends uvm_agent #(pipe_item);
    `uvm_component_utils(pipe_agent)
    uvm_analysis_port#(pipe_item) ap;

    pipe_driver    drv;
    pipe_monitor   mntr;
    pipe_sequencer seqcr;

    pipe_config cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv   = pipe_driver::type_id::create("drv", this);
        drv.cfg = cfg;
        mntr  = pipe_monitor::type_id::create("mntr", this);
        mntr.cfg = cfg;
        seqcr = pipe_sequencer::type_id::create("seqcr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqcr.seq_item_export);
        ap = mntr.item_collected_port;
    endfunction
endclass
