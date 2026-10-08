class lsu_env_config extends uvm_object;
    `uvm_object_utils(lsu_env_config)

    axil_config axil_cfg;
    pipe_config pipe_cfg;

    bit en_cov = 1'b1;
    bit en_scb = 1'b1;

    function new(strin name = "lsu_env_config");
        super.new(name);
    endfunction
endclass
