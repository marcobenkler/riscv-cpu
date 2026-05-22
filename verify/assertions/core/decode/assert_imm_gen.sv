module assert_imm_gen();

    logic [31:0] instruction;
    logic [31:0] imm;

    logic [31:0] testvectors [5] = '{
        32'hABCDE2B7,
        32'h000010B7,
        32'hFFFFF537,
        32'h123450B7,
        32'h800007B7
    };

    int err_count = 0;
    int succ_count = 0;

    imm_gen imm_gen(
        .instruction(instruction),
        .imm(imm)
    );

    initial begin
        for (int i = 0; i < $size(testvectors); i++) begin
            instruction = testvectors[i];
            #1;
            assert final (imm[11:0] == 12'b0 && imm[31:12] == instruction[31:12]) begin
                succ_count++;
                $info("[%1d] U-Type immedate generation is correct", i+1);
            end
            else begin
                err_count++;
                $error("[%1d] U-Type immediate generation is wrong", i+1);
            end
        end
        $display("Error:   %d\nSuccess: %d", err_count, succ_count);
    end

endmodule
