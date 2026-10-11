class axil_item extends uvm_sequence_item;
    // Fused READ and WRITE, only one was used anyways
    rand kind_e       kind;
    rand bit [31:0]   addr;
    rand bit [2:0]    prot; //currently fixed
    rand bit [31:0]   data;
    rand bit [3:0]    strb;
    resp_e            resp;
    bit               aborted; // only used for 2 phase sequence

    rand int unsigned addr_valid_delay;
    rand int unsigned addr_ready_delay;
    rand int unsigned data_valid_delay;
    rand int unsigned data_ready_delay;
    rand int unsigned b_valid_delay;
    rand int unsigned b_ready_delay;

    `uvm_object_utils_begin(axil_item)
    `uvm_field_enum(kind_e, kind, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(prot, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(strb, UVM_ALL_ON)
    `uvm_field_enum(resp_e, resp, UVM_ALL_ON)
    `uvm_field_int(addr_valid_delay, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(addr_ready_delay, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(data_valid_delay, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(data_ready_delay, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(b_valid_delay, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(b_ready_delay, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end
    `uvm_object_new

    function axil_trans_t to_struct();
        axil_trans_t t;
        t.kind             = kind;
        t.addr             = addr;
        t.prot             = prot;
        t.data             = data;
        t.strb             = strb;
        t.resp             = resp;
        t.addr_valid_delay = addr_valid_delay;
        t.addr_ready_delay = addr_ready_delay;
        t.data_valid_delay = data_valid_delay;
        t.data_ready_delay = data_ready_delay;
        t.b_valid_delay    = b_valid_delay;
        t.b_ready_delay    = b_ready_delay;
        return t;
    endfunction

    function void from_struct(axil_trans_t t);
        kind             = t.kind;
        addr             = t.addr;
        prot             = t.prot;
        data             = t.data;
        strb             = t.strb;
        resp             = t.resp;
        addr_valid_delay = t.addr_valid_delay;
        addr_ready_delay = t.addr_ready_delay;
        data_valid_delay = t.data_valid_delay;
        data_ready_delay = t.data_ready_delay;
        b_valid_delay    = t.b_valid_delay;
        b_ready_delay    = t.b_ready_delay;
    endfunction

    constraint delay_c {
        soft addr_valid_delay dist {0 := 40, [1:3] := 40, [4:20] := 20};
        soft addr_ready_delay dist {0 := 40, [1:3] := 40, [4:20] := 20};
        soft data_valid_delay dist {0 := 40, [1:3] := 40, [4:20] := 20};
        soft data_ready_delay dist {0 := 40, [1:3] := 40, [4:20] := 20};
        soft b_valid_delay    dist {0 := 40, [1:3] := 40, [4:20] := 20};
        soft b_ready_delay    dist {0 := 40, [1:3] := 40, [4:20] := 20};
    }

    constraint kind_read_c {
        kind == READ -> strb == '0;
    }

    constraint order_c {
        solve kind before strb;
    }

    constraint fix_prot_c {
        //[2] data access [1] secure zone [0] priviledged
        soft prot == 3'b001;
    }


endclass
