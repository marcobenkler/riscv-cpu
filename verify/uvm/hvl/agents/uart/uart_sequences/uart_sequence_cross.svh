class uart_sequence_cross extends uvm_sequence #(uart_item);
    `uvm_object_utils(uart_sequence_cross)
    `uvm_object_new

    bit [7:0] vals[] = '{8'h00, 8'hFF, 8'hAA, 8'h55};
    int n = 20;

    //extra check bloats a bit, but verilator cant handle constraints, if assigned after check with () -> ass
    virtual task body();
        foreach (vals[j]) begin
            for (int i = 0; i < n; i++) begin
                bit [7:0] v = vals[j];
                req = uart_item::type_id::create("req");
                start_item(req);
                // use local, so the compiler takes the ones from for, not from the item thats searched first
                if (i % 2 == 0) begin
                    req.data_split_c.constraint_mode(0);
                    if (!req.randomize() with {
                        data      ==  local::vals[j];
                        frame_err == (local::i % 4 == 2);
                        })
                    `uvm_fatal("NO_RAND", {"Failed to randomize in: ", get_full_name()})
                end
                else begin
                    if (!req.randomize())
                    `uvm_fatal("NO_RAND", {"Failed to randomize in without: ", get_full_name()})
                end
                finish_item(req);
            end
        end
    endtask
endclass
