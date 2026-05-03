/**
* @brief ALU logic unit
*
* Performs bitwise logic operations
*/

module alu_logic(
    input   logic [31:0] a,         ///< first operand
    input   logic [31:0] b,         ///< second operand
    input   logic [1:0]  logic_op,  ///< 00 = and, 01 = or, 10 = xor
    output  logic [31:0] result     ///< operation result
);

    always_comb begin
        unique case (logic_op)
            2'b00: result = a & b;
            2'b01: result = a | b;
            2'b10: result = a ^ b;
            default: result = '0;
        endcase
    end

endmodule