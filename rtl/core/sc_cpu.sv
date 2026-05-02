/**
* @brief handle all 5 stages in a single cycle
**/

module sc_cpu(
    input logic clk, reset_n 
);
    
    // ---signals---
    // fetch
    logic [31:0] pc_next, pc_current, alu_res, imm_res, pc_default;
    logic [1:0]  pc_src;

    // decode
    logic        reg_write, zero, lt, alu_src_a, alu_src_b, mem_write;
    logic [31:0] result, rs1_data, rs2_data, instruction, imm;
    logic [2:0]  res_src;
    logic [2:0]  mem_s_type;
    logic [3:0]  alu_op;
    
    // execute
    logic [31:0] a, b;

    // memory access
    logic [31:0] read_data;
    // csr
    logic [31:0] csr_res, csr_pc;
    logic [3:0] exc_cause;
    logic [2:0] csr_op;
    logic trap_taken, csr_write, time_itr;
    // ---instances---
    // fetch
    update_pc update_pc(
        .clk(clk),
        .reset_n(reset_n), 
        .pc_next(pc_next), 
        .pc_current(pc_current) //output
    );

    assign imm_res = pc_current + imm;

    next_pc next_pc(
        .alu_res(alu_res),
        .imm_res(imm_res),
        .csr_pc(csr_pc),
        .pc_current(pc_current),
        .pc_src(pc_src),
        .trap_taken(trap_taken),
        .pc_next(pc_next), //output
        .pc_default(pc_default) //output
    );

    instruction_memory instruction_memory(
        .pc(pc_current),
        .instruction(instruction)
    );

    // decode
    register_file register_file(
        .clk(clk),
        .reset_n(reset_n),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .reg_write(reg_write),
        .result(result),
        .rs1_data(rs1_data), //output
        .rs2_data(rs2_data) //output
    );

    imm_gen imm_gen(
        .instruction(instruction),
        .imm(imm) //output
    );

    decoder decoder(
        .instruction(instruction),
        .zero(zero),
        .lt(lt),
        .reg_write(reg_write),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .mem_write(mem_write),
        .pc_src(pc_src), //output
        .res_src(res_src), //output
        .alu_op(alu_op), //output
        .mem_s_type(mem_s_type), //output
        .csr_op(csr_op), //output
        .exc_cause(exc_cause), //output
        .csr_write(csr_write) //output
    );

    //execute
    operand_select operand_select(
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .pc_current(pc_current),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .a(a), //output
        .b(b) //output
    );

    alu_top alu_top(
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(alu_res), //output
        .zero(zero), //output
        .lt(lt) //output
    );

    //memory access
    data_memory data_memory(
        .clk(clk),
        .reset_n(reset_n),
        .mem_write(mem_write),
        .mem_s_type(mem_s_type),
        .address(alu_res),
        .write_data(rs2_data),
        .read_data(read_data) //output
    );

    //writeback
    result_select result_select(
        .alu_res(alu_res),
        .imm_res(imm),
        .mem_res(read_data),
        .pc_res(pc_default),
        .csr_res(csr_res),
        .res_src(res_src),
        .result(result)
    );

    //csr
    csr_regfile csr_regfile(
        .clk(clk),
        .reset_n(reset_n),
        .instruction(instruction),
        .pc_current(pc_current),
        .rs1_data(rs1_data),
        .exc_cause(exc_cause),
        .csr_op(csr_op),
        .csr_write(csr_write),
        .time_itr(time_itr),
        .trap_taken(trap_taken),
        .csr_res(csr_res), //output
        .csr_pc(csr_pc) //output
    );

endmodule