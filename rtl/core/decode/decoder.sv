/**
* @brief Decompose op-code and set control bits
*
**/

module decoder
    import alu_pkg::*;
(
    input  logic [31:0] instruction, ///< entire instruction vector
    output logic reg_write, alu_src_a, alu_src_b, mem_write,///< single bit controls
    output logic [1:0] pc_src, ///< 00 = default +4, 01 = pc = imm, 10 = rs1 + imm
    output logic [2:0] res_src, ///< 000 = alu, 001 = mem, 010 = imm, 011 = pc + 4, 100 = csr
    output logic [3:0] alu_op, ///< alu controller
    output logic [1:0] mul_op, ///< mul controller
    output logic [1:0] div_op, ///< div controller
    output logic [2:0] mem_s_type, ///< tell data_memory which S-Type is used
    output logic [1:0] ex_src, ///< alu, mul or div result
    //CSR
    output logic [2:0] csr_op, ///< op code for csr module
    //output logic [3:0] exc_cause,
    output logic id_ecall,
    output logic id_ebreak,
    output logic id_mret,
    output logic id_illegal_instr,
    output logic csr_write
);

    logic [4:0] op_code;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign op_code = instruction[6:2];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];   

    assign id_mret = (instruction == 32'h30200073); 

    always_comb begin
        alu_op = 'x;
        mem_s_type = 'x;
        res_src = 'x;
        reg_write = 'x;
        alu_src_b = 'x;
        pc_src = 2'b00;
        mem_write = 1'b0;
        alu_src_a = 1'b0;
        mem_s_type = funct3;
        mul_op = 'x;
        div_op = 'x;
        ex_src = 2'b00;
        //CSR
        csr_op = funct3;
        csr_write = '0;
        id_ecall = 1'b0;
        id_ebreak = 1'b0;
        id_illegal_instr = 1'b0;
        case (op_code)
            5'b01100: begin // R-Type
                reg_write = 1'b1; // Single bit controlls are Type specific
                alu_src_b = 1'b0;
                res_src = 3'b000;
                case (funct3) 
                    3'b000: case (funct7)
                        7'b0000000: alu_op = ALU_ADD;
                        7'b0100000: alu_op = ALU_SUB;
                        7'b0000001: begin
                            mul_op = MUL;
                            ex_src = 2'b01;
                        end
                        default: ;
                    endcase
                    3'b001: case (funct7)
                        7'b0000000: alu_op = ALU_SLL;
                        7'b0000001: begin
                            mul_op = MULH;
                            ex_src = 2'b01;
                        end
                        default: ;
                    endcase
                    3'b010: case(funct7)
                        7'b0000000: alu_op = ALU_SLT;
                        7'b0000001: begin
                            mul_op = MULHSU;
                            ex_src = 2'b01; 
                        end
                        default: ;
                    endcase
                    3'b011: case(funct7)
                        7'b0000000: alu_op = ALU_SLTU;
                        7'b0000001: begin
                            mul_op = MULHU;
                            ex_src = 2'b01;
                        end
                        default: ;
                    endcase
                    3'b100: case (funct7)
                        7'b0000000: alu_op = ALU_XOR;
                        7'b0000001: begin
                            div_op = DIV;
                            ex_src = 2'b10;
                        end
                        default: ;
                    endcase
                    3'b101: case (funct7)
                        7'b0000000: alu_op = ALU_SRL;
                        7'b0100000: alu_op = ALU_SRA;
                        7'b0000001: begin
                            div_op = DIVU;
                            ex_src = 2'b10;
                        end
                        default: ;
                    endcase
                    3'b110: case (funct7)
                        7'b0000000: alu_op = ALU_OR;
                        7'b0000001: begin
                            div_op = REM;
                            ex_src = 2'b10;
                        end 
                        default: ;
                    endcase
                    3'b111: case(funct7)
                        7'b0000000: alu_op = ALU_AND;
                        7'b0000001: begin
                            div_op = REMU;
                            ex_src = 2'b10;
                        end
                        default: ;
                    endcase
                    default: ;
                endcase
            end
            5'b00100: begin // I-Type
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                res_src = 3'b000;
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
                res_src = 3'b001;
                alu_op = ALU_ADD;
            end
            5'b11000: begin //B-Type
                reg_write = 1'b0;
                alu_src_b = 1'b0;
                pc_src = 2'b01;
                res_src = 'x;
                case (funct3)
                    3'b000: alu_op = ALU_SUB;
                    3'b001: alu_op = ALU_SUB;
                    3'b100: alu_op = ALU_SLT;
                    3'b101: alu_op = ALU_SLT;
                    3'b110: alu_op = ALU_SLTU;
                    3'b111: alu_op = ALU_SLTU;
                    default: ;
                endcase
            end
            5'b01101: begin //U-Type
                reg_write = 1'b1;
                alu_src_b = 'x;
                res_src = 3'b010;
            end
            5'b00101: begin //U-Type
                reg_write = 1'b1;
                alu_src_a = 1'b1; // Take PC instead of rs1
                alu_src_b = 1'b1;
                alu_op = ALU_ADD;
                res_src = 3'b000;
            end
            5'b01000: begin //S-Type Decide in memory block which S-Type specifically
                reg_write = 1'b0;
                alu_src_b = 1'b1;
                mem_write = 1'b1;
                res_src = 'x;
                alu_op = ALU_ADD;
            end
            5'b11011: begin //J-Type
                reg_write = 1'b1;
                pc_src = 2'b01;
                res_src = 3'b011;
            end
            5'b11001: begin //JALR
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                pc_src = 2'b10;
                res_src = 3'b011;
                alu_op = ALU_ADD;
            end
            5'b11100: begin // CSR
                case (funct3) 
                    3'b000: begin
                        case (instruction[20])
                            1'b0: id_ecall = 1'b1; ///< ECALL
                            1'b1: id_ebreak = 1'b1; ///< EBREAK
                        endcase
                    end
                    default: begin
                        csr_write = 1'b1;
                        reg_write = 1'b1;
                        res_src = 3'b100;
                    end
                endcase
            end
            default: begin
                id_illegal_instr = 1'b1; ///< Illegal instruction
            end
        endcase        
    end

endmodule
