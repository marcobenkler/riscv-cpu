/**
* @brief select the correct result (alu, imm, pc, mem)
**/

module result_select (
    input  logic [31:0] alu_res, imm_res, mem_res, pc_res, csr_res,
    input  logic [2:0] res_src,
    output logic [31:0] result
);

    always_comb begin
        case (res_src) 
            3'b000: result = alu_res;
            3'b001: result = mem_res;
            3'b010: result = imm_res;
            3'b011: result = pc_res;
            3'b100: result = csr_res;
            default: result = 'x;
        endcase
    end
    
endmodule