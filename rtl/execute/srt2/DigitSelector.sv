//Bruch wird über multiplikation beider Seiten gemacht R > 5/8 D => 8R > 5D
// 8 => 3 shifts
// 5 => 2 shift + D
//Damit billig und wenig Fläche

module digitSelect (
    input logic signed [31:0] R,
    input logic signed [31:0] ND,
    output logic signed [1:0] Q
);

//Adjust inputs no overflow garanteed, 32 bits thats few million
logic signed [34:0] R8;
logic signed [34:0] D5;

assign R8 = R <<< 3; //<<< oder << ist hier egal fährt ja nur nach links
assign D5 = (ND <<< 2) + ND; //+ ist stärler als <<

    always_comb begin

        if (R8 >= D5)
            Q = 2'sd1;  //immer mit signed machen nicht nur d
        else if (R8 <= -D5)
            Q = -2'sd1;
        else
            Q = 2'sd0;        

    end

endmodule