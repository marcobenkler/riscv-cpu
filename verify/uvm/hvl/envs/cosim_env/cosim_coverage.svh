class cosim_coverage extends uvm_subscriber #(retire_item);
    `uvm_component_utils(cosim_coverage)

    covergroup cg with function sample(retire_item t);
        cp_instr_category: coverpoint t.rvfi.instr {
            `include "instr_bins.svh"
        }

        cp_rd: coverpoint t.rvfi.instr[11:7] iff (t.rvfi.reg_write){
            bins regi[] = {[0:31]};
        }

        cp_rs1: coverpoint t.rvfi.instr[19:15] iff (uses_rs1(t.rvfi.instr[6:0])){
            bins regi[] = {[0:31]};
        }

        cp_rs2: coverpoint t.rvfi.instr[24:20] iff (uses_rs2(t.rvfi.instr[6:0])){
            bins regi[] = {[0:31]};
        }

        cp_csr_addr: coverpoint t.rvfi.csr_addr {
            bins mstatus = {12'h300};
            bins mie     = {12'h304};
            bins mtvec   = {12'h305};
            bins mepc    = {12'h341};
            bins mcause  = {12'h342};
            bins mtval   = {12'h343};
            bins mip     = {12'h344};
        }

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    function void write(retire_item t);
        cg.sample(t);
    endfunction

    static function bit uses_rs1(bit [6:0] opcode);
        // U and J Type
        return (opcode != 7'b1101111) && (opcode != 7'b0110111);
    endfunction

    static function bit uses_rs2(bit [6:0] opcode);
        // U and J and I Type
        return (opcode != 7'b1101111) && (opcode != 7'b0110111) && (opcode != 7'b0010011);
    endfunction

endclass
