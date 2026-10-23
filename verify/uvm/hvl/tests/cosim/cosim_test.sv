`timescale 1ns/1ps

class cosim_test extends uvm_test;
    `uvm_component_utils(cosim_test)
    `uvm_component_new

    cosim_env        env;
    cosim_env_config env_cfg;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env_cfg = cosim_env_config::type_id::create("env_cfg");
        env_cfg.agnt_cfg = retire_config::type_id::create("agnt_cfg");
        if(!uvm_config_db#(virtual retire_if)::get(this, "", "retire_if", env_cfg.agnt_cfg.vif))
            `uvm_fatal("NO_VIF", {"Could not find vif in ", get_full_name()})
        uvm_config_db#(cosim_env_config)::set(this, "*", "cfg", env_cfg);
        env = cosim_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        phase.get_objection().set_drain_time(this, 50us);
        phase.drop_objection(this);
    endtask

endclass
