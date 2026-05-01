/**
* @ brief Decide which pc should be next
**/

module next_pc(
    input  logic [31:0] alu_res, imm_res, ///< Possible next pc's
    input  logic [31:0]pc_current, ///< Current PC
    input  logic [1:0] pc_src, ///< Control which possible one
    output logic [31:0] pc_next, ///< Next PC
    output logic [31:0] pc_default /// For JAL(R)
);

    always_comb begin 
        pc_default = pc_current + 4;
        case (pc_src) 
            2'b00: pc_next = pc_default; // Default update
            2'b01: pc_next = imm_res; // B/J-Type update
            2'b10: pc_next = alu_res; // I-Type update
            default: pc_next = 'x;
        endcase 
    end

endmodule