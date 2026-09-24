class uart_sequence extends uvm_sequence #(uart_item);
    `uvm_object_utils(uart_sequence)

    function new(string name = "uart_sequence");
        super.new(name);
    endfunction

    virtual task body();
        
    endtask
endclass
