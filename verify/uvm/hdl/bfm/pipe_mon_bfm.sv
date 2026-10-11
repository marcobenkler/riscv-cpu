interface pipe_bfm(pipe_if.mon bus);
    pipe_trans_t trans;



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
