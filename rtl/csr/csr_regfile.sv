/**
* @brief Manage entire csr block
**/

module csr_regfile(
    input  logic clk, reset_n,
    input  logic [31:0] instruction, // entire instruction vector
    input  logic [31:0] pc_current, // current pc to remember where to jump back after trap
    input  logic [31:0] rs1_data_a, // data from register[rs1]
    input  logic [3:0] exc_cause, // decoder tells exception was recognized
    input  logic [2:0] csr_op, // which operation, declared by decoder
    input  logic csr_write, // enable writing in csr, declared by decoder
    input  logic time_itr, // from CLINT, timer interrupt is required
    output logic trap_taken, // override next pc, if trap was taken
    output logic [31:0] csr_res, // output for regular register
    output logic [31:0] csr_pc // pc to jump back after trap handled
);

    logic [11:0] csr_addr;
    assign csr_addr = instruction[31:20];

    logic [31:0] csr_data;
    assign csr_data = csr_op[2] ? {27'b0, instruction[19:15]} : rs1_data_a;

    logic mret_detected;
    assign mret_detected = (instruction == 32'h30200073);

    // Workaround to prevent 4000+ unused registers
    logic [31:0] mstatus;
    logic [31:0] mie;
    logic [31:0] mtvec;
    logic [31:0] mepc;
    logic [31:0] mcause;
    logic [31:0] mip;

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
            12'h344: csr_res = mip;
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
        csr_pc = '0;
        if(exc_cause != 0 || (time_itr && mie[7] && mstatus[3])) begin
            trap_taken = 1'b1;
            csr_pc = mtvec;
        end
        else if(mret_detected) begin
            trap_taken = 1'b1;
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
        else if (exc_cause != 0 || (time_itr && mie[7] && mstatus[3])) begin
            //Handle interrupts
            mepc <= pc_current;
            if (exc_cause != 0) mcause <= {28'b0, exc_cause};
            else mcause <= 32'h80000007;
            mstatus[7] <= mstatus[3];
            mstatus[3] <= 1'b0;
            mstatus[12:11] <= 2'b11;
        end
        else if (mret_detected) begin
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
                12'h344: ; // mip read-only, driven by CLINT
                default: $error("CSR write to unknown address: 0x%h", csr_addr);
            endcase
        end
    end

endmodule