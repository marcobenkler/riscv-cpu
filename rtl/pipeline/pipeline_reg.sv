/**
* @brief store all important values for IF/ID re
**/

module pipeline_reg#(
    parameter type T = logic
)(
    input  logic   clk,
    input  logic   reset_n,
    input  logic   flush,
    input  logic   stall,
    input  T       in,
    output var T   out
);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n || flush) 
            out <= '0;
        else if (!stall) 
            out <= in;
    end

endmodule