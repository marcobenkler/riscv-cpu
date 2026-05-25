/**
* @brief Create the instruction vector out of the pc
*
* By using the pc combine 4 byte into 1 instruction vector via comb
**/
module instruction_memory #(
    parameter MEM_DEPTH = 4096 // might be too big for BRAM
)(
    input  logic        clk,
    input  logic        stall,
    input  logic [31:0] pc,          ///< which instruction to take
    output logic [31:0] instruction ///< instruction vector
);

    logic [31:0] memo [0:MEM_DEPTH-1];
    /* Synthesis*/
    initial begin
        $readmemh("/opt/projects/riscv-cpu/program.hex", memo);
    end
    /**/

    always_ff @(posedge clk) begin
        if (!stall) instruction <= memo[pc[$clog2(MEM_DEPTH)+1:2]];
    end

endmodule