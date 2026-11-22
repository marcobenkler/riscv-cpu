module uart_rx
    import uart_pkg::*;
(
    input  logic       clk,
    input  logic       reset_n,
    input  logic       baud_tick_fast,
    input  logic       rx,
    output logic [7:0] wdata,
    output logic       rx_valid
);

    uart_states_e state;

    logic       baud_tick;
    logic       mid_tick;
    logic [3:0] tick_count;
    logic [2:0] bit_cnt;

    // 2-ff synchronizer to resolve meta stability
    (* ASYNC_REG = "TRUE" *) logic rx_meta;
    (* ASYNC_REG = "TRUE" *) logic rx_s;

    always_ff@(posedge clk or negedge reset_n) begin
        if (!reset_n) {rx_s, rx_meta} <= 2'b11;
        else          {rx_s, rx_meta} <= {rx_meta, rx};
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state      <= IDLE;
            wdata      <= '0;
        end
        else if (state == IDLE && rx_s == 1'b0) begin
            state     <= START;
        end
        else if (mid_tick) begin
            if (rx_s == 1'b0) begin
                state   <= DATA;
                bit_cnt <= 3'b0;
            end
            else state <= IDLE; // detect glitch
        end
        else if (state == DATA && baud_tick)begin
            if(bit_cnt == 7) state <= STOP;
            bit_cnt <= bit_cnt + 1;
            wdata[bit_cnt] <= rx_s;
        end
        else if (state == STOP && baud_tick) begin
            state <= IDLE;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) tick_count <= '0;
        else if (state == IDLE && rx_s == 1'b0) tick_count <= '0;  // resync on new transmission
        else if (baud_tick_fast) tick_count <= tick_count + 1;
    end

    assign rx_valid = (state == STOP) && baud_tick;
    assign baud_tick = (tick_count == 4'b1111) && baud_tick_fast;
    assign mid_tick = (tick_count == 4'b0111) && baud_tick_fast && (state == START); // state of fsm

endmodule
