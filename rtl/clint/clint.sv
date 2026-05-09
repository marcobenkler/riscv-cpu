/**
* @brief Implementation of core local interruptor
**/

module clint
    import clint_pkg::*;
(
    input  logic        clk,
    input  logic        reset_n,
    input  logic        write_en, ///< enable override of mtimecmp and msip register
    input  logic [31:0] address, ///< address if lower or upper mtimecmp is written to
    input  logic [31:0] wdata, ///< set new mtimecmp value via software
    output logic        mtip, ///< interrupt flag
    output logic [31:0] rdata ///< read data from mtime and mtimecmp
);

logic [31:0] mtimecmp_lo;
logic [31:0] mtimecmp_hi;
logic [31:0] mtime_lo;
logic [31:0] mtime_hi;
logic [31:0] msip;

always_comb begin
    case (address)
         CLINT_MSIP: rdata = msip;
         CLINT_MTIMECMP_LO: rdata = mtimecmp_lo;
         CLINT_MTIMECMP_HI: rdata = mtimecmp_hi;
         CLINT_MTIME_LO: rdata = mtime_lo;
         CLINT_MTIME_HI: rdata = mtime_hi;
         default: rdata = '0;
    endcase
end

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        msip <= '0;
        mtimecmp_lo <= '0;
        mtimecmp_hi <= '0;
        mtime_lo <= '0;
        mtime_hi <= '0;
    end 
    else if (write_en) begin
        case (address)
            CLINT_MSIP: msip <= wdata;
            CLINT_MTIMECMP_LO: mtimecmp_lo <= wdata;
            CLINT_MTIMECMP_HI: mtimecmp_hi <= wdata;
            CLINT_MTIME_LO: mtime_lo <= wdata;
            CLINT_MTIME_HI: mtime_hi <= wdata;
            default: ;
        endcase
    end
    else {mtime_hi, mtime_lo} <= {mtime_hi, mtime_lo} + 1;
end

assign mtip = ({mtime_hi, mtime_lo} >= {mtimecmp_hi, mtimecmp_lo});

endmodule