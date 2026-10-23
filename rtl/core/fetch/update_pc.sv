/**
* @brief hold and update pc
*
**/

module update_pc#(parameter RESET_VECTOR = 32'h0001_0000)
(
    input  logic        clk,
    input  logic        reset_n,
    input  logic [31:0] pc_next,
    input  logic        pc_stall,
    output logic [31:0] pc_current
);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pc_current <= RESET_VECTOR;
        end
        else if (!pc_stall) begin
            pc_current <= pc_next;
        end
    end

endmodule