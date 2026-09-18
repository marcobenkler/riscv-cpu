`timescale 1ps/1ps

module tb_Norm();

    //Input
    logic [31:0] D, N;


    //Output
    logic [31:0] ND, NN;
    logic [5:0]  LZD, LZN;

    Norm dut (.*);

    initial begin
                $display("t=%0t START Normalizer Test", $time);

        // Monitor
        $monitor("t=%0t D=%h N=%h | ND=%h NN=%h LZD=%0d LZN=%d",
                  $time, D, N, ND, NN, LZD, LZN);

        // Test 1: Einfach
        D = 32'h0001_2340;  
        N = 32'h0000_0010;
        #10;

        // Test 2: D mit vielen leading zeros
        D = 32'h0000_0100;
        N = 32'h0000_0800;
        #10;

        // Test 3: N kleiner als D
        D = 32'h0000_4000;
        N = 32'h0000_0004;
        #10;

        // Test 4: Beide zufällig
        D = 32'h00F0_0003;
        N = 32'h0000_00A0;
        #10;

        $display("t=%0t END Normalizer Test", $time);
        $finish;
    end

    initial begin
        $dumpfile("sim/Norm.vcd");
        $dumpvars(0, tb_Norm);
    end

endmodule