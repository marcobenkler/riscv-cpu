package common_uart_pkg;
    typedef struct packed {
        logic [7:0] data;
        logic       delay;
        logic       frame_err;
    } uart_trans_t;

    typedef enum logic [1:0] {
        ENC_IDLE,
        ENC_WAIT,
        ENC_WORK
    } uart_tx_states_t;

    typedef enum logic [0:0] {
        DEC_IDLE,
        DEC_WORK
    } uart_rx_states_t;

endpackage
