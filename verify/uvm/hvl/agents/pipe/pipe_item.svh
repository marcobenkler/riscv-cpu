class pipe_item extends uvm_sequence_item;
    // DATA
    rand bit [31:0]   addr;
    rand bit [31:0]   store_data;
    rand mem_type_e   mem_type;
    rand bit          stall_do;
    rand bit          flush_do;
    bit      [31:0]   load_data;
    lsu_excep_e       lsu_exception;
    bit      [2:0]    mcause;
    bit      [31:0]   mtval;

    // TIMING
    rand int unsigned      stall_at;
    rand int unsigned      stall_duration;
    rand int unsigned      flush_at; //
    rand int unsigned      req_vld_at;
         int unsigned      out_vld_at;
         int unsigned      lsu_stall_at;
         int unsigned      lsu_stall_duration;

    `uvm_object_utils_begin(pipe_item)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(store_data, UVM_ALL_ON)
    `uvm_field_enum(mem_type_e, mem_type, UVM_ALL_ON)
    `uvm_field_int(stall_do, UVM_ALL_ON)
    `uvm_field_int(stall_at, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(stall_duration, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(flush_do, UVM_ALL_ON)
    `uvm_field_int(flush_at, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(load_data, UVM_ALL_ON)
    `uvm_field_int(out_vld_at, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(lsu_stall_at, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(lsu_stall_duration, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_enum(lsu_excep_e, lsu_exception, UVM_ALL_ON)
    `uvm_field_int(mcause, UVM_ALL_ON)
    `uvm_field_int(mtval, UVM_ALL_ON)
    `uvm_field_int(req_vld_at, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function pipe_trans_t to_struct();
        pipe_trans_t t;
        t.addr               = addr;
        t.store_data         = store_data;
        t.mem_type           = mem_type;
        t.stall_do           = stall_do;
        t.flush_do           = flush_do;
        t.load_data          = load_data;
        t.lsu_exception      = lsu_exceptopn;
        t.mcause             = mcause;
        t.mtval              = mtval;
        t.stall_at           = stall_at
        t.stall_duration     = stall_duration;
        t.flush_at           = flush_at;
        t.req_vld_at         = req_vld_at;
        t.out_vld_at         = out_vld_at;
        t.lsu_stall_at       = lsu_stall_at;
        t.lsu_stall_duration = lsu_stall_duration;
        return t;
    endfunction

    function void from_struct(pipe_trans_t t);
        addr               = t.addr;
        store_data         = t.store_data;
        mem_type           = t.mem_type;
        stall_do           = t.stall_do;
        flush_do           = t.flush_do;
        load_data          = t.load_data;
        lsu_exception      = t.lsu_exception;
        mcause             = t.mcause;
        mtval              = t.mtval;
        stall_at           = t.stall_at;
        stall_duration     = t.stall_duration;
        flush_at           = t.flush_at;
        req_vld_at         = t.req_vld_at;
        out_vld_at         = t.out_vld_at;
        lsu_stall_at       = t.lsu_stall_at;
        lsu_stall_duration = t.lsu_stall_duration;
    endfunction

    //constraints
    constraint mem_type_c {
        soft mem_type dist {
            SB  := 10,
            SH  := 10,
            SW  := 10,
            LB  := 10,
            LH  := 10,
            LW  := 10;
            LBU := 20;
            LHU := 20;
        }
    }

    constraint interrupt_c {
        stall_do dist { 0 := 95, 1 := 5 };
        flush_do dist { 0 := 95, 1 := 5 };
    }

    constraint addr_c {
        // mem:    32'h0000_0000:32'h0000_07FF
        // periph: 32'h1000_0000:32'h1000_0008
        // fault: else
        soft addr dist {
            [32'h0000_0000:32'h0000_07FF] :/ 70,
            [32'h1000_0000:32'h1000_0008] :/ 20,
            [32'h0000_0800:32'h0FFF_FFFF] :/ 5,
            [32'h1000_0009:32'hFFFF_FFFF] :/ 5
        };
    }

    constraint data_c {
        soft store_data dist {
            '0                            := 5,
            [32'h0000_0001:32'h5555_5551] :/ 40,
            // Offsets by 2n + 1 are visible instantly
            32'h5555_5555                 := 5,
            [32'h5555_5556:32'hAAAA_AAA9] :/ 40,
            // Offsets by 2n + 1 are visible instantly
            32'hAAAA_AAAA                 := 5,
            '1                            := 5,
        }
    }

    constraint timing_c {
        soft stall_at dist {
            0     := 20,
            [1:2] :/ 30,
            [3:8] :/ 50
        };

        soft flush_at dist {
            0     := 20,
            [1:2] :/ 30,
            [3:8] :/ 50
        }

        soft stall_duration dist {
            1     := 20,
            [1:3] :/ 50,
            [4:6] :/ 30
        }

        soft req_vld_at dist {
            0     := 50,
            [1:2] :/ 40,
            [3:4] :/ 10
        }
    }

endclass
