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
    logic [3:0]  bit_cnt_out;
    logic        baud_tick;
    logic [10:0] frame_out;

    logic [3:0]  bit_cnt_in;
    logic [10:0] frame_in;

    uart_tx_states_t ENC_STATE;
    uart_rx_states_t DEC_STATE;

    sync_2ff sync_line_in(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(line_in),
        .data_out(line_in_sync)
    );
    generate
        if (IsActive) begin : g_enc
            always_ff @(posedge clk) begin
                if (!rst_n) begin
                    ENC_STATE <= ENC_IDLE;
                    line_out  <= 1'b1;
                end
                else begin
                    case (ENC_STATE)
                        ENC_IDLE: begin
                            line_out <= 1'b1;
                            if (start_req) begin
                                //UART sends LSB first
                                frame_out <= {~enc_trans.frame_err, enc_trans.data, 1'b0};
                                ENC_STATE <= ENC_WAIT;
                                cnt       <= enc_trans.delay;
                            end
                        end
                        ENC_WAIT: if (baud_tick) begin
                            if (cnt == 0) begin
                                ENC_STATE   <= ENC_START;
                                bit_cnt_out <= '0;
                            end
                            else cnt <= cnt - 1;
                        end
                        ENC_WORK: if (baud_tick) begin
                            if (bit_cnt_out == 10) begin
                                ENC_STATE <= ENC_IDLE;
                                lane_out  <= 1'b1;
                            end else begin
                                line_out    <= frame_out[0];
                                frame_out   <= frame_out >> 1;
                                bit_cnt_out <= bit_cnt_out + 1;
                            end
                        end
                        default: ;
                    endcase
                end
            end
        end else begin : g_no_enc
            assign line_out = 1'b1;
        end
    endgenerate

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            DEC_STATE <= DEC_IDLE;
            frame_in  <= '0;
        end
        else begin
            case (DEC_STATE)
                DEC_IDLE: begin
                    if (!line_in_sync) begin
                        DEC_STATE  <= DEC_WORK;
                        bit_cnt_in <= '0;
                    end
                end
                DEC_WORK: if (baud_tick) begin
                    if (bit_cnt_in == 10) begin
                        DEC_STATE <= DEC_IDLE;
                    end else begin
                        frame_in[0] <= line_in_sync;
                        frame_in    <= {line_in_sync, frame_in[9:1]};
                        bit_cnt_in  <= bit_cnt_in + 1;
                    end
                end
                default: ;
            endcase
        end
    end

endinterface
