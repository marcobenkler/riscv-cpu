class uart_driver extends uvm_driver #(uart_item);
    `uvm_component_utils(uart_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function build_phase(uvm_phase phase)
        super.build_phase(phase);
        if(!uvm_config_db#(virtaul uart_bfm)::get(this, "", "bfm", bfm))
            `uvm_fatal("NO_BFM", {"No BFM founnd for: ", get_full_name()});
    endfunction

    function run_phase(uvm_phase phase)
        wait(uart_bfm.rst_n);
        forever begin
            seq_item_port.get_next_item(req);
            fork begin : iso
                fork
                    drive();
                    @(negedge uart_bfm.rst_n);
                join_any
                disable fork
            end join
            seq_item_port.item_done();
        end
    endfunction

    virtual task drive();
        repeat(req.delay) @(uart_bfm.clk);
    endtask
endclass
