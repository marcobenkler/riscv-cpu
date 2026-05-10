//Bruch wird über multiplikation beider Seiten gemacht R > 5/8 D => 8R > 5D
// 8 => 3 shifts
// 5 => 2 shift + D
//Damit billig und wenig Fläche

module digitSelect (
    input logic signed [31:0] R,
    input logic signed [31:0] ND,
    output logic signed [1:0] Q
);

logic signed [34:0] R8;
logic signed [34:0] D5;

assign R8 = {3'b0, R} <<< 3;
assign D5 = ({3'b0, ND} <<< 2) + {3'b0, ND};

    always_comb begin

        if (R8 >= D5)
            Q = 2'sd1;
        else if (R8 <= -D5)
            Q = -2'sd1;
        else
            Q = 2'sd0;        

    end

endmodule