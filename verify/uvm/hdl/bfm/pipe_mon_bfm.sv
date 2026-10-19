interface pipe_bfm#(parameter int CntWdth = 32)(pipe_if.mon bus);
    pipe_trans_t trans;
    logic [CntWdth-1:0] glb_cnt;
    logic [CntWdth-1:0] last_trans_wr;

    always_ff @(posedge bus.clk) begin
        if (!bus.rst_n) begin
            last_trans_wr <= '0;
        end else begin
            if (bus.req_vld) begin
                trans.req_vld_at <= glb_cnt - last_trans_wr;
                trans.addr       <= bus.addr;
                trans.store_data <= bus.store_data;
                trans.mem_type   <= bus.store_type;
            end
            if (bus.out_vld) begin
                trans.load_data     <= bus.load_data;
                trans.lsu_exception <= bus.lsu_exception;
                trans.mcause        <= bus.mcause;
                trans.mtval         <= bus.mtval;
            end
            if (bus.stall && stall) begin
                stall_ankor <= glb_cnt;
            end
        end
    end

    //COUNTER
    always_ff @(posedge bus.clk) begin
        if(!bus.rst_n) begin
            glb_cnt <= '0;
        end else begin
            glb_cnt <= glb_cnt + 1;
        end
    end

    `ifndef SYNTHESISE

        task automatic wait_item(output pipe_trans_t t);
            do @(posedge bus.clk); while(!trans_done);
            t = trans;
        endtask

        task automatic wait_reset_done();
            @(posedge bus.clk iff bus.rst_n);
        endtask

    `endif
endinterface
