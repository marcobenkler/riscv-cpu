module data_memory #(
    parameter MEM_DEPTH = 8192
)(
    input  logic clk,
    input  logic [31:0] read_address,
    input  logic [2:0]  read_mem_s_type,
    output logic [31:0] mem_read_data,
    input  logic        mem_write_en,
    input  logic [31:0] write_address,
    input  logic [2:0]  write_mem_s_type,
    input  logic [31:0] mem_write_data
);

    localparam AW = $clog2(MEM_DEPTH);

    (* ram_style = "block" *) logic [31:0] mem [0:MEM_DEPTH-1];

    logic [31:0] raw_read;
    logic [1:0]  addr_lsb_reg;
    logic [2:0]  s_type_reg;

    // BRAM — ein Process, sauber
    always_ff @(posedge clk) begin
        raw_read     <= mem[read_address[AW+1:2]];
        addr_lsb_reg <= read_address[1:0];
        s_type_reg   <= read_mem_s_type;

        if (mem_write_en) begin
            case (write_mem_s_type)
                3'b000: mem[write_address[AW+1:2]][write_address[1:0]*8 +: 8]  <= mem_write_data[7:0];
                3'b001: mem[write_address[AW+1:2]][write_address[1:0]*8 +: 16] <= mem_write_data[15:0];
                3'b010: mem[write_address[AW+1:2]]                              <= mem_write_data;
                default: ;
            endcase
        end
    end

    // Bypass-Tracking — registriere Write-Info, kein mem[]-Zugriff
    logic        prev_wr_en;
    logic [AW-1:0] prev_wr_word_addr;
    logic [1:0]  prev_wr_byte_off;
    logic [2:0]  prev_wr_type;
    logic [31:0] prev_wr_data;
    logic [AW-1:0] rd_word_addr_reg;

    always_ff @(posedge clk) begin
        prev_wr_en        <= mem_write_en;
        prev_wr_word_addr <= write_address[AW+1:2];
        prev_wr_byte_off  <= write_address[1:0];
        prev_wr_type      <= write_mem_s_type;
        prev_wr_data      <= mem_write_data;
        rd_word_addr_reg  <= read_address[AW+1:2];
    end

    // Bypass: overlay geschriebene Bytes auf raw_read
    logic bypass;
    logic [31:0] merged;

    assign bypass = prev_wr_en && (rd_word_addr_reg == prev_wr_word_addr);

    always_comb begin
        merged = raw_read;
        if (bypass) begin
            case (prev_wr_type)
                3'b000: merged[prev_wr_byte_off*8 +: 8]  = prev_wr_data[7:0];
                3'b001: merged[prev_wr_byte_off*8 +: 16] = prev_wr_data[15:0];
                3'b010: merged                            = prev_wr_data;
                default: ;
            endcase
        end
    end

    // Sign/zero extension
    always_comb begin
        mem_read_data = merged;
        case (s_type_reg)
            3'b000: mem_read_data = {{24{merged[addr_lsb_reg*8 + 7]}}, merged[addr_lsb_reg*8 +: 8]};
            3'b001: mem_read_data = {{16{merged[addr_lsb_reg*8 + 15]}}, merged[addr_lsb_reg*8 +: 16]};
            3'b100: mem_read_data = {24'b0, merged[addr_lsb_reg*8 +: 8]};
            3'b101: mem_read_data = {16'b0, merged[addr_lsb_reg*8 +: 16]};
            default: ;
        endcase
    end

endmodule