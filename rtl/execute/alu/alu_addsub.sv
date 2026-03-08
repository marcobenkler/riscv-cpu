/**
* @brief ALU add/sub unit
*
* Performs integer addition/subtraction.
*/

module alu_addsub (
    input   logic [31:0] a,     ///< first operand
    input   logic [31:0] b,     ///< second operand
    input   logic sub,          ///< 1 = sub, 0 = add
    output  logic [31:0] result ///< operation result
);

    logic [31:0] b_buf;
    
    assign b_buf = sub ? ~b : b;
    assign result = a + b_buf + sub;

endmodule