interface axil_sub_bfm #(
    parameter logic [15:0] aw_seed = 2874,
    parameter logic [15:0] w_seed  = 32145,
    parameter logic [15:0] ar_seed = 17095,
    parameter logic [15:0] zero    = 16000,
    parameter logic [15:0] low     = 30000,
    parameter logic [15:0] mid     = 41000,
    parameter logic [15:0] high    = 52000,
    parameter logic [15:0] ultra   = 60000
)(axil_if.sub bus);
    axil_trans_t trans;

    logic [15:0] lfsr_aw;
    logic [15:0] lfsr_w;
    logic [15:0] lfsr_ar;

    logic [3:0] awready_delay;
    logic [3:0] wready_delay;
    logic [3:0] arready_delay;

    logic [15:0] thresh [5] = {zero, low, mid, high, ultra};

    always_ff @(posedge bus.clk) begin
        if (!bus.rst_n) begin

        end else begin

        end
    end

    //LFSR pseudo random generator. READY Delays need to be generated randomly in the bfm
    // to avoid lookahead logic thats buggy
    always_ff @(posedge bus.clk) begin
        if (!bus.rst_n) begin
            lfsr_aw <= aw_seed;
            lfsr_w  <= w_seed;
            lfsr_ar <= ar_seed;
        end else begin
            lfsr_aw <= {lfsr_aw[14:0], ~(lfsr_w[15] ^ lfsr_w[14] ^ lfsr_w[12] ^ lfsr_w[3])};
            lfsr_w  <= {lfsr_w[14:0], ~(lfsr_w[15] ^ lfsr_w[14] ^ lfsr_w[12] ^ lfsr_w[3])};
            lfsr_ar <= {lfsr_ar[14:0], ~(lfsr_w[15] ^ lfsr_w[14] ^ lfsr_w[12] ^ lfsr_w[3])};
        end

    end

    function automatic logic [3:0] map_delay(input logic [15:0] r);
        if      (r < zero) return 4'b0000;
        else if (r < low)  return 4'b0001;
        else if (r < mid)  return 4'b0100;
        else if (r < high) return 4'b1000;
        else               return 4'b1111;
    endfunction

    assign awready_delay = map_delay(lfsr_aw);
    assign wready_delay  = map_delay(lfsr_w);
    assign wrready_delay = map_delay(lfsr_ar);

endinterface
