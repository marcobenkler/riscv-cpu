/**
* @brief store temporary data for comutes
*
* Receive the data from the instruction vector, store them in registers
* and manage when it's written to
**/

module register_file(
    input  logic [4:0] rs1, rs2, rd,         ///< rs: source register, rd: target register
    input  logic clk, reset_n,               ///< default clock and reset option
    input  logic reg_write,                  ///< enable writing into register
    input  logic [31:0] result,              ///< result of computation
    output logic [31:0] rs1_data, rs2_data   ///< data for compute
);

    logic [31:0] regi [31:0];
    always_comb begin
        rs1_data = regi[rs1];
        rs2_data = regi[rs2];
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            for (int i = 0; i < 32; i++) begin
                regi[i] <= 0;
            end
        end else if(reg_write && rd != '0) begin
            regi[rd] <= result;
        end
    end

endmodule