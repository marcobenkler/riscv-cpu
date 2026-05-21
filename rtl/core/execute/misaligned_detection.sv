module misaligned_detection(
    input  logic [2:0]  funct3,
    input  logic [31:0] alu_res,
    input  logic        mem_write,
    input  logic        mem_read,
    input  logic [1:0]  pc_src_ex,
    output logic        misaligned_load,
    output logic        misaligned_store,
    output logic        misaligned_fetch
); 

always_comb begin
    misaligned_load = 1'b0;
    misaligned_store = 1'b0;
    misaligned_fetch = 1'b0;
    if(pc_src_ex == 2'b10)
        misaligned_fetch = |alu_res[1:0];
    
    if(mem_read) begin
        case (funct3)
            3'b001: misaligned_load = alu_res[0]; //LH(U)
            3'b010: misaligned_load = |alu_res[1:0]; //LW
            default: ;
        endcase
    end
    
    if(mem_write) begin
        case (funct3)
            3'b001: misaligned_store = alu_res[0]; //SH(U)
            3'b010: misaligned_store = |alu_res[1:0]; //SW
            default: ;
        endcase
    end
end


endmodule