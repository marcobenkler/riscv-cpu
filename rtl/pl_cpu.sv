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

    // IF Stage
    logic [31:0] pc_next;
    logic [31:0] csr_pc;
    logic [31:0] imm_res;

    // EX Stage
    logic        div_activate;
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] alu_res;
    logic [31:0] mul_res;
    logic [31:0] div_res;
    logic        zero;
    logic        lt;
    logic [1:0]  pc_src_ex;
    logic        is_div;
    logic        srt_en;
    logic        srt_done;
    logic        mtip;
    logic [31:0] ex_mem_forward_data;

    // MEM Stage
    logic [31:0] mem_read_data;
    logic        trap_taken;
    logic        mret_taken;
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
    logic        if_id_flush;
    logic        id_ex_stall;
    logic        id_ex_flush;
    logic        ex_mem_stall;
    logic        ex_mem_flush;

    // IF Stage
    update_pc update_pc(
        .clk(clk),
        .reset_n(reset_n), 
        .pc_next(pc_next), 
        .pc_stall(pc_stall),
        .pc_current(if_id_in.pc_current) //output
    );

    next_pc next_pc(
        .alu_res(alu_res),
        .imm_res(imm_res),
        .csr_pc(csr_pc),
        .pc_current(if_id_in.pc_current),
        .pc_src(pc_src_ex),
        .trap_taken(trap_taken),
        .mret_taken(mret_taken),
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
        .flush(if_id_flush),
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
        .rs1_data(id_ex_in.rs1_data), //output
        .rs2_data(id_ex_in.rs2_data) //output
    );

    imm_gen imm_gen(
        .instruction(if_id_out.instruction),
        .imm(id_ex_in.imm) //output
    );

    decoder decoder(
        .instruction(if_id_out.instruction),
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
        .id_ecall(id_ex_in.id_ecall), //output
        .id_ebreak(id_ex_in.id_ebreak), //output
        .id_mret(id_ex_in.id_mret), //output
        .id_illegal_instr(id_ex_in.id_illegal_instr), //output
        .csr_write(id_ex_in.csr_write) //output
    );

    // Straight transmission between register
    assign id_ex_in.pc_current = if_id_out.pc_current;
    assign id_ex_in.pc_default = if_id_out.pc_default;
    assign id_ex_in.instruction = if_id_out.instruction;
    assign id_ex_in.rs1 = if_id_out.rs1;
    assign id_ex_in.rs2 = if_id_out.rs2;

    pipeline_reg #(.T(id_ex_t)) id_ex_reg (
        .clk(clk),
        .reset_n(reset_n),
        .flush(id_ex_flush),
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
        .forward_b(forward_b),
        // parameter from forwarding
        .ex_mem_data(ex_mem_forward_data),
        .mem_wb_data(result),
        .a(a), //output
        .b(b) //output
        );
        
    alu_top alu_top(
        .a(a),
        .b(b),
        .alu_op(id_ex_out.alu_op),
        .result(alu_res), //output
        .zero(zero), //output
        .lt(lt) //output
        );
        
    multiply multiply(
        .rs1_data(a),
        .rs2_data(b),
        .mul_op(id_ex_out.mul_op),
        .mul_res(mul_res) //output
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
        .rs1_data(a),
        .rs2_data(b),
        .div_op(id_ex_out.div_op),
        .srt_en(srt_en),
        .div_res(div_res), //output
        .srt_done(srt_done) //output
    );

    branch_unit branch_unit(
        .pc_src(id_ex_out.pc_src),
        .op_code(id_ex_out.instruction[6:0]),
        .funct3(id_ex_out.instruction[14:12]),
        .zero(zero),
        .lt(lt),
        .pc_src_ex(pc_src_ex) //output
    );

    misaligned_detection misaligned_detection(
        .funct3(id_ex_out.instruction[14:12]),
        .alu_res(alu_res),
        .mem_write(id_ex_out.mem_write),
        .mem_read(id_ex_out.res_src == 3'b001),
        .misaligned_load(ex_mem_in.misaligned_load),
        .misaligned_store(ex_mem_in.misaligned_store)
    );

    always_comb begin
        case (id_ex_out.ex_src)
            2'b00: ex_mem_in.ex_res = alu_res;
            2'b01: ex_mem_in.ex_res = mul_res;
            2'b10: ex_mem_in.ex_res = div_res;
            default: ;
        endcase
    end
    
    always_comb begin
        case (forward_b)
            2'b00: ex_mem_in.rs2_data = id_ex_out.rs2_data;
            2'b01: ex_mem_in.rs2_data = result;
            2'b10: ex_mem_in.rs2_data = ex_mem_forward_data;
            default: ex_mem_in.rs2_data = 'x;
        endcase
    end

    // Straigt transmission between register
    assign ex_mem_in.instruction = id_ex_out.instruction;
    assign ex_mem_in.pc_current = id_ex_out.pc_current;
    assign ex_mem_in.pc_default = id_ex_out.pc_default;
    assign ex_mem_in.pc_src = id_ex_out.pc_src;
    assign ex_mem_in.rs1_data = a;
    assign ex_mem_in.imm = id_ex_out.imm;
    assign ex_mem_in.reg_write = id_ex_out.reg_write;
    assign ex_mem_in.mem_write = id_ex_out.mem_write;
    assign ex_mem_in.mem_s_type = id_ex_out.mem_s_type;
    assign ex_mem_in.res_src = id_ex_out.res_src;
    assign ex_mem_in.csr_write = id_ex_out.csr_write;
    assign ex_mem_in.csr_op = id_ex_out.csr_op;
    assign ex_mem_in.rd = id_ex_out.instruction[11:7];
    // Exceptions
    assign ex_mem_in.id_ecall = id_ex_out.id_ecall;
    assign ex_mem_in.id_ebreak = id_ex_out.id_ebreak;
    assign ex_mem_in.id_mret = id_ex_out.id_mret;
    assign ex_mem_in.id_illegal_instr = id_ex_out.id_illegal_instr;

    pipeline_reg #(.T(ex_mem_t)) ex_mem_reg (
        .clk(clk),
        .reset_n(reset_n),
        .flush(ex_mem_flush),
        .stall(ex_mem_stall),
        .in(ex_mem_in),
        .out(ex_mem_out)
    );

    //MUX for solving forwarding problem, where only alu_res could be forwarded
    always_comb begin
        case (ex_mem_out.res_src)
            3'b000: ex_mem_forward_data = ex_mem_out.ex_res;
            3'b010: ex_mem_forward_data = ex_mem_out.imm;
            3'b011: ex_mem_forward_data = ex_mem_out.pc_default;
            default: ex_mem_forward_data = '0;
        endcase
    end

    // MEM Stage
    data_memory data_memory(
        .clk(clk),
        .reset_n(reset_n),
        .mem_write_en(mem_write_en),
        .mem_s_type(ex_mem_out.mem_s_type),
        .address(ex_mem_out.ex_res),
        .mem_write_data(ex_mem_out.rs2_data),
        .mem_read_data(mem_read_data) //output
    );

    //csr
    csr_regfile csr_regfile(
        .clk(clk),
        .reset_n(reset_n),
        .instruction(ex_mem_out.instruction),
        .pc_current(ex_mem_out.pc_current), //Exception-mpec
        .pc_if(if_id_in.pc_current), //in op out idk       //Interrutp-mpec
        .rs1_data(ex_mem_out.rs1_data),
        .csr_op(ex_mem_out.csr_op),
        .csr_write(ex_mem_out.csr_write),
        .id_ecall(ex_mem_out.id_ecall),
        .id_ebreak(ex_mem_out.id_ebreak),
        .id_mret(ex_mem_out.id_mret),
        .id_illegal_instr(ex_mem_out.id_illegal_instr),
        .misaligned_load(ex_mem_out.misaligned_load),
        .misaligned_store(ex_mem_out.misaligned_store),
        .fault_address(ex_mem_out.ex_res),
        .time_itr(mtip),
        .trap_taken(trap_taken), //output
        .mret_taken(mret_taken), //output
        .csr_res(mem_wb_in.csr_res), //output
        .csr_pc(csr_pc) //output
    );

    bus_interconnect bus_interconnect(
        .address(ex_mem_out.ex_res),
        .clint_read_data(clint_read_data),
        .mem_data(mem_read_data),
        .mem_write(ex_mem_out.mem_write),
        .rdata(mem_wb_in.rdata), //output
        .clint_write_en(clint_write_en), //output
        .mem_write_en(mem_write_en) //output
    );

    assign mem_wb_in.reg_write = ex_mem_out.reg_write;
    assign mem_wb_in.ex_res = ex_mem_out.ex_res;
    assign mem_wb_in.imm = ex_mem_out.imm;
    assign mem_wb_in.pc_default = ex_mem_out.pc_default;
    assign mem_wb_in.rd = ex_mem_out.rd;
    assign mem_wb_in.res_src = ex_mem_out.res_src;

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
        .ex_res(mem_wb_out.ex_res),
        .imm_res(mem_wb_out.imm),
        .mem_res(mem_wb_out.rdata),
        .pc_res(mem_wb_out.pc_default),
        .csr_res(mem_wb_out.csr_res),
        .res_src(mem_wb_out.res_src),
        .result(result) //output
    );

    // EXTERNAL
    clint clint(
        .clk(clk),
        .reset_n(reset_n),
        .clint_write_en(clint_write_en),
        .address(ex_mem_out.ex_res),
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
        .forward_a(forward_a), //output
        .forward_b(forward_b) //output
    );

    hazard_unit hazard_unit(
        .if_id_rs1(if_id_out.rs1),
        .if_id_rs2(if_id_out.rs2),
        .id_ex_rd(id_ex_out.instruction[11:7]),
        .res_src(id_ex_out.res_src),
        .pc_src(pc_src_ex),
        .is_div(is_div),
        .srt_done(srt_done),
        .reg_write(id_ex_out.reg_write),
        .trap_taken(trap_taken),
        .mret_taken(mret_taken),
        .pc_stall(pc_stall), //output
        .if_id_stall(if_id_stall), //output
        .if_id_flush(if_id_flush), //output
        .id_ex_flush(id_ex_flush), //output
        .id_ex_stall(id_ex_stall), //output
        .ex_mem_stall(ex_mem_stall), //output
        .ex_mem_flush(ex_mem_flush) //output
    );

endmodule