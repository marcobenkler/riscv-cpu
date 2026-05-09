/**
* @brief determine, if CLINT or MEM writes
**/

module bus_interconnect
    import clint_pkg::*;
(
    input  logic [31:0] address,
    input  logic [31:0] clint_data,
    input  logic [31:0] mem_data,
    output logic [31:0] rdata
);

logic clint_sel;
    
always_comb begin
    clint_sel = (address >= CLINT_BASE) && (address <= CLINT_BASE + CLINT_MTIME_HI);
    // Space for further address extension
end

assign rdata = clint_sel ? clint_data : mem_data;

endmodule