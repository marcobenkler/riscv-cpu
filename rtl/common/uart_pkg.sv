package uart_pkg;
    localparam logic [31:0] UART_BASE   = 32'h1000_0000;
    localparam logic [31:0] UART_TX     = 32'h0000_0000;
    localparam logic [31:0] UART_STATUS = 32'h0000_0004;
    localparam logic [31:0] UART_RX     = 32'h0000_0008;

    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } uart_states_e;

endpackage
