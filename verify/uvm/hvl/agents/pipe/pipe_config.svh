class pipe_config extends uvm_object;
    `uvm_object_utils(pipe_config)

    virtual pipe_bfm bfm;

    function new(string name = "pipe_config");
        super.new(name);
    endfunction
endclass
