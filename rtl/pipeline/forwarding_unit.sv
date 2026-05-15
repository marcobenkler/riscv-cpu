/**
* @brief Detect resolvable hazards and solve them comb 
*
* Forward_x convention: 00 = reg_file 10 = ex/mem 01 mem/wb
**/

module forwarding_unit(
    input  logic [4:0] rs1_id_ex,
    input  logic [4:0] rs2_id_ex,

    input  logic [4:0] rd_ex_mem,
    input  logic       reg_write_ex_mem,

    input  logic [4:0] rd_mem_wb,
    input  logic       reg_write_mem_wb,

    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

    always_comb begin
        if (reg_write_ex_mem && rd != 5'b0 && rs1_id_ex == rd_ex_mem)
            forward_a = 2'b10;
        else if (reg_write_mem_wb && rd != 5'b0 && rs1_id_ex == rd_mem_wb)
            forward_a = 2'b01;
        else
            forward_a = 2'b00; 
    end

    always_comb begin
        if (reg_write_ex_mem && rd != 5'b0 && rs2_id_ex == rd_ex_mem)
            forward_b = 2'b10;
        else if (reg_write_mem_wb && rd != 5'b0 && rs2_id_ex == rd_mem_wb)
            forward_b = 2'b01;
        else
            forward_b = 2'b00; 
    end


endmodule