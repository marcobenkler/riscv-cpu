module mem
import axi_pkg::*;
#(
    parameter logic[31:0] MEM_DEPTH = 4096
)
(
    input  logic     clk,
    input  logic     rst_n,
    input  axi_req_t axi_req_mem,
    output axi_rsp_t axi_rsp_mem
);

    `ifndef SYNTHESIS
        initial begin
            string dmem_file;
            if ($value$plusargs("DMEM=%s", dmem_file))
                $readmemh(dmem_file, mem);
        end
    `endif

    // AXI handling, just raise ready to complete transaction
    // axi bit overcomplicate in current state, no variable wait times,
    // but option to expand further in dram connection
    // only valid in rsp need handling to ensure correct axi behaviour
    assign axi_rsp_mem.awready = 1'b1;
    assign axi_rsp_mem.wready  = 1'b1;
    assign axi_rsp_mem.bresp   = OKAY;
    assign axi_rsp_mem.arready = 1'b1;
    assign axi_rsp_mem.rresp   = OKAY;
    //valid handling (mb useless, TODO check)
    always_ff@(posedge clk) begin
        if (!rst_n) begin
            axi_rsp_mem.rvalid <= 1'b0;
            axi_rsp_mem.bvalid <= 1'b0;
        end
        axi_rsp_mem.rvalid <= 1'b0;
        axi_rsp_mem.bvalid <= 1'b0;
        if (axi_req_mem.arvalid) axi_rsp_mem.rvalid <= 1'b1;
        if (axi_req_mem.awvalid && axi_req_mem.wvalid) axi_rsp_mem.bvalid <= 1'b1;
    end

    /*
    // Strobe handling
    always_comb begin
        if      (axi_req_mem.wstrb == 4'b0001) bram_in_data = {24'b0, axi_req_mem.wdata[7:0]};
        else if (axi_req_mem.wstrb == 4'b0011) bram_in_data = {16'b0, axi_req_mem.wdata[15:0]};
        else if (axi_req_mem.wstrb == 4'b1111) bram_in_data = axi_req_mem.wdata;
        // Maybe implement exception here
        else                                   bram_in_data = 32'hDEAD_D00F;
    end
    */

    // Translate Byte -> Word Index: Just erase the two LSBs
    localparam int WD = $clog2(MEM_DEPTH);
    logic [WD-1:0] trans_wr_addr;
    logic [WD-1:0] trans_rd_addr;
    assign trans_wr_addr = axi_req_mem.awaddr[WD+1:2];
    assign trans_rd_addr = axi_req_mem.araddr[WD+1:2];

    // BlockRAM
    // Following AMD structure to ensure BRAM use on Xilinx FPGA boards
    (* ram_style = "block" *)
    logic [31:0] mem [MEM_DEPTH];

    // Write
    always_ff@(posedge clk) begin
        if (axi_req_mem.awvalid && axi_req_mem.wvalid)
            for (int i = 0; i < 4; i++) begin
                if (axi_req_mem.wstrb[i])
                    mem[trans_wr_addr][i*8 +: 8] <= axi_req_mem.wdata[i*8 +: 8];
            end
    end

    // Read
    always_ff@(posedge clk) begin
        if (axi_req_mem.arvalid)
            axi_rsp_mem.rdata <= mem[trans_rd_addr];
    end

    // Sign/Zero extension is done in lsu

endmodule
