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
    output logic pc_stall,
    output logic if_id_stall,
    output logic if_id_flush,
    output logic id_ex_stall,
    output logic id_ex_flush,
    output logic ex_mem_stall,
    output logic ex_mem_flush
);
    logic div_stall;
    logic load_use_hazard;
    logic mem_read;

    assign div_stall = is_div && !srt_done;

    assign mem_read = res_src == 3'b001;
    assign load_use_hazard = mem_read && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2);

    always_comb begin
        pc_stall     = div_stall || load_use_hazard;
        if_id_stall  = div_stall || load_use_hazard;
        id_ex_stall  = div_stall;
        ex_mem_stall = div_stall;

        if_id_flush  = pc_src != 2'b00 || trap_taken || mret_taken; //pc_src != 0 means branch taken
        id_ex_flush  = pc_src != 2'b00 || trap_taken || mret_taken || (load_use_hazard && !div_stall);
        ex_mem_flush = trap_taken || mret_taken;

        if (if_id_flush) if_id_stall = 1'b0;
        if (id_ex_flush) id_ex_stall = 1'b0;
        if (ex_mem_flush) ex_mem_stall = 1'b0;
        if (trap_taken || mret_taken) pc_stall = 1'b0;
    end


endmodule