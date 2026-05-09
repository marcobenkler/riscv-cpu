/**
* @brief Data memory — word-addressed for BRAM inference
* NOTE: Byte/halfword access logic temporarily simplified for synthesis.
* Original S-Type handling preserved in comments for later restoration.
**/
module data_memory #(
    parameter MEM_DEPTH = 255
)(
    input  logic        clk, mem_write,
    input  logic [2:0]  mem_s_type,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);
    (* ram_style = "block" *)
    logic [31:0] mem [0:MEM_DEPTH/4];

    always_ff @(posedge clk) begin
        if (mem_write)
            mem[address[31:2]] <= write_data;
        read_data <= mem[address[31:2]];
    end

endmodule
