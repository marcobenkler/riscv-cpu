package common_uart_pkg;
    typedef struct packed {
        logic [7:0] data;
        logic       delay;
        logic       framing_err;
    } uart_trans_t;

    typedef enum logic [2:0] {
        START,
        WAIT,
        WORK
    } uart_bfm_states_t;
endpackage
