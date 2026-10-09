// Define the if not virtual, bfm is hdl side not hvl => Thus as a port, not in the class
interface axil_mon_bfm (axil_if.mon bus);
    // Ich schau ob bei Read oder Write zuerst ein valid anliegt, dann diejenigen channels tracken (3w oder 2r) und
    // Dazu dann ab dem valid den ready delay messen

    axil_trans_t trans_wr;
    bit          trans_wr_done;

    axil_trans_t trans_rd;
    bit          trans_rd_done;

    //WRITE
    always_ff @(posedge bus.clk) begin
        if(bus.rst_n) begin
            //Reset only control signals due to AMD reset convention
            trans_wr_done <= '0;
        end else begin

        end
    end

    //READ
    always_ff @(posedge bus.clk) begin
        if(bus.rst_n) begin
            trans_rd_done <= '0;
        end else begin

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
