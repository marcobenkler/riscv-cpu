package common_pipe_pkg;
    typedef struct packed {
        
    } pipe_trans_t;

    typedef enum logic[1:0] {
        BYTE,
        HALF,
        WORD
    } mem_type_e;

    typedef enum logic [2:0] {
        NONE,
        LOAD_ADDR_MIS,
        LOAD_ACC_FLT,
        STORE_ADDR_MIS,
        STORE_ACC_FLT
    } lsu_excep_e;
endpackage
