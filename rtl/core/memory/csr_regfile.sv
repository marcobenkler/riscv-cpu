/**
* @brief Manage entire csr block
**/

module csr_regfile(
    input  logic clk, reset_n,
    input  logic [31:0] instruction, // entire instruction vector
    input  logic [31:0] pc_current, // current pc to remember where to jump back after trap
    input  logic [31:0] pc_if, // current pc to remember where to jump back after trap
    input  logic [31:0] rs1_data, // data from register[rs1]
    input  logic [2:0]  csr_op, // which operation, declared by decoder
    input  logic        csr_write, // enable writing in csr, declared by decoder
    //input  logic [3:0] exc_cause, // decoder tells exception was recognized

    //Exception
    input  logic        id_ecall,  
    input  logic        id_ebreak,  
    input  logic        id_mret,  
    input  logic        id_illegal_instr,  
    input  logic        misaligned_load,  
    input  logic        misaligned_store,  
    input  logic        misaligned_fetch,  
    input  logic [31:0] fault_address, 

    //Interrput 
    input  logic        time_itr, // from CLINT, timer interrupt is required

    output logic        trap_taken, // override next pc, if trap was taken
    output logic        mret_taken, // jump back to last pc stored in mret
    output logic [31:0] csr_res, // output for regular register
    output logic [31:0] csr_pc // pc to jump back after trap handled
);

    logic [11:0] csr_addr;
    assign csr_addr = instruction[31:20];

    logic [31:0] csr_data;
    assign csr_data = csr_op[2] ? {27'b0, instruction[19:15]} : rs1_data;

    // Workaround to prevent 4000+ unused registers
    // Must have register
    logic [31:0] mstatus;
    logic [31:0] mie;
    logic [31:0] mtvec;
    logic [31:0] mepc;
    logic [31:0] mcause;
    logic [31:0] mip;
    logic [31:0] mtval;

    // Nice to have register
    logic [31:0] mscratch;
    logic [31:0] misa;
    logic [31:0] mhartid;
    logic [31:0] mvendorid;
    logic [31:0] marchid;
    logic [31:0] mimpid;

    assign misa = 32'h40001100;
    assign mhartid = '0;
    assign mvendorid = '0;
    assign marchid = '0;
    assign mimpid = '0;

    logic [31:0] csr_write_val;

    // mip is no real register in this simple cpu, directly wired
    assign mip = {24'b0, time_itr, 7'b0};
    
    always_comb begin 
        csr_res = '0;
        csr_write_val = '0;
        case (csr_addr) 
            12'h300: csr_res = mstatus;
            12'h304: csr_res = mie;
            12'h305: csr_res = mtvec;
            12'h341: csr_res = mepc;
            12'h342: csr_res = mcause;
            12'h343: csr_res = mtval;
            12'h344: csr_res = mip;
            12'hF11: csr_res = mvendorid;
            12'hF12: csr_res = marchid;
            12'hF13: csr_res = mimpid;
            12'hF14: csr_res = mhartid;
            12'h301: csr_res = misa;
            12'h340: csr_res = mscratch;
            default: ;
        endcase
        case (csr_op[1:0]) 
            2'b01: csr_write_val = csr_data;
            2'b10: csr_write_val = csr_res | csr_data;
            2'b11: csr_write_val = csr_res & ~csr_data;
            default: ;
        endcase
    end

    always_comb begin
        trap_taken = '0;
        mret_taken = '0;
        csr_pc = '0;
        if(id_ecall || id_ebreak || id_illegal_instr||
                 misaligned_load || misaligned_store || misaligned_fetch) begin
            trap_taken = 1'b1;
            csr_pc = mtvec;
        end
        else if(time_itr && mie[7] && mstatus[3]) begin
            trap_taken = 1'b1;
            csr_pc = mtvec;
        end
        else if(id_mret) begin
            mret_taken = 1'b1;
            csr_pc = mepc;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            mstatus <= {19'b0, 2'b11, 11'b0};
            mie <= '0;
            mtvec <= '0;
            mepc <= '0;
            mcause <= '0;
        end
        else if (id_ecall || id_ebreak || id_illegal_instr||
                 misaligned_load || misaligned_store || misaligned_fetch) begin //Exceptions
            //Handle interrupts
            mepc <= pc_current;
            if (misaligned_fetch) begin
                mcause <= 32'd0;
                mtval <= fault_address;
            end
            else if (id_illegal_instr) begin
                mcause <= 32'd2;
                mtval  <= instruction;
            end
            else if (misaligned_load) begin
                mcause <= 32'd4;
                mtval <= fault_address;
            end
            else if (misaligned_store) begin
                mcause <= 32'd6;
                mtval <= fault_address;
            end
            else if (id_ecall) mcause <= 32'd11;
            else if (id_ebreak) mcause <= 32'd3;
            mstatus[7] <= mstatus[3];
            mstatus[3] <= 1'b0;
            mstatus[12:11] <= 2'b11;
        end
        else if (time_itr && mie[7] && mstatus[3]) begin //Interrupts
            mepc <= pc_if;
            mcause <= 32'h80000007;
            mstatus[7] <= mstatus[3];
            mstatus[3] <= 1'b0;
            mstatus[12:11] <= 2'b11;
        end
        else if (id_mret) begin
            //Exit trap handler
            mstatus[3] <= mstatus[7];
            mstatus[7] <= 1'b1;
            mstatus[12:11] <= 2'b11;
        end
        else if(csr_write) begin
            //Manipulate registers via software
            case (csr_addr)
                12'h300: mstatus <= csr_write_val;
                12'h304: mie <= csr_write_val;
                12'h305: mtvec <= csr_write_val;
                12'h341: mepc <= csr_write_val;
                12'h342: mcause <= csr_write_val;
                12'h343: mtval <= csr_write_val;
                12'h340: mscratch <= csr_write_val;
                12'h344: ; // mip read-only, driven by CLINT
                12'hF11: ; // mvendorid read-only
                12'hF12: ; // marchid read-only
                12'hF13: ; // mimpid read-only
                12'hF14: ; // mhartid read-only
                12'h301: ; // misa read-only
                default: ;
                //default: $display("CSR write to unknown address: 0x%h", csr_addr);
            endcase
        end
    end

endmodule