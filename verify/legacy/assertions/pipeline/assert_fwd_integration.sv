module assert_fwd_integration(
    input logic        clk,
    input logic        reset_n,
    input logic [4:0]  rs1_EX,
    input logic [4:0]  rs2_EX,
    input logic [4:0]  rd_MEM,
    input logic        reg_write_MEM,
    input logic [4:0]  rd_WB,
    input logic        reg_write_WB,
    input logic [1:0]  fwd_sel_a,
    input logic [1:0]  fwd_sel_b
);
    //FWD_A
    property p_fwd_mem_a;
        @(posedge clk) disable iff (!reset_n)
        (reg_write_MEM && rd_MEM != 0 && rd_MEM == rs1_EX)
        |-> fwd_sel_a == 2'b10;
    endproperty

    property p_fwd_wb_a;
        @(posedge clk) disable iff (!reset_n)
        (reg_write_WB && rd_WB != 0 && rd_WB == rs1_EX)
        |-> fwd_sel_a == 2'b01;
    endproperty

    property p_no_fwd_a;
        @(posedge clk) disable iff (!reset_n)
        (!(reg_write_WB && rd_WB != 0 && rd_WB == rs1_EX) &&
         !(reg_write_MEM && rd_MEM != 0 && rd_MEM == rs1_EX))
        |-> fwd_sel_a == 2'b00;
    endproperty

    property p_fwd_mem_priority_a;
        @(posedge clk) disable iff (!reset_n)
        ((reg_write_WB && rd_WB != 0 && rd_WB == rs1_EX) &&
         (reg_write_MEM && rd_MEM != 0 && rd_MEM == rs1_EX))
        |-> fwd_sel_a == 2'b10;
    endproperty

    //FWD_B
    property p_fwd_mem_b;
        @(posedge clk) disable iff (!reset_n)
        (reg_write_MEM && rd_MEM != 0 && rd_MEM == rs2_EX)
        |-> fwd_sel_b == 2'b10;
    endproperty

    property p_fwd_wb_b;
        @(posedge clk) disable iff (!reset_n)
        (reg_write_WB && rd_WB != 0 && rd_WB == rs2_EX)
        |-> fwd_sel_b == 2'b01;
    endproperty

    property p_no_fwd_b;
        @(posedge clk) disable iff (!reset_n)
        (!(reg_write_WB && rd_WB != 0 && rd_WB == rs2_EX) &&
         !(reg_write_MEM && rd_MEM != 0 && rd_MEM == rs2_EX))
        |-> fwd_sel_b == 2'b00;
    endproperty

    property p_fwd_mem_priority_b;
        @(posedge clk) disable iff (!reset_n)
        ((reg_write_WB && rd_WB != 0 && rd_WB == rs2_EX) &&
         !(reg_write_MEM && rd_MEM != 0 && rd_MEM == rs2_EX))
        |-> fwd_sel_b == 2'b10;
    endproperty

    assert property (p_fwd_mem_a) else $error("MEM-FWD_A MISSING");
    assert property (p_fwd_wb_a) else $error("WB-FWD_A MISSING");
    assert property (p_no_fwd_a) else $error("FWD_A FORWARD WHEN IT SHOULDN'T");
    assert property (p_fwd_mem_priority_a) else $error("FWD_A HAS NO PRIORITY");
    
    assert property (p_fwd_mem_b) else $error("MEM-FWD_A MISSING");
    assert property (p_fwd_wb_b) else $error("WB-FWD_A MISSING");
    assert property (p_no_fwd_b) else $error("FWD_A FORWARD WHEN IT SHOULDN'T");
    assert property (p_fwd_mem_priority_b) else $error("FWD_A HAS NO PRIORITY");
    
    cover property  (p_fwd_mem_a);
    cover property  (p_fwd_wb_a);
    cover property  (p_no_fwd_a);
    cover property  (p_fwd_mem_priority_a);

    cover property  (p_fwd_mem_b);
    cover property  (p_fwd_wb_b);
    cover property  (p_no_fwd_b);
    cover property  (p_fwd_mem_priority_b);

endmodule