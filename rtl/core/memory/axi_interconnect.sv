module axi_interconnect
    import clint_pkg::*;
    import uart_pkg::*;
    //no mem pkg, pkges are not parametrizable
    #(parameter logic [31:0] MEM_HIGHT = 32'h0000_20000)
(
    input logic clk,
    input logic rst_n,
    // LSU
    input  axi_req_t axi_req_lsu,
    output axi_rsp_t axi_rsp_lsu,

    // Peripherie
    output axi_req_t axi_req_mem,
    input  axi_rsp_t axi_rsp_mem,
    output axi_req_t axi_req_uart,
    input  axi_rsp_t axi_rsp_uart,
    output axi_req_t axi_req_clint,
    input  axi_rsp_t axi_rsp_clint
);

logic MEM_BASE = 32'h8000_0000;

function automatic logic is_in_range (logic [31:0] addr, logic [31:0] base, logic [31:0] hight);
    return ((addr >= base) && (addr <= base + hight));
endfunction

// select peripherie
always_comb begin
    clint_sel = is_in_range(axi_req_in.awaddr, CLINT_BASE, CLINT_MTIME_HI) ||
                is_in_range(axi_req_in.araddr, CLINT_BASE, CLINT_MTIME_HI);

    uart_sel = is_in_range(axi_req_in.awaddr, UART_BASE, UART_RX) ||
               is_in_range(axi_req_in.araddr, UART_BASE, UART_RX);

    mem_sel = is_in_range(axi_req_in.awaddr, MEM_BASE, MEM_HIGHT) ||
              is_in_range(axi_req_in.araddr, MEM_BASE, MEM_HIGHT);

end

// translate to periph
always_comb begin
    axi_req_mem   = '0;
    axi_req_uart  = '0;
    axi_req_clint = '0;
    if (clint_sel) begin
        axi_req_clint = axi_req_lsu;
        axi_rsp_clint = axi_rsp_lsu;
    end
    else if (uart_sel) begin
        axi_req_uart = axi_req_lsu;
        axi_rsp_uart = axi_rsp_lsu;
    end
    else if (mem_sel) begin
        axi_req_mem = axi_req_lsu;
        axi_rsp_mem = axi_rsp_lsu;
    end
    // DECERR
    // No buffering required, address stays the same over the entire transaction in my tightened spec
    else begin
        axi_rsp_lsu.awready = 1'b1;
        axi_rsp_lsu.wready  = 1'b1;
        axi_rsp_lsu.bvalid  = 1'b1;
        axi_rsp_lsu.bresp   = DECERR;
        axi_rsp_lsu.arready = 1'b1;
        axi_rsp_lsu.rdata   = 32'hDEAD_C0DE; // For easier debugging
        axi_rsp_lsu.rdata   = DECERR;
        axi_rsp_lsu.rvalid  = 1'b1;
    end
end

endmodule
