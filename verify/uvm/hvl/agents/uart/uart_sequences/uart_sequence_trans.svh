class uart_sequence_trans extends uvm_sequence #(uart_item);
    `uvm_object_utils(uart_sequence_trans)
    `uvm_object_new

    bit [7:0] vals[] = '{8'h00, 8'hFF};
    int n = 3;

    virtual task body();
        for (int i = 0; i < n; i++) begin
            bit [7:0] v = vals[i % 2];
            req = uart_item::type_id::create("req");
            req.data_split_c.constraint_mode(0);
            start_item(req);
            if (!req.randomize() with { data == local::v; })
                `uvm_error(get_type_name(), "randomize failed")
            finish_item(req);
        end
    endtask
endclass
