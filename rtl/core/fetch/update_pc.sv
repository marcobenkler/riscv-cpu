/**
* @brief hold and update pc
*
**/

module update_pc#(parameter logic [31:0] RESET_VECTOR = 32'h0001_0000)
(
    input  logic        clk,
    input  logic        reset_n,
    input  logic [31:0] pc_next,
    input  logic        pc_stall,
    input  logic [1:0]  pc_src,
    output logic [31:0] pc_current
);
    logic redirect;
    assign redirect = pc_src == 2'b01;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pc_current <= RESET_VECTOR;
        end
        else begin
            if (redirect) begin
                pc_current <= pc_next;
            end
            else if (!pc_stall) begin
                pc_current <= pc_next;
            end
        end
    end

endmodule
