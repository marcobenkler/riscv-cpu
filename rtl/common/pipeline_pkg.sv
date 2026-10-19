package pipeline_pkg;
    typedef struct packed {
        logic [31:0] pc_current;
        logic [31:0] pc_default;
    } if1_if2_t;

    typedef struct packed {
        // Data
        logic [31:0] pc_current;
        logic [31:0] pc_default;
        logic [31:0] instruction;
        logic [4:0]  rs1;
        logic [4:0]  rs2;
        // RVFI only for offset lockstep against Spike
        rvfi_t       rvfi;
    } if_id_t;

    typedef struct packed {
        // Data
        logic [31:0] rs1_data;
        logic [31:0] rs2_data;
        logic [31:0] imm;
        logic [31:0] instruction;
        logic [31:0] pc_current;
        logic [31:0] pc_default;

        // Register control
        logic        reg_write;
        logic [4:0]  rs1;
        logic [4:0]  rs2;

        // Memory control
        logic        mem_write;
        logic [2:0]  mem_s_type;

        // ALU control
        logic        alu_src_a;
        logic        alu_src_b;
        logic [3:0]  alu_op;
        logic [1:0]  mul_op;
        logic [1:0]  div_op;
        logic [1:0]  ex_src;

        // PC
        logic [1:0]  pc_src;
        logic [2:0]  res_src;

        // CSR / Exceptions
        logic        csr_write;
        logic [2:0]  csr_op;
        logic [3:0]  exc_cause;
        logic        id_ecall;
        logic        id_ebreak;
        logic        id_mret;
        logic        id_illegal_instr;

        // RVFI only for offset lockstep against Spike
        rvfi_t       rvfi;
    } id_ex_t;

    typedef struct packed {
        // Data
        logic [31:0] instruction;
        logic [31:0] pc_current;
        logic [31:0] pc_default;
        logic [31:0] ex_res;
        logic [31:0] rs1_data;
        logic [31:0] rs2_data;
        logic [31:0] imm;

        // Register control
        logic        reg_write;
        logic [4:0]  rd;

        logic [1:0]  pc_src;

        // Memory control   
        logic        mem_write;
        logic [2:0]  mem_s_type;

        // Alu control
        logic [2:0]  res_src;

        // CSR / Exceptions
        logic        csr_write;
        logic [2:0]  csr_op;
        logic [3:0]  exc_cause;
        logic        id_ecall;
        logic        id_ebreak;
        logic        id_mret;
        logic        id_illegal_instr;
        logic        misaligned_load;
        logic        misaligned_store;
        logic        misaligned_fetch;

        // RVFI only for offset lockstep against Spike
        rvfi_t       rvfi;
    } ex_mem_t;

    typedef struct packed {
        // Data
        logic [31:0] csr_res;
        logic [31:0] ex_res;
        logic [31:0] rdata;
        logic [31:0] imm;
        logic [31:0] pc_default;
        // logic [31:0] csr_pc;  directly in pc

        // Register control
        logic        reg_write;
        logic [4:0]  rd;

        // Alu control
        logic [1:0]  ex_src;
        logic [2:0]  res_src;

        // RVFI only for offset lockstep against Spike
        rvfi_t       rvfi;
    } mem_wb_t;

    typedef struct packed {
        //valid is set to 0 whenever it's flushed

        //items are put in the rvfi struct, whenever the datapath uses them
        //essential
        logic        valid;     //if1_stage set's it to 1, get's set to 0, when flushed or reset
        logic [31:0] pc;        //if_stage
        logic [31:0] instr;     //if_stage
        logic [31:0] rd_addr;   //wb_stage
        logic [31:0] rd_data;   //wb_stage
        //In current mem design not possible this way, LSU and mem meshed up, so just take before and after mem block
        logic [31:0] mem_addr;  //mem_stage after LSU, before interconnect
        logic [31:0] mem_wdata; //mem_stage after LSU, before interconnect
        logic [4:0]  mem_wmask; //mem_stage after LSU, before interconnect
        logic [31:0] mem_rmask; //mem_stage after mem, before LSU
        logic [31:0] mem_rdata; //mem_stage after mem, before LSU
        logic [63:0] counter;   //in UVM_MONITOR

        //debugging
        logic [31:0] rs1_addr;   //id_stage
        logic [31:0] rs2_addr;   //id_stage
        logic [31:0] rs1_data;   //ex_stage after operand_sel: after forwarding
        logic [31:0] rs2_data;   //ex_stage after operand_sel: after forwarding
    } rvfi_t;
endpackage
