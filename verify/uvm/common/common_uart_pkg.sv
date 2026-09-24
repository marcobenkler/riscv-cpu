package common_uart_pkg;
    typedef struct packed {
        logic [7:0] data;
        logic       delay;
        logic       framing_err;
    } uart_trans_t;

    typedef enum logic [1:0] {
        TX_IDLE,
        TX_WAIT,
        TX_WORK
    } uart_tx_states_t;

    typedef enum logic [0:0] {
        RX_IDLE,
        RX_WORK
    } uart_rx_states_t;

endpackage
