package lsu_pkg;

typedef enum logic[2:0] {
    SB,
    SH,
    SW,
    LB,
    LH,
    LW,
    LBU,
    LHU
} mem_op_type_e;

typedef enum logic [2:0] {
    NONE,
    LOAD_ADDR_MIS,
    LOAD_ACC_FLT,
    STORE_ADDR_MIS,
    STORE_ACC_FLT
} lsu_excep_e;

typedef enum logic [2:0] {
    IDLE,
    STORE_AW_A,
    STORE_B,
    LOAD_AR,
    LOAD_R
} state_t;

endpackage
