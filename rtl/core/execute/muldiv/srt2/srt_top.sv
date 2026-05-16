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
    logic        [32:0] restu_shifted;
    logic [31:0] quotient_pos;
    logic [31:0] quotient_neg;
    logic [31:0] q_mag;

    logic signed [1:0] q;
    logic [4:0]  cycle_count;
    logic        q_norm_ge_1;  // Q_norm >= 1.0: NN >= ND after normalization

    logic [31:0] rs1_latch;
    logic [31:0] rs2_latch;

    logic signed [31:0] ND;
    logic signed [31:0] NN;
    logic [5:0] LZD;
    logic [5:0] LZN;

    // Sign handling: negate inputs for signed ops, restore sign at output
    logic        sign_n, sign_d;
    logic        sign_div_reg, sign_rem_reg;
    logic [32:0] abs_n, abs_d;

    assign sign_n = (div_op == DIV || div_op == REM) ? rs1_data[31] : 1'b0;
    assign sign_d = (div_op == DIV || div_op == REM) ? rs2_data[31] : 1'b0;
    assign abs_n  = sign_n ? (~{rs1_data[31], rs1_data} + 1) : {1'b0, rs1_data};
    assign abs_d  = sign_d ? (~{rs2_data[31], rs2_data} + 1) : {1'b0, rs2_data};

    Norm norm(
        .D(abs_d[31:0]),
        .N(abs_n[31:0]),
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
        // When Q_norm >= 1.0, add the integer part 2^(LZD-LZN) to the SRT2
        q_mag = 'x;
        restu_shifted = 'x;
        if (rs2_data == '0) begin
            case (div_op) 
                DIV: div_res = 32'hFFFFFFFF;
                DIVU: div_res = 32'hFFFFFFFF;
                //Store rs1_data in rest to save latch and have it stable
                REM: div_res = rs1_latch;
                REMU: div_res = rs1_latch;
            endcase
        end
        else begin
            q_mag         = (quotient_pos - quotient_neg) >> (32 - lzd_reg + lzn_reg);
            if (q_norm_ge_1 && lzd_reg >= lzn_reg)
                q_mag = q_mag + (32'b1 << (lzd_reg - lzn_reg));
            restu_shifted = $unsigned(rest) >> lzd_reg;
            case (div_op)
                DIV:  div_res = sign_div_reg ? (~q_mag + 1)               : q_mag;
                DIVU: div_res = q_mag;
                REM:  div_res = sign_rem_reg ? (~restu_shifted[31:0] + 1) : restu_shifted[31:0];
                REMU: div_res = rs1_latch - q_mag * rs2_latch;
            endcase
        end
        srt_done = (state == DONE);
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            lzd_reg      <= '0;
            lzn_reg      <= '0;
            divisor      <= '0;
            quotient_pos <= '0;
            quotient_neg <= '0;
            rest         <= '0;
            cycle_count  <= '0;
            sign_div_reg <= '0;
            sign_rem_reg <= '0;
            q_norm_ge_1  <= '0;
            state        <= IDLE;
        end else begin
            if (state == IDLE && srt_en) begin
                if (rs2_data == '0) begin
                    state <= DONE;
                    rs1_latch <= rs1_data;
                end
                else begin
                    // If NN >= ND: Q_norm >= 1.0, SRT2 runs on the fractional remainder
                    q_norm_ge_1  <= ({1'b0, NN} >= {1'b0, ND});
                    rest         <= ({1'b0, NN} >= {1'b0, ND}) ? {1'b0, NN - ND} : {1'b0, NN};
                    divisor      <= {1'b0, ND};
                    lzd_reg      <= LZD;
                    lzn_reg      <= LZN;
                    cycle_count  <= '0;
                    sign_div_reg <= sign_n ^ sign_d;
                    sign_rem_reg <= sign_n;
                    rs1_latch    <= rs1_data;
                    rs2_latch    <= rs2_data;
                    state        <= RUNNING;
                end
            end
            else if (state == RUNNING) begin
                cycle_count <= cycle_count + 1;
                case (q)
                    2'sd1:  begin
                        quotient_pos[31 - cycle_count] <= 1'b1;
                        quotient_neg[31 - cycle_count] <= 1'b0;
                    end
                    2'sd0:  begin
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
                if (cycle_count + 1'b1 == '0) state <= DONE;
            end
            else if (state == DONE) begin
                state        <= IDLE;
                quotient_pos <= '0;
                quotient_neg <= '0;
            end
        end
    end

endmodule
