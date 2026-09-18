module tb_uart_baud();

    logic clk;
    logic reset_n;
    logic baud_tick;

    initial clk = 0;
    always #5 clk = ~clk;

    uart_baud #(.baud_rate(25_000_000)) u_uart_baud(
        .clk(clk),
        .reset_n(reset_n),
        .baud_tick(baud_tick)
    );

    initial begin
        reset_n = 0;
        #10;
        reset_n = 1;
        #100;
        reset_n = 0;
        #20;
        reset_n = 1;
        #20;
        $finish;
    end

endmodule