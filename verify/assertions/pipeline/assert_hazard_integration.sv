module asser_hazard_integration(
    input logic       clk,
    input logic       reset_n,
    input logic [4:0] id_ex_rd,
    input logic [4:0] if_id_rs1,
    input logic [4:0] if_id_rs2,
    input logic [2:0] res_src,
    input logic       is_div,
    input logic       srt_done,
    input logic       id_ex_id_ecall,
    input logic       id_ex_reg_write,
    input logic       if_id_stall,
    input logic       id_ex_stall,
    input logic       ex_mem_stall,
    input logic       pc_stall
);

    logic div_stall;
    assign div_stall = is_div && !srt_done;

    property load_use_flush_rs1;
        @(posedge clk) disable iff (!reset_n)
        (id_ex_rd == if_id_rs1 && res_src == 3'b001)
        |=> !(id_ex_id_ecall || id_ex_reg_write);
    endproperty

    property load_use_flush_rs2;
        @(posedge clk) disable iff (!reset_n)
        (id_ex_rd == if_id_rs2 && res_src == 3'b001)
        |=> !(id_ex_id_ecall || id_ex_reg_write);
    endproperty

    property no_stall_without_reason;
        @(posedge clk) disable iff (!reset_n)
        (div_stall || (res_src == 3'b001 && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2)))
        |-> (pc_stall || if_id_stall || id_ex_stall || ex_mem_stall);
    endproperty

    assert property (load_use_flush_rs1) else $error("LOAD USE RS1 ERROR");
    assert property (load_use_flush_rs2) else $error("LOAD USE RS2 ERROR");
    assert property (no_stall_without_reason) else $error("EXECUTED STALL WITHOUT REASON");

    cover  property (load_use_flush_rs1);
    cover  property (load_use_flush_rs2);
    cover  property (no_stall_without_reason);

endmodule