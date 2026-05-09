/**
* @brief select the correct result (alu, imm, pc, mem)
**/

module result_select (
    input  logic [31:0] alu_res, mul_res, imm_res, mem_res, pc_res, csr_res,
    input  logic [2:0]  res_src,
    input  logic [1:0]  ex_src,
    output logic [31:0] result
);
    logic [31:0] ex_res;

    always_comb begin
        case (ex_src)
            2'b00: ex_res = alu_res;
            2'b01: ex_res = mul_res;
            default: ;
        endcase
    end

    always_comb begin
        case (res_src) 
            3'b000: result = ex_res;
            3'b001: result = mem_res;
            3'b010: result = imm_res;
            3'b011: result = pc_res;
            3'b100: result = csr_res;
            default: result = 'x;
        endcase
    end
    
endmodule