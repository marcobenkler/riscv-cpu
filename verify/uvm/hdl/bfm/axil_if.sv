interface axil_if
import common_lsu_pkg::*;
(
    input logic clk,
    input logic rst_n
);

    //Write
    //AW
    logic [31:0] awaddr;
    logic [2:0]  awprot;
    logic        awvalid;
    logic        awready;
    //W
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic        wvalid;
    logic        wready;
    //B
    resp_e       bresp;
    logic        bvalid;
    logic        bready;
    //Read
    //AR
    logic [31:0] araddr;
    logic [2:0]  arprot;
    logic        arvalid;
    logic        arready;
    //R
    logic [31:0] rdata;
    resp_e       rresp;
    logic        rvalid;
    logic        rready;

        modport mgr (
        input  clk, rst_n,
        // AW
        output awaddr, awprot, awvalid,
        input  awready,
        // W
        output wdata, wstrb, wvalid,
        input  wready,
        // B
        input  bresp, bvalid,
        output bready,
        // AR
        output araddr, arprot, arvalid,
        input  arready,
        // R
        input  rdata, rresp, rvalid,
        output rready
    );

    modport sub (
        input  clk, rst_n,
        // AW
        input  awaddr, awprot, awvalid,
        output awready,
        // W
        input  wdata, wstrb, wvalid,
        output wready,
        // B
        output bresp, bvalid,
        input  bready,
        // AR
        input  araddr, arprot, arvalid,
        output arready,
        // R
        output rdata, rresp, rvalid,
        input  rready
    );

    modport mon (
        input clk, rst_n,
        // AW
        input awaddr, awprot, awvalid, awready,
        // W
        input wdata, wstrb, wvalid, wready,
        // B
        input bresp, bvalid, bready,
        // AR
        input araddr, arprot, arvalid, arready,
        // R
        input rdata, rresp, rvalid, rready
    );

endinterface
