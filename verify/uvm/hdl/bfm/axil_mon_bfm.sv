// Define the if not virtual, bfm is hdl side not hvl => Thus as a port, not in the class
interface axil_mon_bfm #(parameter int CntWdth = 32)(axil_if.mon bus);
    // Ich schau ob bei Read oder Write zuerst ein valid anliegt, dann diejenigen channels tracken (3w oder 2r) und
    // Dazu dann ab dem valid den ready delay messen

    logic [CntWdth-1:0] glb_cnt;
    logic [CntWdth-1:0] last_trans; //
    logic [CntWdth-1:0] newer_channel_anker; //

    axil_trans_t        trans_wr;
    logic               trans_wr_done; //
    //Anker to indicate when valid was first set
    logic [CntWdth-1:0] aw_valid_anker; //
    logic               aw_valid_seen; //
    logic [CntWdth-1:0] aw_handshake_anker; //
    logic [CntWdth-1:0] w_valid_anker; //
    logic               w_valid_seen; //
    logic [CntWdth-1:0] w_handshake_anker; //
    logic [CntWdth-1:0] b_valid_anker; //
    logic               b_valid_seen; //

    axil_trans_t        trans_rd;
    bit                 trans_rd_done;
    logic [CntWdth-1:0] ar_valid_anker;
    logic [CntWdth-1:0] ar_handshake_anker;
    logic [CntWdth-1:0] r_valid_anker;

    //WRITE
    always_ff @(posedge bus.clk) begin
        if(!bus.rst_n) begin
            //Reset only control signals due to AMD reset convention
            trans_wr_done  <= '0;
            aw_valid_anker <= '0;
            aw_valid_seen  <= '0;
            w_valid_anker  <= '0;
            w_valid_seen   <= '0;
            b_valid_anker  <= '0;
            b_valid_seen   <= '0;
            last_trans     <= glb_cnt;
        end else begin
            trans_wr_done  <= '0;
            //AW
            if (bus.awvalid && !aw_valid_seen) begin
                aw_valid_anker <= glb_cnt;
                aw_valid_seen  <= 1'b1;
            end
            if (bus.awvalid && bus.awready) begin
                trans_wr.addr      <= bus.awaddr;
                trans_wr.prot      <= bus.awprot;
                aw_handshake_anker <= glb_cnt;
            end
            //W
            if (bus.wvalid && !w_valid_seen) begin
                w_valid_anker <= glb_cnt;
                w_valid_seen  <= 1'b1;
            end
            if (bus.wvalid && bus.wready) begin
                trans_wr.data     <= bus.wdata;
                trans_wr.strb     <= bus.wstrb;
                w_handshake_anker <= glb_cnt;
            end
            //B
            if (bus.bvalid && !b_valid_seen) begin
                b_valid_anker <= glb_cnt;
                b_valid_seen  <= 1'b1;
            end
            if (bus.bvalid && bus.bready) begin
                trans_wr.resp <= bus.bresp;
                trans_wr.addr_valid_delay <= aw_valid_anker     - last_trans;
                trans_wr.addr_ready_delay <= aw_handshake_anker - aw_valid_anker;
                trans_wr.data_valid_delay <= w_valid_anker      - last_trans;
                trans_wr.data_ready_delay <= w_handshake_anker  - w_valid_anker;
                if (b_valid_seen) begin
                    trans_wr.b_valid_delay <= b_valid_anker     - newer_channel_anker;
                    trans_wr.b_ready_delay <= glb_cnt           - b_valid_anker;
                end
                else begin
                    trans_wr.b_valid_delay <= glb_cnt           - newer_channel_anker;
                    trans_wr.b_ready_delay <= '0;
                end
                last_trans                <= glb_cnt;
                trans_wr.kind             <= WRITE;
                trans_wr_done             <= 1'b1;
                aw_valid_seen <= '0;
                w_valid_seen <= '0;
                b_valid_seen <= '0;
            end
        end
    end

    assign newer_channel_anker = (aw_handshake_anker > w_handshake_anker) ?
                                    aw_handshake_anker : w_handshake_anker;

    //READ
    always_ff @(posedge bus.clk) begin
        if(bus.rst_n) begin
            trans_rd_done  <= '0;
            ar_valid_anker <= '0;
            r_valid_anker  <= '0;
        end else begin

        end
    end

    //COUNTER
    always_ff @(posedge bus.clk) begin
        if(bus.rst_n) begin
            glb_cnt <= '0;
        end else begin
            glb_cnt <= glb_cnt + 1;
        end
    end


    `ifndef SYNTHESIS

    task automatic wait_frame(output axil_trans_t t);
        do @(posedge bus.clk); while(!trans_done);
        t = trans;
    endtask

    task automatic wait_reset_done();
        @(posedge bus.clk iff bus.rst_n);
    endtask

    `endif
endinterface
