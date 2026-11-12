// Addresses from freeRTOS ports for easier booting
package clint_pkg;
    localparam logic [31:0] CLINT_BASE = 32'h02000000;
    localparam logic [31:0] CLINT_MSIP = 32'h0000_0000;
    localparam logic [31:0] CLINT_MTIMECMP_LO = 32'h0000_4000;
    localparam logic [31:0] CLINT_MTIMECMP_HI = 32'h0000_4004;
    localparam logic [31:0] CLINT_MTIME_LO = 32'h0000_BFF8;
    localparam logic [31:0] CLINT_MTIME_HI = 32'h0000_BFFC;
endpackage
