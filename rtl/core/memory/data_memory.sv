/**
* @brief Manage datastorage
*
* Handle data from memory and decide which S-Type ius correct
**/

module data_memory #(
    parameter MEM_DEPTH = 65536
)(
    input  logic mem_write_en, clk, reset_n, ///< enable writing, clock, reset
    input  logic [2:0] mem_s_type, ///< which funct3 of S-Type was used
    input  logic [31:0] address, 
    input  logic [31:0] mem_write_data, ///< data that's written in memory from register
    output logic [31:0] mem_read_data ///< data that's read from memory into register
);

    logic [7:0] mem [MEM_DEPTH-1:0];

    always_comb begin
        for (int i = 0; i < 4; i++)begin
            mem_read_data[8*i +: 8] = mem[address + i];
        end
        case (mem_s_type)
            3'b000: mem_read_data = {{24{mem_read_data[7]}}, mem_read_data[7:0]};
            3'b001: mem_read_data = {{16{mem_read_data[15]}}, mem_read_data[15:0]};
            3'b100: mem_read_data = {24'b0, mem_read_data[7:0]};
            3'b101: mem_read_data = {16'b0, mem_read_data[15:0]};
            default: ;
        endcase
    end

    always_ff @(posedge clk) begin
        if (mem_write_en) begin
            case (mem_s_type)
                3'b000: mem[address] <= mem_write_data[7:0];
                3'b001: begin
                    mem[address] <= mem_write_data[7:0];
                    mem[address + 1] <= mem_write_data[15:8];
                end
                3'b010: begin
                    for (int i = 0; i < 4; i++) begin
                        mem[address + i] <= mem_write_data[8*i +: 8];
                    end
                end
                default: ;
            endcase
        end
    end
    
endmodule