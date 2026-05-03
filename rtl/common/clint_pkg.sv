package clint_pkg;
    localparam CLINT_BASE = 32'h02000000;
    localparam CLINT_MSIP_OFFSET = 32'h0000_0000;
    localparam CLINT_MTIMECMP_LO = 32'h0000_4000;
    localparam CLINT_MTIMECMP_HI = 32'h0000_4004;
    localparam CLINT_MTIME_LO = 32'h0000_BFF8;
    localparam CLINT_MTIME_HI = 32'h0000_BFFC;
endpackage