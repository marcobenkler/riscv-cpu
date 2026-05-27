/**
* @brief ALU operand selection
*
* Selects the correct operands out of the Instruction vector
*
**/

module operand_select(
    input  logic [31:0] rs1_data, 
    input  logic [31:0] rs2_data,    ///< data from storage
    input  logic [31:0] imm,
    input  logic [31:0] pc_current,  ///< immediate from instruction vector
    input  logic        alu_src_a,
    input  logic        alu_src_b,   ///< decide if imm or rs2_data is required
    input  logic [1:0]  forward_a,
    input  logic [1:0]  forward_b,
    input  logic [31:0] ex_mem_data,
    input  logic [31:0] mem_wb_data,
    output logic [31:0] a, b         ///< inputs for alu module
);

    always_comb begin
        if (alu_src_a) a = pc_current;
        else begin
            case (forward_a)
                2'b00: a = rs1_data;
                2'b01: a = mem_wb_data;
                2'b10: a = ex_mem_data;
                default: a = 'x;
            endcase
        end
        if(alu_src_b) b = imm;
        else begin
            case (forward_b)
                2'b00: b = rs2_data;
                2'b01: b = mem_wb_data;
                2'b10: b = ex_mem_data;
                default: b = 'x;
            endcase
        end
    end

endmodule