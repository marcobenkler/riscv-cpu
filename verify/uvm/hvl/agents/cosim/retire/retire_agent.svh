class retire_agent extends uvm_agent;
    `uvm_component_utils(retire_agent)
    `uvm_component_new

    retire_monitor      mntr;
    retire_trace_writer trc_wr;

    retired_config cfg;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mntr = retire_monitor::type_id::create("mntr", this);
        mntr.cfg = cfg;
        trc_wr = retire_trace_writer::type_id::create("trc_wr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //subscribers imp is named analysis_export
        mntr.ap.connect(trc_wr.analysis_export);
    endfunction
endclass
