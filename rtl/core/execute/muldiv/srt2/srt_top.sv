//Was muss das Modul machen, was bekommt es usw
//Input ist Nenner, Zähler vom Bruch
//Output ist Quotient und Rest

//Was geben Module, was muss ich noch machen
//Bekomme
//Normierte Bruchbestandteile mit jeweiligem Shift
//Berechnung von einzelnen q digits
//Berechnung vom Rest durch q digit

//Was tun noch
//Reset mit N_0 initialisieren
//Module hier integrieren
//q abspeichern in 2 Vektoren, einmal positiv einmal negativ
//Q aus q berechnen 
//Rest korrekt shiften
//FSM zur Kontrolle

module srt2 
    import alu_pkg::*;
(
    input  logic        clk,
    input  logic        reset_n,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [1:0]  div_op,
    input  logic        srt_en,
    output logic [31:0] div_res,
    output logic [31:0] rem_res,
    output logic        srt_done
);
    div_state_e state;

    logic [5:0] lzd_reg;
    logic [5:0] lzn_reg;

    logic signed [31:0] divisor;
    logic signed [31:0] dividend;
    logic signed [31:0] rest;
    logic [31:0] quotient_pos;
    logic [31:0] quotient_neg;

    logic [4:0] cycle_count;

    logic signed [31:0] ND;
    logic signed [31:0] NN;
    logic [5:0] LZD;
    logic [5:0] LZN;

    Norm norm(
        .D(rs2_data),
        .N(rs1_data),
        .ND(ND),
        .NN(NN),
        .LZD(LZD),
        .LZN(LZN),
    );

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            lzd_reg <= '0;
            lzn_reg <= '0;
            divisor <= '0;
            dividend <= '0;
            quotient_pos <= '0;
            quotient_neg <= '0;
            rest <= '0;
            cycle_count <= '0;
            state <= IDLE;
        end else begin
            // FSM
            if (state == IDLE && srt_en) begin
                divisor <= ND;
                dividend <= NN;
                lzd_reg <= LZD;
                lzn_reg <= LZN;
            end
        end
    end


endmodule