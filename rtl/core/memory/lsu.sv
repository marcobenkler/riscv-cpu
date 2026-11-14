module lsu
import lsu_pkg::*;
import axi_pkg::*;
(
    // pipeline_part (thick arrows in mem_stage.svg)
    input  logic         clk,
    input  logic         rst_n,
    input  logic [31:0]  address,
    input  logic [31:0]  input_data,
    input  mem_op_type_e op,
    input  logic         mem_req,
    input  logic         pipe_stall,
    output logic [31:0]  output_data,
    output logic         lsu_stall,
    output lsu_excep_e   lsu_except,

    // axi part (thin arrow in mem_stage.svg)
    output axi_req_t    axi_req_lsu,
    input  axi_rsp_t    axi_rsp_lsu
);

logic       is_store;
logic [3:0] comp_strb;
state_t     state_q;
state_t     state_d;

assign is_store = (op == SB || op == SH || op == SW);

// comp lsu exception

always_comb begin
    lsu_except = NONE;
    if (is_store) begin
        if      (axi_rsp_lsu.bresp == OKAY)   lsu_except = NONE;
        else if (axi_rsp_lsu.bresp == EXOKAY) lsu_except = STORE_ACC_FLT;
        else if (axi_rsp_lsu.bresp == SLVERR) lsu_except = STORE_ACC_FLT;
        else if (axi_rsp_lsu.bresp == DECERR) lsu_except = STORE_ADDR_MIS;
    end
    else begin
        if      (axi_rsp_lsu.rresp == OKAY)   lsu_except = NONE;
        else if (axi_rsp_lsu.rresp == EXOKAY) lsu_except = LOAD_ACC_FLT;
        else if (axi_rsp_lsu.rresp == SLVERR) lsu_except = LOAD_ACC_FLT;
        else if (axi_rsp_lsu.rresp == DECERR) lsu_except = LOAD_ADDR_MIS;
    end
end

// comp strobe
always_comb begin
    if      (op == SB) comp_strb = 4'b0001;
    else if (op == SH) comp_strb = 4'b0011;
    else               comp_strb = 4'b1111;
end

// AXI
// standard dq states, for stalls to be instant without workarounds
always_ff@(posedge clk) begin
    if (!rst_n) state_q <= IDLE;
    else        state_q <= state_d;
end

always_comb begin
    axi_req_lsu.awaddr = address;
    axi_req_lsu.awprot = 3'b001;
    axi_req_lsu.wdata  = input_data;
    axi_req_lsu.wstrb  = comp_strb;
    axi_req_lsu.araddr = address;
    axi_req_lsu.arprot = 3'b001;
end

// sign/zero extension
always_comb begin
    if      (op == LB)  output_data = {{24{axi_rsp_lsu.rdata[7]}} ,axi_rsp_lsu.rdata[7:0]};
    else if (op == LH)  output_data = {{16{axi_rsp_lsu.rdata[15]}} ,axi_rsp_lsu.rdata[15:0]};
    else if (op == LH)  output_data = axi_rsp_lsu.rdata;
    else if (op == LBU) output_data = {24'b0 ,axi_rsp_lsu.rdata[7:0]};
    else if (op == LHU) output_data = {16'b0 ,axi_rsp_lsu.rdata[15:0]};
    else output_data = 32'hAAAA_AAAA;
end

always_comb begin
    state_d    = state_q;
    lsu_stall  = 1'b0;
    lsu_except = NONE;
    case (state_q)
        IDLE: begin
            if (mem_req) begin
                lsu_stall = 1'b1;
                state_d = (is_store) ? STORE_AW_W : LOAD_AR;
            end
        end
        STORE_AW_W: begin
            lsu_stall       = 1'b1;
            axi_req_lsu.awvalid = 1'b1;
            axi_req_lsu.wvalid  = 1'b1;
            if (axi_rsp_lsu.awready && axi_rsp_lsu.wready) state_d = STORE_B;
        end
        STORE_B: begin
            lsu_stall = 1'b1;
            axi_req_lsu.bready = 1'b1;
            // if pipe is stalled an state set to IDLE bresp is thrown away
            if (axi_rsp_lsu.bvalid && !pipe_stall) begin
                state_d = IDLE;
                // resp_b_vld = 1'b1; not needed. If err occurs output except occurs
                // else lsu_stall is just set to 0
            end
        end
        LOAD_AR: begin
            lsu_stall = 1'b1;
            axi_req_lsu.arvalid = 1'b1;
            if (axi_rsp_lsu.arready) state_d = LOAD_R;
        end
        LOAD_R: begin
            lsu_stall = 1'b1;
            axi_req_lsu.rready = 1'b1;
            if (axi_rsp_lsu.rvalid) state_d = IDLE;
        end
        default: state_d = IDLE;
    endcase
end

endmodule
