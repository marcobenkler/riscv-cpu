/**
* @brief handle all 5 stages in a single cycle
**/

module sc_cpu(
    input logic clk, reset_n 
);
    
    // ---signals---
    // fetch
    logic [31:0] pc_next, pc_current, alu_res, imm_res, pc_default;
    logic [1:0]  pc_src;

    // decode
    logic        reg_write, zero, lt, alu_src_a, alu_src_b, mem_write;
    logic [31:0] result, rs1_data, rs2_data, instruction, imm;
    logic [2:0]  res_src;
    logic [2:0]  mem_s_type;
    logic [3:0]  alu_op;
    logic [1:0]  mul_op;
    logic [1:0]  div_op;
    logic [1:0]  ex_src;
    
    // execute
    logic [31:0] a, b;
    logic [31:0] mul_res;
    logic [31:0] div_res;
    logic        div_execute;
    logic        srt_en;
    logic        srt_done;
    logic        stall;
    logic        div_activate;
    logic        is_div;

    // memory access
    logic [31:0] mem_read_data;
    
    // csr
    logic [31:0] csr_res, csr_pc;
    logic [3:0]  exc_cause;
    logic [2:0]  csr_op;
    logic        trap_taken, csr_write;

    // bus interconnect
    logic        clint_sel;
    logic [31:0] rdata;
    logic        mem_write_en;
    
    // clint
    logic        clint_write_en;
    logic [31:0] clint_read_data;
    logic        mtip;

    // ---instances---
    // fetch
    update_pc update_pc(
        .clk(clk),
        .reset_n(reset_n), 
        .pc_next(pc_next), 
        .pc_current(pc_current) //output
    );

    assign imm_res = pc_current + imm;

    next_pc next_pc(
        .alu_res(alu_res),
        .imm_res(imm_res),
        .csr_pc(csr_pc),
        .pc_current(pc_current),
        .pc_src(pc_src),
        .trap_taken(trap_taken),
        .stall(stall),
        .pc_next(pc_next), //output
        .pc_default(pc_default) //output
    );

    instruction_memory instruction_memory(
        .pc(pc_current),
        .instruction(instruction)
    );

    // decode
    register_file register_file(
        .clk(clk),
        .reset_n(reset_n),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .reg_write(reg_write),
        .result(result),
        .stall(stall),
        .rs1_data(rs1_data), //output
        .rs2_data(rs2_data) //output
    );

    imm_gen imm_gen(
        .instruction(instruction),
        .imm(imm) //output
    );

    decoder decoder(
        .instruction(instruction),
        .zero(zero),
        .lt(lt),
        .reg_write(reg_write), //output
        .alu_src_a(alu_src_a), //output
        .alu_src_b(alu_src_b), //output
        .mem_write(mem_write), //output
        .pc_src(pc_src), //output
        .res_src(res_src), //output
        .alu_op(alu_op), //output
        .mul_op(mul_op), //output
        .div_op(div_op), //output
        .mem_s_type(mem_s_type), //output
        .ex_src(ex_src), //output
        .csr_op(csr_op), //output
        .exc_cause(exc_cause), //output
        .csr_write(csr_write) //output
    );

    
    //execute
    operand_select operand_select(
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .pc_current(pc_current),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .a(a), //output
        .b(b) //output
        );
        
    alu_top alu_top(
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(alu_res), //output
        .zero(zero), //output
        .lt(lt) //output
        );
        
    multiply multiply(
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .mul_op(mul_op),
        .mul_res(mul_res) //output
        );
    
    // Div handling
    assign is_div = ex_src == 2'b10;
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) div_activate <= '0;
        else if (srt_done) div_activate <= '0;
        else if (is_div) div_activate <= '1;
    end

    assign srt_en = is_div && !div_activate; // might be error, additional !srt_done required
    assign stall = is_div && !srt_done;
                
    srt2 srt2(
        .clk(clk),
        .reset_n(reset_n),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .div_op(div_op),
        .srt_en(srt_en),
        .div_res(div_res), //output
        .srt_done(srt_done) //output
    );

    //memory access
    data_memory data_memory(
        .clk(clk),
        .reset_n(reset_n),
        .mem_write_en(mem_write_en),
        .mem_s_type(mem_s_type),
        .address(alu_res),
        .mem_write_data(rs2_data),
        .mem_read_data(mem_read_data) //output
    );

    bus_interconnect bus_interconnect(
        .address(alu_res),
        .clint_read_data(clint_read_data),
        .mem_data(mem_read_data),
        .mem_write(mem_write),
        .rdata(rdata), //output
        .clint_write_en(clint_write_en), //output
        .mem_write_en(mem_write_en) //output
    );

    //writeback
    result_select result_select(
        .alu_res(alu_res),
        .mul_res(mul_res),
        .div_res(div_res),
        .imm_res(imm),
        .mem_res(rdata),
        .pc_res(pc_default),
        .csr_res(csr_res),
        .res_src(res_src),
        .ex_src(ex_src),
        .result(result) //output
    );

    //csr
    csr_regfile csr_regfile(
        .clk(clk),
        .reset_n(reset_n),
        .instruction(instruction),
        .pc_current(pc_current),
        .rs1_data(rs1_data),
        .exc_cause(exc_cause),
        .csr_op(csr_op),
        .csr_write(csr_write),
        .time_itr(mtip),
        .trap_taken(trap_taken), //output
        .csr_res(csr_res), //output
        .csr_pc(csr_pc) //output
    );

    //clint
    clint clint(
        .clk(clk),
        .reset_n(reset_n),
        .clint_write_en(clint_write_en),
        .address(alu_res),
        .clint_write_data(rs2_data),
        .mtip(mtip), //output
        .clint_read_data(clint_read_data) //output
    );

endmodule