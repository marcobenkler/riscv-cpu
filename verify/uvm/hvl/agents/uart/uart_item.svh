class uart_item extends uvm_sequence_item;
    rand bit [7:0] data;
    rand int       delay;
    rand bit       frame_err;

    `uvm_object_utils_begin(uart_item)
    `uvm_field_int(data, UVM_DEFAULT)
    `uvm_field_int(delay, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new(string name = "uart_item");
        super.new(name);
    endfunction

    constraint frame_err_c     { soft frame_err == 0;};
    constraint min_max_delay_c { soft delay inside {[3:19]}; }

endclass
