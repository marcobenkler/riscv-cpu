module digitSelect (
    input  logic signed [32:0] R,
    input  logic signed [32:0] ND,
    output logic signed [1:0]  Q
);

logic signed [35:0] R3;
logic signed [35:0] D;

// 3R >= D  <=>  R >= 1/3·D 
assign R3 = {{3{R[32]}}, R} + ({{3{R[32]}}, R} <<< 1);
assign D  = {{3{ND[32]}}, ND};

always_comb begin
    if      (R3 >= D)   Q =  2'sd1;
    else if (R3 <= -D)  Q = -2'sd1;
    else                Q =  2'sd0;
end

endmodule