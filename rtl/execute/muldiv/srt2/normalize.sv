//Kann sein, dass signed und unsigned probleme macht

module Norm (
    input  logic [31:0] D, N,
    output logic signed[31:0] ND, NN,
    output logic [5:0]  LZD, LZN
);

    LZD32 lzd_inst_d ( //So baut man Module ein, er schluckt D und spuckt LZ aus, alle outputs von LZD32 sind neue logic
        .D(D),
        .LZ(LZD)
    );

    LZD32 lzd_inst_n (
        .D(N),
        .LZ(LZN)
    );

    always_comb begin
        ND = D << LZD;
        NN = N << LZN;
    end

endmodule