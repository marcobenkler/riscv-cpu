bind pl_cpu assert_fwd_integration u_fwd_props (
    .clk          (clk),
    .reset_n      (reset_n),
    .rs1_EX       (id_ex_out.rs1),
    .rs2_EX       (id_ex_out.rs2),
    .rd_MEM       (ex_mem_out.rd),
    .reg_write_MEM(ex_mem_out.reg_write),
    .rd_WB        (mem_wb_out.rd),
    .reg_write_WB (mem_wb_out.reg_write),
    .fwd_sel_a    (forward_a),
    .fwd_sel_b    (forward_b)
);