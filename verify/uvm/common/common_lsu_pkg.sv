package common_lsu_pkg;
    typedef struct packed {
        kind_e       kind;
        bit [31:0]   addr;
        bit [2:0]    prot; //currently fixed
        bit [31:0]   data;
        bit [3:0]    strb;
        resp_e       resp;

        int unsigned addr_valid_delay;
        int unsigned addr_ready_delay;
        int unsigned data_valid_delay;
        int unsigned data_ready_delay;
        int unsigned b_valid_delay;
        int unsigned b_ready_delay;
    } lsu_trans_t;

    typedef enum bit {
        READ,
        WRITE
    } kind_e;

    typedef enum bit {
        OKAY,
        SLVERR,
        DECERR
    } resp_e;

endpackage
