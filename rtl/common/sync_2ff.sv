module sync_2ff #(parameter bit ResetValue = 1'b1)
(
    input  logic clk,
    input  logic rst_n,
    input  logic data_in,
    output logic data_out
);

    (* ASYNC_REG = "TRUE" *) logic meta, sync;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            meta     <= ResetValue;
            sync     <= ResetValue;
        end else begin
            meta <= data_in;
            sync <= meta;
        end
    end

    assign data_out = sync;

endmodule
