/**
* @brief Decide if branch should be taken or not
**/

module branch_unit(
    input  logic [1:0] pc_src,
    input  logic [6:0] op_code,
    input  logic [2:0] funct3,
    input  logic       zero,
    input  logic       lt,
    output logic [1:0] pc_src_ex
);

    always_comb begin
        unique case (pc_src)
            2'b10: pc_src_ex = 2'b10; //JALR always taken
            2'b01: begin
                if(op_code == 7'b1100011) begin //B Type
                    unique case (funct3)
                        3'b000: pc_src_ex = zero  ? 2'b01 : 2'b00; // BEQ
                        3'b001: pc_src_ex = !zero ? 2'b01 : 2'b00; // BNE
                        3'b100: pc_src_ex = lt    ? 2'b01 : 2'b00; // BLT
                        3'b101: pc_src_ex = !lt   ? 2'b01 : 2'b00; // BGE
                        3'b110: pc_src_ex = lt    ? 2'b01 : 2'b00; // BLTU
                        3'b111: pc_src_ex = !lt   ? 2'b01 : 2'b00; // BGEU
                        default: pc_src_ex = 2'b00;
                    endcase
                end else
                    pc_src_ex = 2'b01; // JAL always take
            end
            default: pc_src_ex = 2'b00;
        endcase        
    end

endmodule