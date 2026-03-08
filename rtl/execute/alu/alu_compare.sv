/**
* @brief ALU compare unit
*
* Performs comparisons between two operands
*/

module alu_compare(
    input   logic [31:0] a,         ///< first operand
    input   logic [31:0] b,         ///< second operand
    input   logic [1:0]  cmp_op,    ///< 00 = eq, 01 = lt, 10 = ltu, 11 = ne
    output  logic [31:0] result     ///< comparison result in LSB
);

    always_comb begin
        unique case (cmp_op)
            2'b00: result = {31'b0, (a == b)};
            2'b01: result = {31'b0, (logic signed [31:0]'(a) < logic signed [31:0]'(b))};
            2'b10: result = {31'b0, (a < b)};
            2'b11: result = {31'b0, (a != b)};
            default: result = '0;
        endcase
    end

endmodule