/**
* @brief simple multiplication implementation to get get a OS running
**/

module multiply (
    input logic [31:0] a, ///< first operand
    input logic [31:0] b, ///< second operand
    input logic [1:0]  alu_op, ///< which multiplication
    input logic [31:0] result ///< result of the operation
);

    logic [63:0] multi_ss; // mul, mulh
    logic [63:0] multi_su; // mulhsu
    logic [63:0] multi_uu; // mulhu

    always_comb begin
        multi_ss = $signed(a) * $signed(b);
        multi_su = $signed(a) * $unsigned(b);
        multi_uu = $unsigned(a) * $unsigned(b);
    end

    always_comb begin
        case (alu_op)
            2'b00: multi_ss[31:0];
            2'b01: multi_ss[61:32];
            2'b10: multi_su[61:32];
            2'b11: multi_uu[61:32];
        endcase
    end

endmodule