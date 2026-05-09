/**
* @brief determine, if CLINT or MEM writes
**/

module bus_interconnect
    import clint_pkg::*;
(
    input  logic [31:0] address,
    input  logic [31:0] clint_read_data,
    input  logic [31:0] mem_data,
    input  logic        mem_write,
    output logic [31:0] rdata,
    output logic        clint_write_en,
    output logic        mem_write_en
);

logic clint_sel;
    
always_comb begin
    clint_sel = (address >= CLINT_BASE) && (address <= CLINT_BASE + CLINT_MTIME_HI);
    // Space for further address extension
end

assign rdata = clint_sel ? clint_read_data : mem_data;

always_comb begin
    clint_write_en = mem_write && clint_sel;
    mem_write_en = mem_write && !clint_sel;
end

endmodule