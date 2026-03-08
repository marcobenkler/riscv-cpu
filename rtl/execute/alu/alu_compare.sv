/**
* @brief ALU compare unit
*
* Performs comparisons between two operands
*/

module alu_compare(
    input   logic [31:0] a,         ///< first operand
    input   logic [31:0] b,         ///< second operand
    input   logic [1:0]  cmp_op,    ///< 00 = eq, 01 = lt, 10 = ltu, 11 = ne
    output  logic        result     ///< comparison result
);

    always_comb begin
        unique case (cmp_op)
            2'b00: result = (a == b);
            2'b01: result = (signed'(a) < signed'(b));
            2'b10: result = (unsigned'(a) < unsigned'(b));
            2'b11: result = (a != b);
            default: result = 1'b0;
        endcase
    end

endmodule