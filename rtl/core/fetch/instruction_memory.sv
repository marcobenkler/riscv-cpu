/**
* @brief Create the instruction vector out of the pc
*
* By using the pc combine 4 byte into 1 instruction vector via comb
**/
module instruction_memory #(
    parameter MEM_DEPTH = 1024 // might be too big for BRAM
)(
    input  logic [31:0] pc,          ///< which instruction to take
    input  logic        clk,
    output logic [31:0] instruction ///< instruction vector
);

    logic [31:0] memo [0:MEM_DEPTH-1];

    initial begin
        $readmemh("/opt/projects/riscv-cpu/program.hex", memo);
    end

    always_ff @(posedge clk) begin
        instruction <= memo[pc[11:2]];
    end

endmodule