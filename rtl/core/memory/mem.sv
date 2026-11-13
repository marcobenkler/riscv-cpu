module mem#(
    parameter logic[31:0] MEM_DEPTH = 8192
)
(
    input  logic     clk,
    input  logic     rst_n,
    input  axi_req_t axi_req_mem,
    output axi_rsp_t axi_rsp_mem
);

    logic [31:0] bram_in_data;
    logic [31:0] bram_out_data;

    // AXI handling, just raise ready to complete transaction
    // axi bit overcomplicate in current state, no variable wait times,
    // but option to expand further in dram connection
    // only valid in rsp need handling to ensure correct axi behaviour
    assign axi_rsp_mem.awready = 1'b1;
    assign axi_rsp_mem.wready  = 1'b1;
    assign axi_rsp_mem.bresp   = OKAY;
    assign axi_rsp_mem.arready = 1'b1;
    assign axi_rsp_mem.rresp   = OKAY;
    //valid handling
    always_ff@(posedge clk) begin
        axi_rsp_mem.rvalid <= 1'b0;
        if (axi_req_mem.arvalid) axi_rsp_mem.rvalid <= 1'b1;
    end

    // Strobe handling
    always_comb begin
        if      (axi_req_mem.wstrb == 4'b0001) bram_in_data = {24'0, axi_req_mem.wdata[7:0]};
        else if (axi_req_mem.wstrb == 4'b0011) bram_in_data = {12'0, axi_req_mem.wdata[15:0]};
        else if (axi_req_mem.wstrb == 4'b1111) bram_in_data = axi_req_mem.wdata;
        // Maybe implement exception here
        else                                   bram_in_data = 32'hAAAA_AAAA;
    end

    // BlockRAM
    // Following AMD structure to ensure BRAM use on Xilinx FPGA boards
    (* ram_style = "block" *)
    logic [31:0] mem [MEM_DEPTH];

    // Write
    always_ff@(posedge clk) begin
        if (axi_req_mem.awvalid && axi_req_mem.wvalid)
            mem[axi_req_mem.awaddr] <= bram_in_data;
    end

    // Read
    always_ff@(posedge clk) begin
        if (axi_req_mem.arvalid)
            axi_rsp_mem.rdata <= mem[axi_req_mem.araddr];
    end

    // Sign/Zero extension is done in lsu

endmodule
