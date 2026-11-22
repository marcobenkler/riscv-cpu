/**
* @brief simple multiplication implementation to get get rs1_data OS running
**/

module multiply
    import alu_pkg::*;
(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        mul_en,
    input  logic [31:0] rs1_data, ///< first operand
    input  logic [31:0] rs2_data, ///< second operand
    input  logic [1:0]  mul_op, ///< which multiplication from decoder
    output logic [31:0] mul_res, ///< result of the operation
    output logic        mul_stall
);

    logic [63:0] multi_ss; // mul, mulh
    logic [63:0] multi_su; // mulhsu
    logic [63:0] multi_uu; // mulhu
    logic [1:0]  op_latched;
    logic [31:0] rs1_latched;
    logic [31:0] rs2_latched;
    mul_state_e  state;

    // Stopped resetting data to increase utilization efficiency. Only reset flags
    always_ff@(posedge clk) begin
        if (!rst_n) state <= MUL_IDLE;
        else if (state == MUL_IDLE) begin
            rs1_latched <= rs1_data;
            rs2_latched <= rs2_data;
            op_latched <= mul_op;
            if (mul_en) state <= MUL_RUN;
        end
        else if (state == MUL_RUN) begin
            state <= MUL_IDLE;
        end
    end

    always_comb begin
        multi_ss = $signed(rs1_latched) * $signed(rs2_latched);
        multi_su = $signed({rs1_latched[31],rs1_latched}) * $signed({1'b0,rs2_latched});
        multi_uu = $unsigned(rs1_latched) * $unsigned(rs2_latched);
    end

    assign mul_stall = (state == MUL_IDLE && mul_en);

    always_comb begin
        unique case (op_latched)
            MUL: mul_res = multi_ss[31:0];
            MULH: mul_res = multi_ss[63:32];
            MULHSU: mul_res = multi_su[63:32];
            MULHU: mul_res = multi_uu[63:32];
        endcase
    end

endmodule
