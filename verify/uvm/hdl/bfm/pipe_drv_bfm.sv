interface pipe_drv_bfm(pipe_if.drv bus);
    pipe_trans_t  trans;
    trans_state_e trans_state;
    logic [31:0]  glb_cnt;

    always_ff @(posedge bus.clk) begin

    end

    assign flush = trans.flush_at >= glb_cnt;

    // Global counter, every timing attr compares to the trans begin
    always_ff @(posedge bus.clk) begin
        case (trans_state)
            IDLE: begin
                if (trans_rdy) trans_state <= ACTIVE;
                glb_cnt <= '0;
            end
            ACTIVE: begin
                // trans_done wird ja auch high wenn exception kommt, dann endet item ja auch
                if (trans_done || flush) trans_state <= IDLE;
                glb_cnt <= glb_cnt + 1;
            end
        endcase
    end

    `ifndef SYNTHESISE

        task automatic send_trans(pipe_trans_t t, output bit aborted);
            trans     <= t;
            trans_rdy <= 1'b1;
            do @(posedge bus.clk); while(!trans_done && bus.rst_n);
            trans_rdy <= 1'b0;
            aborted   <= 1'b1;
        endtask

        task automatic wait_reset_done();
            @(posedge bus.clk iff bus.rst_n);
        endtask

    `endif
endinterface
