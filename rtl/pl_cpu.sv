module pl_cpu 
    import pipeline_pkg::*;
(
    input logic clk,
    input logic reset_n
);

    if_id_t if_id_in;
    if_id_t if_id_out;

    id_ex_t id_ex_in;
    id_ex_t id_ex_out;

    ex_mem_t ex_mem_in;
    ex_mem_t ex_mem_out;

    mem_wb_t mem_wb_in;
    mem_wb_t mem_wb_out;

    logic        stall;

    // IF Stage
    logic [31:0] pc_next;
    logic [31:0] csr_pc;
    logic [31:0] imm_res;

    // EX Stage
    logic        div_activate;
    logic [31:0] a;
    logic [31:0] b;
    logic        zero;
    logic        lt;
    logic        is_div;
    logic        srt_en;
    logic        srt_done;
    logic        mtip;

    // MEM Stage
    logic [31:0] mem_read_data;
    logic        trap_taken;
    logic        mem_write_en;

    // WB Stage
    logic [31:0] result;

    // EXTERNAL
    logic        clint_write_en;
    logic [31:0] clint_read_data;
    logic [1:0]  forward_a;
    logic [1:0]  forward_b;
    logic        pc_stall;
    logic        if_id_stall;
    logic        id_ex_stall;
    logic        ex_mem_stall;

    // IF Stage
    update_pc update_pc(
        .clk(clk),
        .reset_n(reset_n), 
        .pc_next(pc_next), 
        .pc_stall(pc_stall),
        .pc_current(if_id_in.pc_current) //output
    );

    next_pc next_pc(
        .alu_res(mem_wb_out.alu_res),
        .imm_res(imm_res),
        .csr_pc(csr_pc),
        .pc_current(if_id_in.pc_current),
        .pc_src(id_ex_out.pc_src),
        .trap_taken(trap_taken),
        .stall(stall),
        .pc_next(pc_next), //output
        .pc_default(if_id_in.pc_default) //output
    );

    instruction_memory instruction_memory(
        .pc(if_id_in.pc_current),
        .instruction(if_id_in.instruction)
    );
    
    assign if_id_in.rs1 = if_id_in.instruction[19:15];
    assign if_id_in.rs2 = if_id_in.instruction[24:20];

    pipeline_reg #(.T(if_id_t)) if_id_reg (
        .clk(clk),
        .reset_n(reset_n),
        .flush('0),
        .stall(if_id_stall),
        .in(if_id_in),
        .out(if_id_out)
    );

    // ID Stage
    register_file register_file(
        .clk(clk),
        .reset_n(reset_n),
        .rs1(if_id_out.rs1),
        .rs2(if_id_out.rs2),
        .rd(mem_wb_out.rd),
        .reg_write(mem_wb_out.reg_write),
        .result(result),
        .stall(stall),
        .rs1_data(id_ex_in.rs1_data), //output
        .rs2_data(id_ex_in.rs2_data) //output
    );

    imm_gen imm_gen(
        .instruction(if_id_out.instruction),
        .imm(id_ex_in.imm) //output
    );

    decoder decoder(
        .instruction(if_id_out.instruction),
        .zero(zero),
        .lt(lt),
        .reg_write(id_ex_in.reg_write), //output
        .alu_src_a(id_ex_in.alu_src_a), //output
        .alu_src_b(id_ex_in.alu_src_b), //output
        .mem_write(id_ex_in.mem_write), //output
        .pc_src(id_ex_in.pc_src), //output
        .res_src(id_ex_in.res_src), //output
        .alu_op(id_ex_in.alu_op), //output
        .mul_op(id_ex_in.mul_op), //output
        .div_op(id_ex_in.div_op), //output
        .mem_s_type(id_ex_in.mem_s_type), //output
        .ex_src(id_ex_in.ex_src), //output
        .csr_op(id_ex_in.csr_op), //output
        .exc_cause(id_ex_in.exc_cause), //output
        .csr_write(id_ex_in.csr_write) //output
    );

    // Straight transmission between register
    assign id_ex_in.pc_current = if_id_out.pc_current;
    assign id_ex_in.pc_default = if_id_out.pc_default;
    assign id_ex_in.instruction = if_id_out.instruction;

    pipeline_reg #(.T(id_ex_t)) id_ex_reg (
        .clk(clk),
        .reset_n(reset_n),
        .flush('0),
        .stall(id_ex_stall),
        .in(id_ex_in),
        .out(id_ex_out)
    );

    assign imm_res = id_ex_out.pc_current + id_ex_out.imm;

    operand_select operand_select(
        .rs1_data(id_ex_out.rs1_data),
        .rs2_data(id_ex_out.rs2_data),
        .imm(id_ex_out.imm),
        .pc_current(id_ex_out.pc_current),
        .alu_src_a(id_ex_out.alu_src_a),
        .alu_src_b(id_ex_out.alu_src_b),
        // forwarding
        .forward_a(forward_a),
        .forward_a(forward_b),
        .
        // parameter from forwarding
        .a(a), //output
        .b(b) //output
        );
        
    alu_top alu_top(
        .a(a),
        .b(b),
        .alu_op(id_ex_out.alu_op),
        .result(ex_mem_in.alu_res), //output
        .zero(zero), //output - directly in alu
        .lt(lt) //output - directly in alu
        );
        
    multiply multiply(
        .rs1_data(id_ex_out.rs1_data),
        .rs2_data(id_ex_out.rs2_data),
        .mul_op(id_ex_out.mul_op),
        .mul_res(ex_mem_in.mul_res) //output
        );
    
    // Div handling
    assign is_div = id_ex_out.ex_src == 2'b10;
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) div_activate <= '0;
        else if (srt_done) div_activate <= '0;
        else if (is_div) div_activate <= '1;
    end

    assign srt_en = is_div && !div_activate; // might be error, additional !srt_done required
                
    srt2 srt2(
        .clk(clk),
        .reset_n(reset_n),
        .rs1_data(id_ex_out.rs1_data),
        .rs2_data(id_ex_out.rs2_data),
        .div_op(id_ex_out.div_op),
        .srt_en(srt_en),
        .div_res(ex_mem_in.div_res), //output
        .srt_done(srt_done) //output
    );

    // Straigt transmission between register
    assign ex_mem_in.instruction = id_ex_out.instruction;
    assign ex_mem_in.pc_current = id_ex_out.pc_current;
    assign ex_mem_in.pc_default = id_ex_out.pc_default;
    assign ex_mem_in.rs1_data = id_ex_out.rs1_data;
    assign ex_mem_in.rs2_data = id_ex_out.rs2_data;
    assign ex_mem_in.imm = id_ex_out.imm;
    assign ex_mem_in.reg_write = id_ex_out.reg_write;
    assign ex_mem_in.mem_write = id_ex_out.mem_write;
    assign ex_mem_in.mem_s_type = id_ex_out.mem_s_type;
    assign ex_mem_in.res_src = id_ex_out.res_src;
    assign ex_mem_in.csr_write = id_ex_out.csr_write;
    assign ex_mem_in.csr_op = id_ex_out.csr_op;
    assign ex_mem_in.exc_cause = id_ex_out.exc_cause;
    assign ex_mem_in.ex_src = id_ex_out.ex_src;
    assign ex_mem_in.rd = id_ex_out.instruction[11:7];

    pipeline_reg #(.T(ex_mem_t)) ex_mem_reg (
        .clk(clk),
        .reset_n(reset_n),
        .flush('0),
        .stall(ex_mem_stall),
        .in(ex_mem_in),
        .out(ex_mem_out)
    );

    // MEM Stage
    data_memory data_memory(
        .clk(clk),
        .reset_n(reset_n),
        .mem_write_en(mem_write_en),
        .mem_s_type(ex_mem_out.mem_s_type),
        .address(ex_mem_out.alu_res),
        .mem_write_data(ex_mem_out.rs2_data),
        .mem_read_data(mem_read_data) //output
    );

    //csr
    csr_regfile csr_regfile(
        .clk(clk),
        .reset_n(reset_n),
        .instruction(ex_mem_out.instruction),
        .pc_current(ex_mem_out.pc_current),
        .rs1_data(ex_mem_out.rs1_data),
        .exc_cause(ex_mem_out.exc_cause),
        .csr_op(ex_mem_out.csr_op),
        .csr_write(ex_mem_out.csr_write),
        .time_itr(mtip),
        .trap_taken(trap_taken), //output
        .csr_res(mem_wb_in.csr_res), //output
        .csr_pc(csr_pc) //output
    );

    bus_interconnect bus_interconnect(
        .address(ex_mem_out.alu_res),
        .clint_read_data(clint_read_data),
        .mem_data(mem_read_data),
        .mem_write(ex_mem_out.mem_write),
        .rdata(mem_wb_in.rdata), //output
        .clint_write_en(clint_write_en), //output
        .mem_write_en(mem_write_en) //output
    );

    assign mem_wb_in.reg_write = ex_mem_out.reg_write;
    assign mem_wb_in.alu_res = ex_mem_out.alu_res;
    assign mem_wb_in.mul_res = ex_mem_out.mul_res;
    assign mem_wb_in.div_res = ex_mem_out.div_res;
    assign mem_wb_in.imm = ex_mem_out.imm;
    assign mem_wb_in.pc_default = ex_mem_out.pc_default;
    assign mem_wb_in.rd = ex_mem_out.rd;
    assign mem_wb_in.res_src = ex_mem_out.res_src;
    assign mem_wb_in.ex_src = ex_mem_out.ex_src;

    pipeline_reg #(.T(mem_wb_t)) mem_wb_reg (
        .clk(clk),
        .reset_n(reset_n),
        .flush('0),
        .stall(1'b0),
        .in(mem_wb_in),
        .out(mem_wb_out)
    );

    // WB Stage
    result_select result_select(
        .alu_res(mem_wb_out.alu_res),
        .mul_res(mem_wb_out.mul_res),
        .div_res(mem_wb_out.div_res),
        .imm_res(mem_wb_out.imm),
        .mem_res(mem_wb_out.rdata),
        .pc_res(mem_wb_out.pc_default),
        .csr_res(mem_wb_out.csr_res),
        .res_src(mem_wb_out.res_src),
        .ex_src(mem_wb_out.ex_src),
        .result(result) //output
    );

    // EXTERNAL
    clint clint(
        .clk(clk),
        .reset_n(reset_n),
        .clint_write_en(clint_write_en),
        .address(ex_mem_out.alu_res),
        .clint_write_data(ex_mem_out.rs2_data),
        .mtip(mtip), //output
        .clint_read_data(clint_read_data) //output
    );

    // Hazard handling
    forwarding_unit forwarding_unit(
        .rs1_id_ex(id_ex_out.rs1),
        .rs2_id_ex(id_ex_out.rs2),
        .rd_ex_mem(ex_mem_out.rd),
        .reg_write_ex_mem(ex_mem_out.reg_write),
        .rd_mem_wb(mem_wb_out.rd),
        .reg_write_mem_wb(mem_wb_out.reg_write),
        .forward_a(forward_a) //output
        .forward_b(forward_b) //output
    );

    hazard_unit hazard_unit(
        .rs1_id_ex(id_ex_out.rs1),
        .rs2_id_ex(id_ex_out.rs2),

        .is_div(is_div),
        .srt_done(srt_done),

        .pc_stall(pc_stall),
        .if_id_stall(if_id_stall),
        .id_ex_stall(id_ex_stall),
        .ex_mem_stall(ex_mem_stall),
    );

endmodule