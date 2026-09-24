interface uart_bfm #(parameter bit IsActive = 1)
(
    input  logic clk,
    input  logic rst_n,
    input  logic line_in,
    output logic line_out
    //Pins for signals to the DUT
    //Handles for everything to the HVL infrastructure
);

    import common_uart_pkg::*;

    //Use struct packed, hvl doesnt know about classes like item
    //item <-> struct done by monitor/driver
    uart_trans_t enc_trans;
    uart_trans_t dec_trans;

    logic [16:0] cnt;
    logic [$clog2(10)-1:0] bit_cnt;
    logic        baud_tick;
    logic [10:0] frame_out;

    uart_bfm_states_t STATE;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            STATE <= IDLE;
            line_out <= 1'b1;
        end
        else begin
            case (STATE)
                IDLE: begin
                    line_out <= 1'b1;
                    if (start_req) begin
                        //UART sends LSB first
                        frame_out <= {~enc_trans.frame_err, enc_trans.data, 1'b0};
                        STATE <= WAIT;
                        cnt   <= enc_trans.delay;
                    end
                end
                WAIT: if (baud_tick) begin
                    if (cnt == 0) begin
                        STATE <= START;
                        bit_cnt <= '0;
                    end
                    else cnt <= cnt - 1;
                end
                WORK: begin
                    if (bit_cnt == 10) begin
                        state    <= IDLE;
                        lane_out <= 1'b1;
                    end else begin
                        line_out <= frame_out[0];
                        frame_out <= frame_out >> 1;
                        bit_cnt <= bit_cnt + 1;
                    end
                end
                default: ;
            endcase
        end
    end

endinterface
