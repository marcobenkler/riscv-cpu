class pipe_item extends uvm_object;
    // Alles rein, decoder, daten, ...

    `uvm_object_utils_begin(pipe_item)
    `uvm_field_int(, UVM_ALL_ON)
    `uvm_object_utils_end

    function void from_struct(pipe_trans_t t);

    endfunction

    function pipe_trans_t to_struct();
        pipe_trans_t t;
    endfunction

    //constraints

endclass
