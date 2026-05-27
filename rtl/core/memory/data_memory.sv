module data_memory #(
    parameter MEM_DEPTH = 8192
)(
    input  logic clk,
    // Read (EX-stage)
    input  logic [31:0] read_address,
    input  logic [2:0]  read_mem_s_type,
    output logic [31:0] mem_read_data,
    // Write (MEM-stage)
    input  logic        mem_write_en,
    input  logic [31:0] write_address,
    input  logic [2:0]  write_mem_s_type,
    input  logic [31:0] mem_write_data
);

    (* ram_style = "block" *) logic [31:0] mem [0:MEM_DEPTH-1];
    
    logic [31:0] raw_read;
    logic [1:0]  addr_lsb_reg;
    logic [2:0]  s_type_reg;

    // Bypass detection
    logic        bypass;
    logic [31:0] bypassed_word;

    // Register write info for bypass comparison
    // BRAM read + write
    always_ff @(posedge clk) begin
        raw_read     <= mem[read_address[$clog2(MEM_DEPTH)+1:2]];
        addr_lsb_reg <= read_address[1:0];
        s_type_reg   <= read_mem_s_type;

        if (mem_write_en) begin
            case (write_mem_s_type)
                3'b000: mem[write_address[$clog2(MEM_DEPTH)+1:2]][write_address[1:0]*8 +: 8]  <= mem_write_data[7:0];
                3'b001: mem[write_address[$clog2(MEM_DEPTH)+1:2]][write_address[1:0]*8 +: 16] <= mem_write_data[15:0];
                3'b010: mem[write_address[$clog2(MEM_DEPTH)+1:2]]                              <= mem_write_data;
                default: ;
            endcase
        end
    end

    // Bypass detection — alles registriert, gleiche Timing-Domain
    logic        prev_write_en;
    logic [$clog2(MEM_DEPTH)-1:0] prev_write_word_addr;
    logic [$clog2(MEM_DEPTH)-1:0] read_word_addr_reg;
    logic [31:0] prev_written_word;

    always_ff @(posedge clk) begin
        prev_write_en        <= mem_write_en;
        prev_write_word_addr <= write_address[$clog2(MEM_DEPTH)+1:2];
        read_word_addr_reg   <= read_address[$clog2(MEM_DEPTH)+1:2];

        if (mem_write_en) begin
            prev_written_word <= mem[write_address[$clog2(MEM_DEPTH)+1:2]];
            case (write_mem_s_type)
                3'b000: prev_written_word[write_address[1:0]*8 +: 8]  <= mem_write_data[7:0];
                3'b001: prev_written_word[write_address[1:0]*8 +: 16] <= mem_write_data[15:0];
                3'b010: prev_written_word                              <= mem_write_data;
                default: ;
            endcase
        end
    end

    assign bypass = prev_write_en 
                  && (read_word_addr_reg == prev_write_word_addr);
    logic [31:0] selected;
    assign selected = bypass ? prev_written_word : raw_read;

    // Sign/zero extension
    always_comb begin
        mem_read_data = selected;
        case (s_type_reg)
            3'b000: mem_read_data = {{24{selected[addr_lsb_reg*8 + 7]}}, selected[addr_lsb_reg*8 +: 8]};
            3'b001: mem_read_data = {{16{selected[addr_lsb_reg*8 + 15]}}, selected[addr_lsb_reg*8 +: 16]};
            3'b100: mem_read_data = {24'b0, selected[addr_lsb_reg*8 +: 8]};
            3'b101: mem_read_data = {16'b0, selected[addr_lsb_reg*8 +: 16]};
            default: ;
        endcase
    end

endmodule