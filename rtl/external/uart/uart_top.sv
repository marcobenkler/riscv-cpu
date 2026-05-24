module uart_top
    import uart_pkg::*;
(
    input  logic        clk,
    input  logic        reset_n,
    input  logic        tx_start,
    input  logic [31:0] address,
    input  logic [31:0] uart_write_data,
    input  logic        rx,
    output logic [31:0] uart_read_data,
    output logic        tx
);

    localparam baud_rate = 115_200;
    logic baud_tick_tx;
    logic baud_tick_rx;

    logic        tx_ready;
    logic        rx_valid;
    logic [7:0]  wdata_r;
    logic [31:0] uart_tx_reg;
    logic [31:0] uart_rx_reg;

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

    uart_tx u_uart_tx(
        .clk(clk),
        .reset_n(reset_n),
        .baud_tick(baud_tick_tx),
        .tx_start(tx_start),
        .wdata(uart_tx_reg[7:0]),
        .tx_ready(tx_ready), //output
        .tx(tx) //output
    );

    uart_rx u_uart_rx(
        .clk(clk),
        .reset_n(reset_n),
        .baud_tick_fast(baud_tick_rx),
        .rx(rx),
        .wdata(wdata_r), //output
        .rx_valid(rx_valid) //output
    );

    always_ff @(posedge clk) begin
        if(!reset_n) begin
            uart_tx_reg <= '0;
            uart_rx_reg <= '0;
        end
        else begin
            if(tx_start) uart_tx_reg <= uart_write_data;
            if(rx_valid) uart_rx_reg <= {24'b0, wdata_r};
        end
    end

    always_comb begin
        case (address - UART_BASE)
            UART_STATUS: uart_read_data = {30'b0, rx_valid, tx_ready};
            UART_RX:     uart_read_data = uart_rx_reg;
            default:     uart_read_data = '0;
        endcase
    end

endmodule