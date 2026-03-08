/**
* @brief ALU control unit
*
* Handle all alu sub-units
*
*/

module alu_top(
    input   logic [31:0] a,                     ///< first input
    input   logic [31:0] b,                     ///< second input
    input   logic [4:0]  shift,                 ///< optional shift range
    input   logic [3:0] alu_op,    ///< op_code from decoder
    output  logic [31:0] result                 ///< operation result
);

    logic [31:0] addsub_result;
    logic [31:0] compare_result;
    logic [31:0] shift_result;
    logic [31:0] logic_result;

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

    logic        sub;
    logic [1:0]  cmp_op;
    logic [1:0]  logic_o;
    logic [1:0]  shift_op;

    always_comb begin 
        sub      = 1'b0;
        cmp_op   = 2'b00;
        logic_op  = 2'b00;
        shift_op = 2'b00;
        
        unique case (alu_op)
            ALU_ADD: sub = 1'b0;
            ALU_SUB: sub = 1'b1;
            ALU_AND: logic_op = 2'b00;
            ALU_OR:  logic_op = 2'b01;
            ALU_XOR: logic_op = 2'b10;
            ALU_SLL: shift_op = 2'b00;
            ALU_SRL: shift_op = 2'b01;
            ALU_SRA: shift_op = 2'b10;
            ALU_SLT: cmp_op = 2'b01;
            ALU_SLTU:cmp_op = 2'b10;
            default: begin
            end
        endcase
    end
    
    alu_addsub  addsub_module(.a(a), .b(b), .result(addsub_result), .sub(sub));                          //sub / add
    alu_compare compare_module(.a(a), .b(b), .result(compare_result), .cmp_op(cmp_op));                  //eq / lt / ltu/ ne
    alu_shift   shift_module(.a(a), .shift_range(shift), .result(shift_result), .shift_op(shift_op));    //sl / srl / sra      
    alu_logic   logic_module(.a(a), .b(b), .result(logic_result), .logic_op(logic_op));                  //and / or / xor

    always_comb begin
        unique case (alu_op)
            ALU_ADD, ALU_SUB:
                result = addsub_result;
            ALU_AND, ALU_OR, ALU_XOR:
                result = logic_result;
            ALU_SLL, ALU_SRL, ALU_SRA:
                result = shift_result;
            ALU_SLT, ALU_SLTU:
                result = compare_result;
            default: result = '0;
        endcase
    end


endmodule