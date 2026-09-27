class uart_sequence extends uvm_sequence #(uart_item);
    `uvm_object_utils(uart_sequence)

    function new(string name = "uart_sequence");
        super.new(name);
    endfunction

    virtual task body();
        req = uart_item::type_id::create("req");
        start_item(req);
        if(!req.randomize())
            `uvm_fatal("NORAND", {"Could not randomize for: ", get_full_name()})
        finish_item(req);
    endtask
endclass
