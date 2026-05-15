package pipeline_pkg;
    typedef struct packed {
        // Data
        logic [31:0] pc_current;
        logic [31:0] pc_default;
        logic [31:0] instruction;
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
    } id_ex_t;

    typedef struct packed {
        // Data
        logic [31:0] instruction;
        logic [31:0] pc_current;
        logic [31:0] pc_default;
        logic [31:0] ex_res
        logic [31:0] rs1_data;
        logic [31:0] rs2_data;
        logic [31:0] imm;

        // Register control
        logic        reg_write;
        logic [4:0]  rd;

        // Memory control
        logic        mem_write;
        logic [2:0]  mem_s_type;

        // Alu control
        logic [2:0]  res_src;

        // CSR / Exceptions
        logic        csr_write;
        logic [2:0]  csr_op;
        logic [3:0]  exc_cause;
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
    } mem_wb_t;
endpackage