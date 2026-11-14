package axi_pkg;

typedef enum logic[1:0] {
        OKAY,   //Okay
        EXOKAY, //AXI only
        SLVERR, //Slave reached, but error
        DECERR  //No slave under address
    } resp_e;

typedef struct packed {
    //AW
    logic [31:0] awaddr;
    logic [2:0]  awprot;
    logic        awvalid;
    //W
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic        wvalid;
    //B
    logic        bready;
    //AR
    logic [31:0] araddr;
    logic [2:0]  arprot;
    logic        arvalid;
    //R
    logic        rready;
} axi_req_t;

typedef struct packed {
    //AW
    logic        awready;
    //w
    logic        wready;
    //B
    resp_e       bresp;
    logic        bvalid;
    //AR
    logic        arready;
    //R
    logic [31:0] rdata;
    resp_e       rresp;
    logic        rvalid;
} axi_rsp_t;

endpackage
