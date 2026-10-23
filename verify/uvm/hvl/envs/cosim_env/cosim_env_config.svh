class cosim_env_config extends uvm_object;
    `uvm_object_utils(cosim_env_config)

    retire_config agnt_cfg;

    function new(string name = "cosim_env_config");
        super.new(name);
    endfunction

endclass
