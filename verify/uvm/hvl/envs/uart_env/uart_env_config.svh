class uart_env_config extends uvm_object;
    `uvm_object_utils(uart_env_config)

    uart_config rx_cfg;
    uart_config tx_cfg;

    bit loopback = 1'b0;
    bit en_cov   = 1'b1;
    bit en_scb   = 1'b1;

    function new(string name = "uart_env_config");
        super.new(name);
    endfunction

endclass
