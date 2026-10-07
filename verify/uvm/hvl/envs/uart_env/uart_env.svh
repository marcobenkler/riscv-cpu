class uart_env extends uvm_env;
    `uvm_component_utils(uart_env)

    uart_agent      agnt_rx;
    uart_agent      agnt_tx;
    // mem_agent      agnt_mem;
    uart_scoreboard scb;
    uart_coverage   cov;

    uart_env_config cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(uart_env_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("NO_CFG", {"Config not found for: ", get_full_name()})
        agnt_rx = uart_agent::type_id::create("agnt_rx", this);
        agnt_rx.cfg = cfg.rx_cfg;
        agnt_tx = uart_agent::type_id::create("agnt_tx", this);
        agnt_tx.cfg = cfg.tx_cfg;
        // if (!cfg.loopback) agnt_mem = mem_agent::type_id::create("agnt_mem", this)
        if (cfg.en_scb) scb = uart_scoreboard::type_id::create("scb", this);
        if (cfg.en_cov) cov = uart_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (cfg.en_scb) begin
            if (cfg.loopback) begin
                agnt_rx.ap.connect(scb.item_collected_source);
                agnt_tx.ap.connect(scb.item_collected_sink);
            end /*else begin
                agnt_rx.ap.connect(scb.item_collected_source_per);
                agnt_mem.ap.connect(scb.item_collected_mem);
                agnt_tx.ap.connect(scb.item_collected_sink_per);
            end*/
        end
        if (cfg.en_cov) begin
            if (cfg.loopback) begin
                agnt_rx.ap.connect(cov.rx_imp);
            end
        end
    endfunction


endclass
