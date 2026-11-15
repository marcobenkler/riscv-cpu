module tb_uart();

    logic clk;
    logic reset_n;

    initial clk = 0;
    always #5 clk = ~clk;

    pl_cpu u_pl_cpu(.clk(clk), .reset_n(reset_n));

    initial begin
        $dumpfile("sim/uart.fst");
        $dumpvars(0, u_pl_cpu);
        $readmemh("verify/tb/external/uart.hex" ,u_pl_cpu.instruction_memory.memo);
    end

    initial begin
        reset_n = 0;
        #1;

        repeat(2) @(posedge clk);
        reset_n = 1;
        repeat(20000) @(posedge clk);
        $display("DONE");
        $finish;
    end

    assign u_pl_cpu.uart_rx_bit = u_pl_cpu.uart_tx_bit;

endmodule