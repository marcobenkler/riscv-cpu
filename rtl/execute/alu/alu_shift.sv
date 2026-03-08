/**
* @brief ALU shift unit
*
* Performs shift operations on one operand
*/

module alu_shift(
    input   logic [31:0] a,             ///< first operand
    input   logic [4:0]  shift_range,    ///< range of shift
    input   logic [1:0]  shift_op,      ///< 00 = sll, 01 = srl, 10 = sra
    output  logic [31:0] result
);

    always_comb begin
        unique case (shift_op)
            2'b00: result = a << shift_range;
            2'b01: result = a >> shift_range;
            2'b10: result = signed'(a) >>> shift_range;
            default: result = '0;
        endcase
    end

endmodule