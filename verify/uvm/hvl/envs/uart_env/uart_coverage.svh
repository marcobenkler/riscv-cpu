class uart_coverage extends uvm_subscriber #(uart_item);
    `uvm_component_utils(uart_coverage)

    uvm_analysis_imp#(uart_item, uart_coverage) tx_imp;
    uvm_analysis_imp#(uart_item, uart_coverage) rx_imp;

    // uart_item item; not needed when cov_grp parametrised

    // covergroup declaration
    covergroup cg_1 with function sample(uart_item t);

    endgroup

    covergroup cg_2 with function sample(uart_item t);

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_1 = new();
        cg_2 = new();
    endfunction

    function void write(uart_item t);
        // item = t; not needed when cov_grp parametrised
        cg_1.sample(t);
        cg_2.sample(t);
    endfunction

endclass
