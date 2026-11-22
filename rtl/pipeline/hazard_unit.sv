/**
* @brief Manage unresolvable hazards like load use or branches
**/

module hazard_unit(
    input  logic [4:0] if_id_rs1,
    input  logic [4:0] if_id_rs2,
    input  logic [4:0] id_ex_rd,
    input  logic [2:0] res_src,
    input  logic [1:0] pc_src,
    input  logic is_div,
    input  logic srt_done,
    input  logic reg_write,
    input  logic trap_taken,
    input  logic mret_taken,
    input  logic lsu_stall,
    input  logic mul_stall,
    output logic pc_stall,
    output logic if_id_stall,
    output logic if_id_flush,
    output logic id_ex_stall,
    output logic id_ex_flush,
    output logic ex_mem_stall,
    output logic ex_mem_flush,
    output logic mem_wb_flush
);
    logic div_stall;
    logic load_use_hazard;
    logic mem_read;

    logic branch_taken;

    assign div_stall = is_div && !srt_done;

    // pc_src is the latched branch decision (branch is in MEM stage)
    assign branch_taken = pc_src != 2'b00 && !lsu_stall;

    assign mem_read = res_src == 3'b001;
    assign load_use_hazard = mem_read && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2);

    always_comb begin
        pc_stall     = mul_stall || div_stall || load_use_hazard || lsu_stall;
        if_id_stall  = mul_stall || div_stall || load_use_hazard || lsu_stall;
        id_ex_stall  = mul_stall || div_stall || lsu_stall;
        ex_mem_stall = lsu_stall;
        // ex_mem_stall = div_stall; legacy

        //IMPORTANT with flushes. Only flush caused by stall, if the following stages are not stalling themselfes
        //else valid data is deleted
        //Following common convention stall all what's left of your stall source and flush only the right neighbr reg
        //Flushes flush all whats left (before) their stage like trap and mret are located in mem stage

        if_id_flush  = branch_taken || trap_taken || mret_taken;

        // load_use_hazard && !div_stall: l_u_h is pulled by LSU, but div can compute further
        id_ex_flush  = (branch_taken || trap_taken || mret_taken ||
                       (load_use_hazard && !div_stall && !lsu_stall && !mul_stall)); //&&
                       //(!lsu_stall && !trap_taken && !mret_taken); // keep in mind, could be wrong in edge cas

        //div_stall: Without bubble the older instr before div is handed several times
        //from ex/mem to mem/wb and retired several times
        //branch_taken: instr in EX is on the wrong path (branch already in MEM)
        ex_mem_flush = branch_taken || trap_taken || mret_taken || ((div_stall || mul_stall) && !lsu_stall);

        mem_wb_flush = lsu_stall;

        if (if_id_flush) if_id_stall = 1'b0;
        if (id_ex_flush) id_ex_stall = 1'b0;
        if (ex_mem_flush) ex_mem_stall = 1'b0;
        // if (mem_wb_flush) mem_wb_stall = 1'b0;
        if (trap_taken || mret_taken || branch_taken) pc_stall = 1'b0;
    end


endmodule
