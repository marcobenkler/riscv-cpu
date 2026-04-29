/**
* @brief Decompose op-code and set control bits
*
**/

module decoder(
    input  logic [31:0] instruction, ///< entire instruction vector
    output logic reg_write, alu_src, res_src, ///< single bit controls
    output logic [3:0] alu_op ///< alu controller
);
    typedef enum logic [3:0] {
        ALU_ADD,
        ALU_SUB,
        ALU_AND,
        ALU_OR,
        ALU_XOR,
        ALU_SLL,
        ALU_SRL,
        ALU_SRA,
        ALU_SLT,
        ALU_SLTU
    } alu_op_e;

    logic [4:0] op_code;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign op_code = instruction[6:2];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];    

    always_comb begin
        case (op_code)
            5'b01100: begin // R-Type
                reg_write = 1'b1; // Single bit controlls are Type specific
                alu_src = 1'b0;
                res_src = 1'b0;
                case (funct3) 
                    3'b000: case (funct7)
                        7'b0000000: alu_op = ALU_ADD;
                        7'b0100000: alu_op = ALU_SUB;
                    endcase
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: case (funct7)
                        7'b0000000: alu_op = ALU_SRL;
                        7'b0100000: alu_op = ALU_SRA;
                    endcase
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                endcase
            end
            5'b00100: begin
                reg_write = 1'b1;
                alu_src = 1'b0;
                res_src = 1'b0;
            end
        endcase        
    end

endmodule
