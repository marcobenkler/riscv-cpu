/**
* @brief Manage datastorage
*
* Handle data from memory and decide which S-Type ius correct
**/

module data_memory (
    input  logic mem_write, clk, reset_n, ///< enable writing, clock, reset
    input  logic [2:0] mem_s_type, ///< which funct3 of S-Type was used
    input  logic [31:0] address, 
    input  logic [31:0] write_data, ///< data that's written in memory from register
    output logic [31:0] read_data ///< data that's read from memory into register
);

    logic [7:0] regi [255:0];

    always_comb begin
        for (int i = 0; i < 4; i++)begin
            read_data[8*i +: 8] = regi[address + i];
        end
        case (mem_s_type)
            3'b000: read_data = {{24{read_data[7]}}, read_data[7:0]};
            3'b001: read_data = {{16{read_data[15]}}, read_data[15:0]};
            default: ;
        endcase
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (int i = 0; i < $size(regi); i++) begin
                regi[i] <= 0;
            end
        end else if (mem_write) begin 
            case (mem_s_type)
                3'b000: regi[address] <= write_data[7:0];
                3'b001: begin
                    regi[address] <= write_data[7:0];
                    regi[address + 1] <= write_data[15:8];
                end
                3'b010: begin
                    for (int i = 0; i < 4; i++) begin
                        regi[address + i] <= write_data[8*i +: 8];
                    end
                end
            endcase
        end
    end
    
endmodule