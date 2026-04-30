/**
* @brief hold and update pc
*
**/

module update_pc(
    input logic clk, reset_n,
    input logic [31:0] pc_next,
    output logic [31:0] pc_current
);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pc_current <= '0;
        end
        else begin
            pc_current <= pc_next;
        end
    end

endmodule