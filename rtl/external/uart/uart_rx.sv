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
    logic [3:0] tick_count;

    logic [2:0] bit_cnt;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state      <= IDLE;
            tick_count <= '0;
            wdata      <= '0;
        end
        else if (state == IDLE && rx == 1'b0) begin
            state     <= START;
            tick_count <= '0;
        end
        else if (state == START && baud_tick) begin
            state   <= DATA;
            bit_cnt <= 3'b0;
        end
        else if (state == DATA && baud_tick)begin
            if(bit_cnt == 7) state <= STOP;
            bit_cnt <= bit_cnt + 1;
            wdata[bit_cnt] <= rx;
        end
        else if (state == STOP && baud_tick) begin
            state <= IDLE;
        end
        if (baud_tick_fast) begin
            if(tick_count == 4'b1111) tick_count <= '0;
            else tick_count <= tick_count + 1;
        end
        rx_valid <= (state == DATA && baud_tick && bit_cnt == 7);
    end

    assign baud_tick = (tick_count == 4'b1000);

endmodule