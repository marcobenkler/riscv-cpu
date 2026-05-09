/**
* @brief Instruction memory — synchronous read for BRAM inference
* NOTE: Adds 1 cycle read latency vs original combinational design
**/
module instruction_memory #(
    parameter MEM_DEPTH = 255
)(
    input  logic        clk,
    input  logic [31:0] pc,
    output logic [31:0] instruction
);
    (* ram_style = "block" *)
    logic [31:0] mem [0:MEM_DEPTH/4];

    initial $readmemh("/opt/projects/riscv-cpu/rtl/core/fetch/program.hex", mem);

    always_ff @(posedge clk)
        instruction <= mem[pc[31:2]];

endmodule
