interface pipe_bfm(pipe_if.mon bus);
    pipe_trans_t trans;

    always_ff @(posedge bus.clk) begin
        if (!bus.rst_n) begin

        end else begin
            
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
