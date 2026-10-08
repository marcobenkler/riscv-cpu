class lsu_env extends uvm_env;
    `uvm_compnent_utils(lsu_env)
    `uvm_component_new

    lsu_scoreboard scb;
    lsu_coverage   cov;
    axil_agent     axil_agnt;
    pipe_agent     pipe_agnt;

    lsu_env_config cfg;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(lsu_env_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("NO_CFG", {"Config not found for: ", get_full_name()})
        if (cfg.en_cov) cov = lsu_coverage::type_id::create("cov", this);
        if (cfg.en_scb) scb = lsu_scoreboard::type_id::create("scb", this);
        axil_agnt = lsu_agent::type_id::create("axil_agnt", this);
        axil_agnt.cfg = cfg.axil_cfg;
        pipe_agnt = lsu_agent::type_id::create("pipe_agnt", this);
        pipe_agnt.cfg = cfg.pipe_cfg;
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (cfg.env_cov) begin
            axil_agnt.ap.connect(cov.axil_imp);
            pipe_agnt.ap.connect(cov.pipe_imp);
        end
        if (cfg.scb_cov) begin
            axil_agnt.ap.connect(scb.axil_imp);
            pipe_agnt.ap.connect(scb.pipe_imp);
        end
    endfunction
endclass
