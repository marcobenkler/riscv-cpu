class retire_config extends uvm_object;
    `uvm_object_utils(retire_config)

    virtual retire_if vif;

    function new(string name = "retire_config");
        super.new(name);
    endfunction
endclass
