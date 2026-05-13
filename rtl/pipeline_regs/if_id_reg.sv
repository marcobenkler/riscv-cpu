/**
* @brief store all important values for IF/ID re
**/

module if_id_reg
    import pipeline_pkg::*;
(
    input  logic   clk,
    input  logic   reset_n,
    input  logic   flush,
    input  logic   stall,
    input  if_id_t in,
    output if_id_t out
);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n || flush) 
            out <= '0;
        else if (!stall) 
            out <= in;
    end

endmodule