module remainder (
    input  logic signed [31:0] R, ND,
    input  logic signed [1:0]  Q,
    output logic signed [31:0] RNEW
);

    always_comb begin
        case (Q)
            2'sd1:   RNEW = (R << 1) - ND;
            2'sd0:   RNEW = (R << 1);      
           -2'sd1:   RNEW = (R << 1) + ND;
            default: RNEW = 'x;
        endcase
    end

endmodule