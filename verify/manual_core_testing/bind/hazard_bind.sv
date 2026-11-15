bind pl_cpu asser_hazard_integration u_hazard_propts (
    .clk(clk),
    .reset_n(reset_n),
    .id_ex_rd(id_ex_out.instruction[11:7]),
    .if_id_rs1(if_id_out.rs1),
    .if_id_rs2(if_id_out.rs2),
    .res_src(id_ex_out.res_src),
    .is_div(is_div),
    .srt_done(srt_done),
    .id_ex_id_ecall(id_ex_out.id_ecall),
    .id_ex_reg_write(id_ex_out.reg_write),
    .if_id_stall(if_id_stall),
    .id_ex_stall(id_ex_stall),
    .ex_mem_stall(ex_mem_stall),
    .pc_stall(pc_stall)
);