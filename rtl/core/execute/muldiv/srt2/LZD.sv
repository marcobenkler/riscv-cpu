//Tree-Implementation, ist wie binary-search
//Rekursion geht mit den drecks gratis simulatoren nicht

module LZD32 (
    input logic[31:0] D,
   output logic[5:0]  LZ
);
    //Debugging
    initial $display("LZD32 loaded");

    initial begin //monitor gibts nur einmal, der im 32 überschreibt einfach alles
    $monitor("32: t=%0t D=%h | upper=%h lower=%h | lz_up=%0d lz_lo=%0d | LZ=%0d",
             $time, D, upper, lower, lz_upper, lz_lower, LZ);
    end


    //Halbieren und schauen wo die 1 ist
    //==Falsch==// das sind einmalige initialisierungen keine drahtverbindungen
    //logic [15:0] upper; D[31:16];
    //logic [15:0] lower; D[15:0];
    //==Falsch==//

    logic [15:0] upper;
    logic [15:0] lower;

    assign upper = D[31:16];
    assign lower = D[15:0];
    //Prüfen, ob oben oder unten 0 kanns nie sein, ist ja teiler bei Division später
    assign isupper = |upper; //generell mit assign arbeiten und nicht direkten Initialisierungen sonst blockierts
    assign islower = |lower;

    //Jetzt lokale LZ bestimmen
    logic [4:0] lz_upper;
    logic [4:0] lz_lower;

    LZD16 u_lzd_upper (.D(upper), .LZ(lz_upper));
    LZD16 u_lzd_lower (.D(lower), .LZ(lz_lower));

    assign LZ = (D == 0)    ? 32 :
                isupper     ? lz_upper : 
                              (16 + lz_lower);

endmodule

module LZD16 (
    input logic[15:0] D,
   output logic[4:0] LZ
);

    //Halbieren und schauen wo die 1 ist
    logic [7:0] upper;
    logic [7:0] lower;

    assign upper = D[15:8];
    assign lower = D[7:0];
    
    //Prüfen, ob oben oder unten 0 kanns nie sein, ist ja teiler bei Division später
    assign isupper = |upper;
    assign islower = |lower;

    //Jetzt lokale LZ bestimmen
    logic [3:0] lz_upper;
    logic [3:0] lz_lower;

    LZD8 u_lzd_upper (.D(upper), .LZ(lz_upper));
    LZD8 u_lzd_lower (.D(lower), .LZ(lz_lower));

    assign LZ = isupper ? lz_upper : (8 + lz_lower);

endmodule

module LZD8 (
    input logic[7:0] D,
   output logic[3:0] LZ
);

    //Halbieren und schauen wo die 1 ist
    logic [3:0] upper;
    logic [3:0] lower;

    assign upper = D[7:4];
    assign lower = D[3:0];
    
    //Prüfen, ob oben oder unten 0 kanns nie sein, ist ja teiler bei Division später
    assign isupper = |upper;
    assign islower = |lower;

    //Jetzt lokale LZ bestimmen
    logic [2:0] lz_upper;
    logic [2:0] lz_lower;

    LZD4 u_lzd_upper (.D(upper), .LZ(lz_upper));
    LZD4 u_lzd_lower (.D(lower), .LZ(lz_lower));

    assign LZ = isupper ? lz_upper : (4 + lz_lower);

endmodule

module LZD4 (
    input logic[3:0] D,
   output logic[2:0] LZ
);

    //Halbieren und schauen wo die 1 ist
    logic [1:0] upper;
    logic [1:0] lower;

    assign upper = D[3:2];
    assign lower = D[1:0];
    
    //Prüfen, ob oben oder unten 0 kanns nie sein, ist ja teiler bei Division später
    assign isupper = |upper; //assign verwenden und nicht logic sonst ist nach der ersten Zuweisung schluss
                             //er macht dann nichts mehr
    assign islower = |lower;

    //Jetzt lokale LZ bestimmen
    logic [1:0] lz_upper;
    logic [1:0] lz_lower;

    LZD2 u_lzd_upper (.D(upper), .LZ(lz_upper));
    LZD2 u_lzd_lower (.D(lower), .LZ(lz_lower));

    assign LZ = isupper ? lz_upper : (2 + lz_lower);

endmodule

module LZD2 (
    input  logic [1:0] D,
    output logic [1:0] LZ
);

    always_comb begin
        case (D)
            2'b00: LZ = 2;
            2'b01: LZ = 1;
            2'b10: LZ = 0;
            2'b11: LZ = 0;
            default: LZ = 2'b00;
        endcase
    end

endmodule