module uart_baud #(
    parameter clk_freq = 100_000_000,
    parameter baud_rate = 115_200
)(
    input  logic clk,
    input  logic reset_n,
    output logic baud_tick
);

    localparam BAUD_DIV = clk_freq / baud_rate;

    logic [10:0] counter;
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n || counter == BAUD_DIV[10:0] -1) counter <= '0;
        else counter <= counter + 1;
    end

    assign baud_tick = (counter == BAUD_DIV[10:0] - 1);






    property  baud_tick_only_once;
        @(posedge clk) disable iff (!reset_n)
        $rose(baud_tick) |=> $fell(baud_tick); 
    endproperty

    property reset_correct;
        @(posedge clk)
        $fell(reset_n) |=> (counter == 0);
    endproperty

    assert property (baud_tick_only_once) else $error("Baud tick is longer than on tick");
    assert property (reset_correct) else $error("Reset does not work properly");

    cover property (baud_tick_only_once);
    cover property (reset_correct);
endmodule