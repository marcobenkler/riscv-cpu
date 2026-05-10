package alu_pkg;
    typedef enum logic [3:0] {
        ALU_ADD,
        ALU_SUB,
        ALU_AND,
        ALU_OR,
        ALU_XOR,
        ALU_SLL,
        ALU_SRL,
        ALU_SRA,
        ALU_SLT,
        ALU_SLTU
    } alu_op_e;

    typedef enum logic [1:0] {
        IDLE,
        RUNNING,
        DONE
    } div_state_e;

    typedef enum logic [1:0] {
        DIV,
        DIVU,
        REM,
        REMU
    } div_op_e;

    typedef enum logic [1:0] {
        MUL,
        MULH,
        MULHSU,
        MULHU
    } mul_op_e;
endpackage