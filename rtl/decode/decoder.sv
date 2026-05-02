/**
* @brief Decompose op-code and set control bits
*
**/

module decoder(
    input  logic [31:0] instruction, ///< entire instruction vector
    input  logic zero, lt,  ///< zero flag from ALU for B-Type
    output logic reg_write, alu_src_a, alu_src_b, mem_write,///< single bit controls
    output logic [1:0] pc_src, ///< 00 = default +4, 01 = pc = imm, 10 = rs1 + imm
    output logic [1:0] res_src, ///< 00 = alu, 01 = mem, 10 = imm, 11 = pc + 4
    output logic [3:0] alu_op, ///< alu controller
    output logic [2:0] mem_s_type ///< tell data_memory which S-Type is used
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
        alu_op = 'x;
        pc_src = 2'b00;
        mem_write = 1'b0;
        mem_s_type = 'x;
        res_src = 'x;
        reg_write = 'x;
        alu_src_a = 1'b0;
        alu_src_b = 'x;
        case (op_code)
            5'b01100: begin // R-Type
                reg_write = 1'b1; // Single bit controlls are Type specific
                alu_src_b = 1'b0;
                res_src = 2'b00;
                case (funct3) 
                    3'b000: case (funct7)
                        7'b0000000: alu_op = ALU_ADD;
                        7'b0100000: alu_op = ALU_SUB;
                        default: ;
                    endcase
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: case (funct7)
                        7'b0000000: alu_op = ALU_SRL;
                        7'b0100000: alu_op = ALU_SRA;
                        default: ;
                    endcase
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                    default: ;
                endcase
            end
            5'b00100: begin // I-Type
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                res_src = 2'b00;
                case (funct3)
                    3'b000: alu_op = ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: case (funct7)
                                7'b0000000: alu_op = ALU_SRL;
                                7'b0100000: alu_op = ALU_SRA;
                                default: ;
                            endcase
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                    default: ;
                endcase
            end
            5'b00000: begin // I-Type
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                res_src = 2'b01;
                alu_op = ALU_ADD;
                mem_s_type = funct3;
            end
            5'b11000: begin //B-Type
                reg_write = 1'b0;
                alu_src_b = 1'b0;
                res_src = 'x;
                case (funct3) 
                    3'b000: begin 
                        pc_src = {1'b0, zero};
                        alu_op = ALU_SUB;
                    end
                    3'b001: begin
                        pc_src = {1'b0, !zero};
                        alu_op = ALU_SUB;
                    end
                    3'b100: begin
                        pc_src = {1'b0, lt};
                        alu_op = ALU_SLT;
                    end
                    3'b101: begin
                        pc_src = {1'b0, !lt};
                        alu_op = ALU_SLT;
                    end
                    3'b110: begin
                        pc_src = {1'b0, lt};
                        alu_op = ALU_SLTU;
                    end
                    3'b111: begin
                        pc_src = {1'b0, !lt};
                        alu_op = ALU_SLTU;
                    end
                    default: ;
                endcase 
            end
            5'b01101: begin //U-Type
                reg_write = 1'b1;
                alu_src_b = 'x;
                res_src = 2'b10;
            end
            5'b00101: begin //U-Type
                reg_write = 1'b1;
                alu_src_a = 1'b1; // Take PC instead of rs1
                alu_src_b = 1'b1;
                alu_op = ALU_ADD;
                res_src = 2'b00;
            end
            5'b01000: begin //S-Type Decide in memory block which S-Type specifically
                reg_write = 1'b0;
                alu_src_b = 1'b1;
                mem_write = 1'b1;
                res_src = 'x;
                alu_op = ALU_ADD;
                mem_s_type = funct3;
            end
            5'b11011: begin //J-Type
                reg_write = 1'b1;
                pc_src = 2'b01;
                res_src = 2'b11;
            end
            5'b11001: begin //JALR
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                pc_src = 2'b10;
                res_src = 2'b11;
                alu_op = ALU_ADD;
            end
            default: ;
        endcase        
    end

endmodule
