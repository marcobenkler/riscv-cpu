module pl_cpu 
    import pipeline_pkg::*;
(
    input logic clk,
    input logic reset_n
);

    if_id_t if_id_in;
    if_id_t if_id_out;

    id_ex_t id_ex_in;
    id_ex_t id_ex_out;

    ex_mem_t ex_mem_in;
    ex_mem_t ex_mem_out;

    mem_wb_t mem_wb_in;
    mem_wb_t mem_wb_out;


    // IF Stage
    update_pc update_pc(
        .clk(clk),
        .reset_n(reset_n), 
        .pc_next(pc_next), 
        .pc_current(if_id_in.pc_current) //output
    );

    assign imm_res = pc_current + imm;

    next_pc next_pc(
        .alu_res(mem_wb_out.alu_res),
        .imm_res(imm_res),
        .csr_pc(csr_pc),
        .pc_current(if_id_in.pc_current),
        .pc_src(pc_src),
        .trap_taken(trap_taken),
        .stall(stall),
        .pc_next(pc_next), //output
        .pc_default(if_id_in.pc_default) //output
    );

    instruction_memory instruction_memory(
        .pc(pc_current),
        .instruction(if_id_in.instruction)
    );

    pipeline_reg #(.T(if_id_t)) if_id_reg (
        .clk(clk),
        .reset_n(reset_n),
        .in(if_id_in),
        .out(if_id_out)
    );

    // ID Stage
    register_file register_file(
        .clk(clk),
        .reset_n(reset_n),
        .rs1(if_id_out.instruction[19:15]),
        .rs2(if_id_out.instruction[24:20]),
        .rd(mem_wb_out.instruction[11:7]),
        .reg_write(mem_wb_out.reg_write),
        .result(mem_wb_out.result),
        .stall(stall),
        .rs1_data(id_ex_in.rs1_data), //output
        .rs2_data(id_ex_in.rs2_data) //output
    );

    imm_gen imm_gen(
        .instruction(if_id_out.instruction),
        .imm(id_ex_in.imm) //output
    );

    decoder decoder(
        .instruction(if_id_out.instruction),
        .zero(zero),
        .lt(lt),
        .reg_write(id_ex_in.reg_write), //output
        .alu_src_a(id_ex_in.alu_src_a), //output
        .alu_src_b(id_ex_in.alu_src_b), //output
        .mem_write(id_ex_in.mem_write), //output
        .pc_src(id_ex_in.pc_src), //output
        .res_src(id_ex_in.res_src), //output
        .alu_op(id_ex_in.alu_op), //output
        .mul_op(id_ex_in.mul_op), //output
        .div_op(id_ex_in.div_op), //output
        .mem_s_type(id_ex_in.mem_s_type), //output
        .ex_src(id_ex_in.ex_src), //output
        .csr_op(id_ex_in.csr_op), //output
        .exc_cause(id_ex_in.exc_cause), //output
        .csr_write(id_ex_in.csr_write) //output
    );

    // Straight transmission between register
    assign id_ex_in.pc_current = if_id_out.pc_current;
    assign id_ex_in.pc_default = if_id_out.pc_default;
    assign id_ex_in.instruction = if_id_out.instruction;

    pipeline_reg #(.T(id_ex_t)) id_ex_reg (
        .clk(clk),
        .reset_n(reset_n),
        .in(id_ex_in),
        .out(id_ex_out)
    );

endmodule