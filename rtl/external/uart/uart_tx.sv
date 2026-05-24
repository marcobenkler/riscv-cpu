module uart_tx
    import uart_pkg::*;
(
    input  logic       clk,
    input  logic       reset_n,
    input  logic       baud_tick,
    input  logic       tx_start,
    input  logic [7:0] wdata,
    output logic       tx_ready,
    output logic       tx
);

    uart_states_e state;

    logic [7:0] shift_reg;
    logic [2:0] bit_cnt;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            shift_reg <= '0;
            state     <= IDLE;
        end
        else if (state == IDLE && tx_start) begin
            state     <= START;
            shift_reg <= wdata;
        end
        else if (state == START && baud_tick) begin
            state     <= DATA;
            bit_cnt   <= 3'b0;
        end
        else if (state == DATA && baud_tick)begin
            if(bit_cnt == 7) state <= STOP;
            bit_cnt <= bit_cnt + 1;
        end
        else if (state == STOP && baud_tick) begin
            state <= IDLE;
        end

    end

    always_comb begin
        tx = 'x;
        tx_ready = 'x;
        if (state == IDLE) begin
            tx       = 1'b1;
            tx_ready = 1'b1;
        end
        else if (state == START) begin
            tx       = 1'b0;
            tx_ready = 1'b0;
        end
        else if (state == DATA) begin
            tx = shift_reg[bit_cnt];
        end
        else if (state == STOP) begin
            tx = 1'b1;
        end
        else $error("No state in uart found");
    end


    // Assertions
    property tx_low_on_start;
        @(posedge clk) disable iff (!reset_n)
        (state == START) |-> (tx == 1'b0);
    endproperty

    property tx_high_on_idle;
        @(posedge clk) disable iff (!reset_n)
        (state == IDLE) |-> (tx == 1'b1);
    endproperty
    
    property tx_ready_on_low;
        @(posedge clk) disable iff (!reset_n)
        (state != IDLE) |-> (tx_ready == 1'b0);
    endproperty
    
    property tx_ready_on_high;
        @(posedge clk) disable iff (!reset_n)
        (state == IDLE) |-> (tx_ready == 1'b1);
    endproperty
    
    assert property (tx_low_on_start) else $error("TX is NOT low on start");
    assert property (tx_high_on_idle) else $error("TX is not high in idle");
    assert property (tx_ready_on_low) else $error("TX_READY is NOT low when transmitting");
    assert property (tx_ready_on_high) else $error("TX_READY is NOT high after transmitting");

    cover property (tx_low_on_start);
    cover property (tx_high_on_idle);
    cover property (tx_ready_on_low);
    cover property (tx_ready_on_high);

endmodule