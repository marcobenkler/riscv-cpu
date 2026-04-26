/**
* @brief Create the instruction vector out of the pc
*
* By using the pc combine 4 byte into 1 instruction vector via comb
**/
module instruction_memory(
    input logic [31:0] pc,          ///< which instruction to take
    output logic [31:0] instruction ///< instruction vector
);

    logic [7:0] memo [255:0];
    always_comb begin
        for(int i = 0; i < 4; i++) begin
            instruction[8*i +: 8] = memo[pc + i];
        end
    end

endmodule