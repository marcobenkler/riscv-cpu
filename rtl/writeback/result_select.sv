/**
* @brief select the correct result (alu, imm, pc, mem)
**/

module result_select (
    input  logic [31:0] alu_res, imm_res, mem_res, pc_res,
    input  logic [1:0] res_src,
    output logic [31:0] result
);

    always_comb begin
        case (res_src) 
            2'b00: result = alu_res;
            2'b01: result = mem_res;
            2'b10: result = imm_res;
            2'b11: result = pc_res;
            default: result = 'x;
        endcase
    end
    
endmodule