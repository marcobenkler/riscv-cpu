module uart_top
    import uart_pkg::*;
    import axi_pkg::*;
    #(parameter logic [31:0] baud_rate = 115_200)
(
    input  logic     clk,
    input  logic     reset_n,
    input  axi_req_t axi_req_uart,
    output axi_rsp_t axi_rsp_uart,
    output logic     rx_valid, //signal cpu uart has received full byte

    input  logic     rx, // in core
    output logic     tx  // out of core
    /*
    input  logic        tx_start,
    input  logic [31:0] address,
    input  logic [31:0] uart_write_data,
    output logic [31:0] uart_read_data,
    */
);

    logic baud_tick_tx;
    logic baud_tick_rx;

    logic        tx_ready;
    // logic        rx_valid;
    logic [7:0]  wdata_r;
    logic [31:0] uart_tx_reg;
    logic [31:0] uart_rx_reg;

    // AXI overhead
    logic tx_start;
    assign tx_start = axi_req_uart.awvalid && axi_req_uart.wvalid &&
                      (axi_req_uart.awaddr == UART_BASE + UART_TX) && tx_ready;

    assign axi_rsp_uart.bresp   = OKAY;
    assign axi_rsp_uart.bvalid  = 1'b1; //only combinational so always ready
    assign axi_rsp_uart.arready = 1'b1;
    assign axi_rsp_uart.rvalid  = 1'b1;

    always_comb begin
        if (tx_ready) begin
            axi_rsp_uart.awready = 1'b1;
            axi_rsp_uart.wready =  1'b1;
        end
    end

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
        .wdata(axi_req_uart.wdata[7:0]),
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
            uart_rx_reg <= '0;
        end
        else begin
            //if(tx_start) uart_tx_reg <= uart_write_data; caused one clock delay
            if(rx_valid) uart_rx_reg <= {24'b0, wdata_r};
        end
    end

    // READ
    always_comb begin
        axi_rsp_uart.rresp = OKAY;
        case (axi_req_uart.araddr - UART_BASE)
            UART_STATUS: axi_rsp_uart.rdata = {30'b0, rx_valid, tx_ready};
            UART_RX:     axi_rsp_uart.rdata = uart_rx_reg;
            default: begin
                axi_rsp_uart.rdata = 32'hDEAD_BEEF;
                axi_rsp_uart.rresp = SLVERR;
            end
        endcase
    end

endmodule
