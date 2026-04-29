/**
* @brief Create sign extended immediate
* number out of instruction vector
*
**/

module imm_gen(
    input logic [31:0] instruction, ///< entire instruction vector
    output logic [31:0] imm ///< sign extended immediate number
);
    logic [4:0] op_code;
    
    assign op_code = instruction[6:2];

    always_comb begin
        case (op_code)
            5'b00100: imm = {{20{instruction[31]}}, instruction[31:20]}; /// I-Type
            5'b01000: imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; /// S-Type
            5'b01101: imm = {instruction[31:12], 12'b0}; /// U-Type
            5'b11000: imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; /// B-Type
            5'b11011: imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0} /// J-Type
        endcase
    end

endmodule