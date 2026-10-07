`timescale 1ns/1ps

class uart_loopback_test extends uvm_test;
    `uvm_component_utils(uart_loopback_test)

    uart_env        env;
    uart_env_config env_cfg;
    // vseq now. uart_sequence   seq;
    uart_vsequence  vseq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //Create env_cfg, create agnt_cfg, get bfm handle and put on cfg, make setting
        env_cfg = uart_env_config::type_id::create("env_cfg");
        // Build agent cfg in test, only test needs to be modified, agents are reusable
        env_cfg.rx_cfg = uart_config::type_id::create("rx_cfg");
        env_cfg.tx_cfg = uart_config::type_id::create("tx_cfg");

        //Get bfm always with virtual
        if(!uvm_config_db#(virtual uart_bfm)::get(this, "", "bfm_rx", env_cfg.rx_cfg.bfm))
            `uvm_fatal("NO_BFM", {"Could not found bfm at: ", get_full_name()})
        if(!uvm_config_db#(virtual uart_bfm)::get(this, "", "bfm_tx", env_cfg.tx_cfg.bfm))
            `uvm_fatal("NO_BFM", {"Could not found bfm at: ", get_full_name()})

        env_cfg.rx_cfg.is_active = UVM_ACTIVE;
        env_cfg.tx_cfg.is_active = UVM_PASSIVE;
        env_cfg.loopback = 1'b1;

        uvm_config_db#(uart_env_config)::set(this, "*", "cfg", env_cfg);
        env = uart_env::type_id::create("env", this);
        // vseq now. seq = uart_sequence::type_id::create("seq");
        vseq = uart_vsequence::type_id::create("vseq");
        // vseq.seqcr = env.agnt_rx.seqcr; wrong, move to phase after build. first build, then build of children
        // when vseq.seqcr gets assigned, the build phase of the env didnt got through
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vseq.seqcr = env.agnt_rx.seqcr;
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.get_objection().set_drain_time(this, 300us);
        // vseq now. seq.start(env.agnt_rx.seqcr);
        vseq.start(null);
        phase.drop_objection(this);
    endtask
endclass
