class uart_coverage extends uvm_subscriber #(uart_item);
    `uvm_component_utils(uart_coverage)

    uvm_analysis_imp#(uart_item, uart_coverage) rx_imp;

    // uart_item item; not needed when cov_grp parametrised

    // covergroup declaration
    covergroup cg_frame with function sample(uart_item t);

        DATA_VALUES: coverpoint t.data {
            bins max_val      = {8'hFF};
            bins min_val      = {8'h00};
            bins toggle_val[] = {8'h55, 8'hAA}; // [] both values must be hit
            // unsuported in ver 50.52 bins range[4]     = {[0:255]}; // [4] seperates in 4 same size bins
            bins low          = {[0:63]};
            bins mid          = {[64:127]};
            bins upper        = {[128:191]};
            bins high         = {[192:255]};
            // unsup bins walking_one  = {[0:255]} with ($onehot(item)); //only one 1 in the data
            // bins walking_zero = {[0:255]} with ($onehot(~item));
            bins min_2_max[]  = (8'h00 => 8'hFF), (8'hFF => 8'h00);
        }

        FRAME_ERR: coverpoint t.frame_err {
            bins err    = {1};
            bins no_err = {0};
        }

        WORD_FORMAT: cross DATA_VALUES, FRAME_ERR;

    endgroup


    function new(string name, uvm_component parent);
        super.new(name, parent);
        rx_imp = new("rx_imp", this);
        cg_frame = new();
    endfunction

    function void write(uart_item t);
        // item = t; not needed when cov_grp parametrised
        cg_frame.sample(t);
    endfunction

endclass
