class cosim_env extends uvm_env;
    `uvm_component_utils(cosim_env)
    `uvm_component_new

    cosim_agent      agnt;
    cosim_env_config cfg;

    cosim_coverage cov;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(cosim_env_config)::get(this, "", "cfg", cfg))
            `uvmn_fatal("NO_CFG", {"No cfg handle was found in ", get_full_name()})
            agnt = cosim_agent::type_id::create("agnt", this);
            agnt.cfg = cfg.agnt_cfg;
            cov = cosim_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agnt.ap.connect(cov.imp);
    endfunction

endclass
