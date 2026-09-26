module hdl_top;

    pl_cpu pl_cpu_u(
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        uvm_config_db#(virtual uart_bfm)::set(null, "*", "uart_rx_bfm", rx_bfm);
        uvm_config_db#(virtual uart_bfm)::set(null, "*", "uart_tx_bfm", tx_bfm);
    end
endmodule
