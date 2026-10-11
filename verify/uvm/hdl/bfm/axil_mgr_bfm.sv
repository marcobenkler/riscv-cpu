interface axil_mgr_bfm(axil_if.mgr bus);
    axil_trans_t trans;

    always_ff @(posedge bus.clk) begin
        
    end


    `ifndef SYNTHESIS

        task automatic send_item(axil_trans_t t, output bit aborted);
            trans   <= t;
            req_vld <= 1'b1;
            do @(posedge bus.clk); while(!trans_done && bus.rst_n);
            req_vld <= 1'b0;
            aborted <= !bus.rst_n;
        endtask

        task automatic wait_reset_done();
            @(posedge bus.clk iff bus.rst_n);
        endtask

    `endif

endinterface
