class cosim_env_config extends uvm_oject;
    `uvm_component_utils(cosim_env_config)

    cosim_config agnt_cfg;

    function new(string name = "cosim_env_config");
        super.new(name);
    endfunction

endclass
