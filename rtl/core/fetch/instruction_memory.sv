/**
* @brief Create the instruction vector out of the pc
*
* By using the pc combine 4 byte into 1 instruction vector via comb
**/
module instruction_memory #(
    parameter logic [31:0] MEM_DEPTH = 4096 // might be too big for BRAM
)(
    input  logic        clk,
    input  logic        stall,
    input  logic [31:0] pc,          ///< which instruction to take
    output logic [31:0] instruction ///< instruction vector
);

    (* rom_style = "block" *) logic [31:0] memo [MEM_DEPTH];
    `ifndef SYNTHESIS
    initial begin
        string imem_file;
        if ($value$plusargs("iMEM=%s", imem_file))
            $readmemh(imem_file, memo);
    end
    `endif

    always_ff @(posedge clk) begin
        if (!stall) instruction <= memo[pc[$clog2(MEM_DEPTH)+1:2]];
    end

endmodule
