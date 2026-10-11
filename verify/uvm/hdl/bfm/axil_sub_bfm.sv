interface axil_sub_bfm #(
    parameter logic [15:0] aw_seed = 2874,
    parameter logic [15:0] w_seed  = 32145,
    parameter logic [15:0] ar_seed = 17095,
    parameter logic [15:0] zero    = 16000,
    parameter logic [15:0] low     = 30000,
    parameter logic [15:0] mid     = 41000,
    parameter logic [15:0] high    = 52000,
    parameter logic [15:0] ultra   = 60000
)(axil_if.sub bus);
    axil_trans_t trans;

    // Filled from HVL transaction
    // Depending on the kind
    // WRITE: Filled with bresp and bvalid
    // READ:  Filled with rdata, rresp, rvalid
    // Because the answer of the slave is always min 1 clk buffered, the delay can be
    // set clean by den HVL
    axil_trans_t trans_returned;

    // assignment in declaration usefull, if bit is set by function
    logic resp_req = 1'b0;
    logic resp_ack;

    logic [15:0] lfsr_aw;
    logic [15:0] lfsr_w;
    logic [15:0] lfsr_ar;

    logic [3:0] awready_delay;
    logic [3:0] wready_delay;
    logic [3:0] arready_delay;

    rdy_state_e aw_state;
    rdy_state_e w_state;
    rdy_state_e ar_state;

    vld_state_e b_state;
    vld_state_e r_state;

    logic [3:0] aw_cnt;
    logic [3:0] w_cnt;
    logic [3:0] ar_cnt;
    logic [3:0] b_cnt;
    logic [3:0] r_cnt;

    logic aw_seen;
    logic w_seen;
    logic ar_seen;
    logic wr_complete;

    logic trans_rdy;

    logic trans_done;

    assign trans_done = (bus.bvalid && bus.bready) || (bus.rvalid && bus.rready);

    // FSM for managing AW, W and AR delays
    always_ff @(posedge bus.clk) begin
        if (!bus.rst_n) begin
            aw_cnt   <= awready_delay;
            w_cnt    <= wready_delay;
            ar_cnt   <= arready_delay;
            aw_state <= (awready_delay == 0) ? RDY : CNT;
            w_state  <= (wready_delay == 0) ? RDY : CNT;
            ar_state <= (arready_delay == 0) ? RDY : CNT;
        end else begin
            case(aw_state)
                //Set new delay and switch in the next transaction state
                RDY: if (bus.awvalid) begin
                    aw_cnt   <= awready_delay;
                    aw_state <= (awready_delay == 0) ? RDY : CNT;
                end
                //Ready takes some time
                CNT: if (bus.awvalid) begin
                    if (aw_cnt == 1) aw_state <= RDY;
                    aw_cnt <= aw_cnt - 1;
                end
                default: aw_state <= RDY;
            endcase
            case(w_state)
                //Set new delay and switch in the next transaction state
                RDY: if (bus.wvalid) begin
                    w_cnt   <= wready_delay;
                    w_state <= (wready_delay == 0) ? RDY : CNT;
                end
                //Ready takes some time
                CNT: if (bus.wvalid) begin
                    if (w_cnt == 1) w_state <= RDY;
                    w_cnt <= w_cnt - 1;
                end
                default: w_state <= RDY;
            endcase
            case(ar_state)
                RDY: if (bus.arvalid) begin
                    ar_cnt <= arready_delay;
                    ar_state <= (arready_delay == 0) ? RDY : CNT;
                end
                CNT: if (bus.arvalid) begin
                    if (ar_cnt == 1) ar_state <= RDY;
                    ar_cnt <= ar_cnt - 1;
                end
                default: ar_state <= RDY;
            endcase
        end
    end

    assign bus.awready = (aw_state == RDY);
    assign bus.wready  = (w_state == RDY);
    assign bus.arready = (ar_state == RDY);

    // Manage filling up trans_item, depending on ready and valid
    always_ff @(posedge bus.clk) begin
        trans_rdy <= 1'b0;
        // AW
        if (bus.awready && bus.awvalid) begin
            trans.addr <= bus.awaddr;
            trans.prot <= bus.awprot;
            aw_seen     <= 1'b1;
        end
        // W
        if (bus.wready && bus.wvalid) begin
            trans.data <= bus.wdata;
            trans.strb <= bus.wstrb;
            w_seen      <= 1'b1;
        end
        // kind works this easy, cause my spec only allows READ or WRITE, never both due to
        // straight cpu (trading easyness against advanced reusabilty)
        // If a WRITE valid is high, that means the CPU wants to write
        if (bus.awvalid) trans.kind <= WRITE;
        // AR
        if (bus.arready && bus.arvalid) begin
            trans.addr <= bus.araddr;
            trans.prot <= bus.arprot;
        end
        if (bus.arvalid) trans.kind <= READ;
        if (wr_complete) begin
            trans_rdy <= 1'b1;
            aw_seen <= 1'b0;
            w_seen <= 1'b0;
        end
    end

    assign wr_complete = ((aw_seen || bus.awready && bus.awvalid) &&
                         (w_seen  || bus.wready  && bus.wvalid)) ||
                         (bus.arready && bus.arvalid);

    always_ff @(posedge bus.clk) begin
        if (!bus.rst_n) begin
            b_state  <= IDLE;
            r_state  <= IDLE;
            b_cnt    <= 0;
            r_cnt    <= 0;
            resp_ack <= resp_req;
        end else begin
            case (b_state)
                IDLE: begin
                    if (resp_req != resp_ack && trans_returned.kind == WRITE) begin
                        b_state <= (trans_returned.b_valid_delay == 0) ? VLD : CNT;
                        resp_ack <= ~resp_ack;
                    end
                end
                VLD: begin
                    if (trans_done) b_state <= IDLE;
                end
                CNT: begin
                    if      (b_cnt == 1) b_state <= VLD;
                    else if (trans_returned.b_valid_delay == 1) b_state <= VLD;
                    else if (b_cnt == 0) b_cnt <= trans_returned.b_valid_delay;
                    else    b_cnt <= b_cnt - 1;
                end
                default: begin
                    b_state <= IDLE;
                    $info("DEFAULT USED IN B_STATE");
                end
            endcase
            case (r_state)
                IDLE: begin
                    if (resp_req != resp_ack && trans_returned.kind == READ) begin
                        r_state <= (trans_returned.r_valid_delay == 0) ? VLD : CNT;
                        resp_ack <= ~resp_ack;
                    end
                end
                VLD: begin
                    if (trans_done) r_state <= IDLE;
                end
                CNT: begin
                    if      (r_cnt == 1) r_state <= VLD;
                    else if (trans_returned.r_valid_delay == 1) r_state <= VLD;
                    else if (r_cnt == 0) r_cnt <= trans_returned.r_valid_delay;
                    else    r_cnt <= r_cnt - 1;
                end
                default: begin
                    r_state <= IDLE;
                    $info("DEFAULT USED IN R_STATE");
                end
            endcase
        end
    end

    assign bus.rresp  = trans_returned.resp;
    assign bus.rdata  = trans_returned.data;
    assign bus.bresp  = trans_returned.resp;
    assign bus.bvalid = b_state == VLD;
    assign bus.rvalid = r_state == VLD;

    //LFSR pseudo random generator. READY Delays need to be generated randomly in the bfm
    // to avoid lookahead logic thats buggy
    always_ff @(posedge bus.clk) begin
        if (!bus.rst_n) begin
            lfsr_aw <= aw_seed;
            lfsr_w  <= w_seed;
            lfsr_ar <= ar_seed;
        end else begin
            lfsr_aw <= {lfsr_aw[14:0], ~(lfsr_aw[15] ^ lfsr_aw[14] ^ lfsr_aw[12] ^ lfsr_aw[3])};
            lfsr_w  <= {lfsr_w[14:0], ~(lfsr_w[15] ^ lfsr_w[14] ^ lfsr_w[12] ^ lfsr_w[3])};
            lfsr_ar <= {lfsr_ar[14:0], ~(lfsr_ar[15] ^ lfsr_ar[14] ^ lfsr_ar[12] ^ lfsr_ar[3])};
        end

    end

    function automatic logic [3:0] map_delay(input logic [15:0] r);
        if      (r < zero)  return 4'b0000;
        else if (r < low)   return 4'b0001;
        else if (r < mid)   return 4'b0100;
        else if (r < high)  return 4'b1000;
        else if (r < ultra) return 4'b1010;
        else                return 4'b1111;
    endfunction

    assign awready_delay = map_delay(lfsr_aw);
    assign wready_delay  = map_delay(lfsr_w);
    assign arready_delay = map_delay(lfsr_ar);

    `ifndef SYNTHESIS

        // Requires 2 tasks not 1. Wait for a trans item to be filled partially
        // Send it to the hvl, that sets the remaining attributes and put it back on

        // Blocking function, waits til the trans item is filled enought
        // i.e. at WRITE with addr, prot, data and strb. Then sends it to the
        // driver, that fills its item with the struct data
        task automatic get_request(output axil_trans_t t, output bit aborted);
            do @(posedge bus.clk); while(!trans_rdy && bus.rst_n);
            t       = trans;
            aborted = !bus.rst_n;
        endtask

        // Non Blocking function, that puts the, from the hvl, filled struct back in the bfm
        // so the answer can be sent back to the manager
        function automatic void put_response(axil_trans_t t);
            trans_returned <= t;
            // cant overried the resp_req if its written in an ff as well
            // -> toggle bits, if resp_req gets toggled, the ff realises the response
            // => resp_req != resp_ack
            resp_req <= ~resp_req;
        endfunction

        task automatic wait_reset_done();
            @(posedge bus.clk iff bus.rst_n);
        endtask

    `endif

endinterface
