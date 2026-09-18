module tb_uart_tx();

    logic clk;
    logic reset_n;
    logic baud_tick;
    logic tx_start;
    logic tx_ready;
    logic tx;
    logic [7:0] wdata = 8'b11010100;

    uart_baud #(.baud_rate(25_000_000)) uart_baud(
        .clk(clk),
        .reset_n(reset_n),
        .baud_tick(baud_tick) //output
    );

    uart_tx uart_tx(
        .clk(clk),
        .reset_n(reset_n),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .wdata(wdata),
        .tx_ready(tx_ready),
        .tx(tx)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        #10
        reset_n = 1;
        repeat(5) @(posedge clk);
        tx_start = 1'b1;
        @(posedge clk);
        tx_start = 1'b0;
        repeat(1000) @(posedge clk);
        $finish;
    end

    initial begin
        $dumpfile("sim/uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);
    end

endmodule