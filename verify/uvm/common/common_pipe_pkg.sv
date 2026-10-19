package common_pipe_pkg;
    typedef struct packed {
        bit      [31:0] addr; //
        bit      [31:0] store_data; //
        mem_type_e      mem_type; //
        bit             stall_do;
        bit             flush_do;
        bit      [31:0] load_data;
        lsu_excep_e     lsu_exception; //
        bit      [2:0]  mcause;
        bit      [31:0] mtval;
        //stalls from pipe to lsu can happen several times
        //only when out_vld is high it's relevant for lsu
        bit [2:0]        num_stalls;
        int unsigned [4] stall_at;
        int unsigned [4] stall_duration;
        int unsigned     flush_at;
        int unsigned     req_vld_at; //
        int unsigned     out_vld_at; //
        //stalls from lsu only happens once, when no stall
        //transaction is finished when out_vld = 1
        //tracking lsu is redundant
        //int unsigned     lsu_stall_at;
        //int unsigned     lsu_stall_duration;
    } pipe_trans_t;

    typedef enum logic[2:0] {
        SB,
        SH,
        SW,
        LB,
        LH,
        LW,
        LBU,
        LHU
    } mem_type_e;

    typedef enum logic [2:0] {
        NONE,
        LOAD_ADDR_MIS,
        LOAD_ACC_FLT,
        STORE_ADDR_MIS,
        STORE_ACC_FLT
    } lsu_excep_e;
endpackage
