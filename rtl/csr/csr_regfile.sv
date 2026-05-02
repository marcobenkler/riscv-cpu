/**
* @brief Manage entire csr block
**/

module csr_regfile(
    input  logic clk, reset_n,
    input  logic [31:0] instruction, // entire instruction vector
    input  logic [31:0] pc_current, // current pc to remember where to jump back after trap
    input  logic [31:0] rs1_data_a, // data from register[rs1]
    input  logic [2:0] csr_op, // which operation, declared by decoder
    input  logic csr_write, // enable writing in csr, declared by decoder
    input  logic time_itr, // from CLINT, timer interrupt is required
    input  logic exc_detected, // decoder tells exception was recognized
    output logic trap_taken, // override next pcr, if trap was taken
    output logic [31:0] csr_res, // output for regular register
    output logic [31:0] csr_pc // pc to jump back after trap handled
);

    logic [11:0] csr_addr;
    assign csr_addr = instruction[31:20];

    logic [31:0] csr_data;
    assign csr_data = csr_op[2] ? {27'b0, instruction[19:15]} : rs1_data_a;

    

endmodule