/**
* @brief ALU operand selection
*
* Selects the correct operands out of the Instruction vector
*
**/

module operand_select(
    input   logic [31:0] rs1_data, rs2_data,    ///< data from storage
    input   logic [31:0] imm, pc_current                   ///< immediate from instruction vector
    input   logic alu_src_a, alu_src_b                      ///< decide if imm or rs2_data is required
    output  logic [31:0] a, b                   ///< inputs for alu module
);

    always_comb begin
        if (alu_src_a) a = pc_current;
        else a = rs1_data;
        if(alu_src) b = imm;
        else b = rs2_data;
    end

endmodule