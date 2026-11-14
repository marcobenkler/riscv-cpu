/**
* @brief Implementation of core local interruptor
**/

module clint
    import clint_pkg::*;
(
    input  logic     clk,
    input  logic     reset_n,
    input  axi_req_t axi_req_clint,
    output axi_rsp_t axi_rsp_clint,
    output logic     mtip
    /*
    input  logic        clint_write_en, ///< enable override of mtimecmp and msip register
    input  logic [31:0] address, ///< address if lower or upper mtimecmp is written to
    input  logic [31:0] clint_write_data, ///< set new mtimecmp value via software
    output logic        mtip, ///< interrupt flag
    output logic [31:0] clint_read_data ///< read data from mtime and mtimecmp
    */
);

    logic [31:0] mtimecmp_lo;
    logic [31:0] mtimecmp_hi;
    logic [31:0] mtime_lo;
    logic [31:0] mtime_hi;
    logic [31:0] msip;

    logic        clint_write_en;
    logic [31:0] clint_write_data;
    logic [31:0] address;

    // Axi overhead
    // Set all perma. Clint has not states where pausing is reqired
    assign axi_rsp_clint.awready = 1'b1;
    assign axi_rsp_clint.wready  = 1'b1;
    assign axi_rsp_clint.bresp   = OKAY;
    assign axi_rsp_clint.arready = 1'b1;
    assign axi_rsp_clint.rresp   = OKAY;
    assign axi_rsp_clint.bvalid  = 1'b1;
    assign axi_rsp_clint.rvalid  = 1'b1;

    assign clint_write_en = axi_req_clint.awvalid && axi_req_clint.wvalid;

    // Select address
    always_comb begin
        if (axi_req_clint.awvalid) address = axi_req_clint.awaddr;
        else address = axi_req_clint.araddr;
    end

    // Strobe handling
    always_comb begin
        if      (axi_req_clint.wstrb == 4'b0001) clint_write_data = {24'0, axi_req_clint.wdata[7:0]};
        else if (axi_req_clint.wstrb == 4'b0011) clint_write_data = {12'0, axi_req_clint.wdata[15:0]};
        else if (axi_req_clint.wstrb == 4'b1111) clint_write_data = axi_req_clint.wdata;
        // Maybe implement exception here
        else                                     clint_write_data = 32'hAAAA_AAAA;
    end

    always_comb begin
        case (address - CLINT_BASE)
            CLINT_MSIP: axi_rsp_clint.rdata = msip;
            CLINT_MTIMECMP_LO: axi_rsp_clint.rdata = mtimecmp_lo;
            CLINT_MTIMECMP_HI: axi_rsp_clint.rdata = mtimecmp_hi;
            CLINT_MTIME_LO: axi_rsp_clint.rdata = mtime_lo;
            CLINT_MTIME_HI: axi_rsp_clint.rdata = mtime_hi;
            default: axi_rsp_clint.rdata = '0;
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
        else if (clint_write_en) begin
            case (address - CLINT_BASE)
                CLINT_MSIP: msip <= clint_write_data;
                CLINT_MTIMECMP_LO: mtimecmp_lo <= clint_write_data;
                CLINT_MTIMECMP_HI: mtimecmp_hi <= clint_write_data;
                CLINT_MTIME_LO: mtime_lo <= clint_write_data;
                CLINT_MTIME_HI: mtime_hi <= clint_write_data;
                default: ;
            endcase
        end
        else {mtime_hi, mtime_lo} <= {mtime_hi, mtime_lo} + 1;
    end

    assign mtip = ({mtime_hi, mtime_lo} >= {mtimecmp_hi, mtimecmp_lo});

endmodule
