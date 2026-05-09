/**
* @brief simple multiplication implementation to get get rs1_data OS running
**/

module multiply 
    import alu_pkg::*;
(
    input  logic [31:0] rs1_data, ///< first operand
    input  logic [31:0] rs2_data, ///< second operand
    input  logic [1:0]  mul_op, ///< which multiplication from decoder
    output logic [31:0] mul_res ///< result of the operation
);

    logic [63:0] multi_ss; // mul, mulh
    logic [63:0] multi_su; // mulhsu
    logic [63:0] multi_uu; // mulhu

    always_comb begin
        multi_ss = $signed(rs1_data) * $signed(rs2_data);
        multi_su = $signed({rs1_data[31],rs1_data}) * $signed({1'b0,rs2_data});
        multi_uu = $unsigned(rs1_data) * $unsigned(rs2_data);
    end

    always_comb begin
        case (mul_op)
            MUL: mul_res = multi_ss[31:0];
            MULH: mul_res = multi_ss[63:32];
            MULHSU: mul_res = multi_su[63:32];
            MULHU: mul_res = multi_uu[63:32];
        endcase
    end

endmodule