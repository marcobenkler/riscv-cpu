/**
* @brief Divider that reduces the longest critical path significantly
**/

module srt2 
    import alu_pkg::*;
(
    input  logic        clk,
    input  logic        reset_n,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [1:0]  div_op,
    input  logic        srt_en,
    output logic [31:0] div_res,
    output logic        srt_done
);
    div_state_e state;

    logic [5:0] lzd_reg;
    logic [5:0] lzn_reg;

    logic signed [32:0] divisor;
    logic signed [32:0] rest;
    logic signed [32:0] temp_rest;
    logic [31:0] quotient_pos;
    logic [31:0] quotient_neg;

    logic signed [1:0] q;
    logic [4:0] cycle_count;

    logic signed [31:0] ND;
    logic signed [31:0] NN;
    logic [5:0] LZD;
    logic [5:0] LZN;

    Norm norm(
        .D(rs2_data),
        .N(rs1_data),
        .ND(ND),
        .NN(NN),
        .LZD(LZD),
        .LZN(LZN)
    );

    digitSelect digitSelect(
        .R(rest),
        .ND(divisor),
        .Q(q)
    );

    remainder remainder(
        .R(rest),
        .ND(divisor),
        .Q(q),
        .RNEW(temp_rest)
    );

    always_comb begin
        case (div_op)
            DIV: begin 
                if (lzd_reg >= lzn_reg)
                    div_res = $signed(quotient_pos - quotient_neg) << (lzd_reg - lzn_reg);
                else 
                    div_res = $signed(quotient_pos - quotient_neg) >> (lzn_reg - lzd_reg);
            end
            DIVU: begin
                if (lzd_reg >= lzn_reg)
                    div_res = (quotient_pos - quotient_neg) << (lzd_reg - lzn_reg);
                else
                    div_res = (quotient_pos - quotient_neg) >> (lzn_reg - lzd_reg);
                end
            REM: div_res = $signed(rest[31:0]) >>> lzn_reg;
            REMU: div_res = rest[31:0] >> lzn_reg;
        endcase
        srt_done = (state == DONE);
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            lzd_reg <= '0;
            lzn_reg <= '0;
            divisor <= '0;
            quotient_pos <= '0;
            quotient_neg <= '0;
            rest <= '0;
            cycle_count <= '0;
            state <= IDLE;
        end else begin
            // FSM
            if (state == IDLE && srt_en) begin
                rest <= {1'b0, NN};
                state <= RUNNING;
                divisor <= {1'b0, ND};
                lzd_reg <= LZD;
                lzn_reg <= LZN;
                cycle_count <= '0;
            end
            else if (state == RUNNING) begin
                cycle_count <= cycle_count + 1;
                case (q)
                    2'sd1: begin
                        quotient_pos[31 - cycle_count] <= 1'b1;
                        quotient_neg[31 - cycle_count] <= 1'b0;
                    end
                    2'sd0: begin
                        quotient_pos[31 - cycle_count] <= 1'b0;
                        quotient_neg[31 - cycle_count] <= 1'b0;
                    end
                    -2'sd1: begin
                        quotient_pos[31 - cycle_count] <= 1'b0;
                        quotient_neg[31 - cycle_count] <= 1'b1;
                    end
                    default: ;
                endcase
                rest <= temp_rest;
                // Trick to avoid extra if case
                if (cycle_count + 1'b1 == '0) state <= DONE;
            end
            else if(state == DONE) begin
                state <= IDLE;
            end
        end
    end


endmodule