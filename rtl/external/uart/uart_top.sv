module uart_top(
    input  logic       clk,
    input  logic       reset_n,
    input  logic       tx_start,
    input  logic [7:0] wdata_t,
    input  logic       rx,
    output logic       tx_ready,
    output logic [7:0] wdata_r,
    output logic       rx_valid,
    output logic       tx
);

    localparam baud_rate = 115_200;
    logic baud_tick_tx;
    logic baud_tick_rx;

    uart_baud #(.baud_rate(baud_rate)) uart_baut_tx(
        .clk(clk),
        .reset_n(reset_n),
        .baud_tick(baud_tick_tx) //output
    );

    uart_baud #(.baud_rate(16 * baud_rate)) uart_baud_rx(
        .clk(clk),
        .reset_n(reset_n),
        .baud_tick(baud_tick_rx) //output
    );

    uart_tx uart_tx(
        .clk(clk),
        .reset_n(reset_n),
        .baud_tick(baud_tick_tx),
        .tx_start(tx_start),
        .wdata(wdata_t),
        .tx_ready(tx_ready), //output
        .tx(tx) //output
    );

    uart_rx uart_rx(
        .clk(clk),
        .reset_n(reset_n),
        .baud_tick_fast(baud_tick_rx),
        .rx(rx),
        .wdata(wdata_r),
        .rx_valid(rx_valid)
    );

endmodule