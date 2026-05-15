/**
* @brief Manage unresolvable hazards like load use or branches
**/

module hazard_unit(
    input  logic [4:0] rs1_id_ex,
    input  logic [4:0] rs2_ed_ex,
    input  logic       ex_mem_read

    input  logic is_div,     
    input  logic srt_done,     

    output logic pc_stall,
    output logic if_id_stall,
    output logic id_ex_stall,
    output logic ex_mem_stall,
);

    assign div_stall = is_div && !srt_done;

    always_comb begin
        pc_stall = div_stall;
        if_id_stall = div_stall;
        id_ex_stall = div_stall;
        ex_mem_stall = div_stall;
    end

endmodule