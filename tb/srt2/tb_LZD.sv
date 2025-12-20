`timescale 1ps/1ps

module tb_LZD ();

    //Input
    logic[31:0] D;

    //Output
    logic[5:0] LZ;

    LZD32 dut (.*);

    initial begin
        D = 32'h00000000;
        #10;
        D = 32'b01011011001010101001010010101011;
        #50;
        $finish;
    end

    initial begin
        $dumpfile("sim/LZD.vcd");
        $dumpvars(0, tb_LZD);
    end

endmodule