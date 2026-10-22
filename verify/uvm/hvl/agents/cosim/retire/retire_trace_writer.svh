class retire_trace_writer extends uvm_subscriber#(retire_item);
    `uvm_component_utils(retire_trace_write)
    `uvm_analysis_imp#(retire_item) imp;
    string path;
    int    fd;

    string line;

    // jsonl inputs
    string jsonl_pc;
    string jsonl_instr;
    string jsonl_rd_addr;
    string jsonl_rd_data;
    string jsonl_mem_waddr;
    string jsonl_mem_wdata;
    string jsonl_mem_raddr;
    string jsonl_mem_rdata;
    string jsonl_csr_addr;
    string jsonl_csr_data;

    function new(string name, uvm_component parent);
        super.new(name, parent)
        imp = new("new", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        $value$plusargs("TRACE=%s", path);
        if(!fd = $fopen(path, "w"))
            `uvm_fatal("NOJSONL", {"Could not oepn jsonl file in: ", get_full_name()})
    endfunction

    virtual task write(retire_item item);
        forever begin
            jsonl_pc = item.rvfi.pc;
            jsonl_instr = item.rvfi.instr;
            //abused sformat as casting operator
            json_rd_addr   = (item.rvfi.reg_write) ? $sformat("%0d",     item.rvfi.rd_addr)   : "null";
            json_rd_addr   = (item.rvfi.reg_write) ? $sformat("0x%08h",  item.rvfi.rd_data)   : "null";
            json_mem_waddr = (item.rvfi.wr_en)     ? $sformat("0x%08h",  item.rvfi.mem_addr)  : "null";
            json_mem_wdata = (item.rvfi.wr_en)     ? $sformat("0x%08h",  item.rvfi.mem_wdata) : "null";
            json_mem_raddr = (item.rvfi.rd_en)     ? $sformat("0x%08h",  item.rvfi.mem_addr)  : "null";
            json_mem_rdata = (item.rvfi.rd_en)     ? $sformat("0x%08h",  item.rvfi.mem_rdata) : "null";
            json_csr_addr  = (item.rvfi.csr_wr)    ? $sformat("0x%d",    item.rvfi.csr_addr)  : "null";
            json_csr_data  = (item.rvfi.csr_wr)    ? $sformat("0x%08h",  item.rvfi.csr_data)  : "null";

            line =        $sformat("{\"pc\": \"0x%08h\", ", jsonl_pc);
            line = {line, $sformat("\"instr\": \"0x%08h\", ", jsonl_instr)};
            line = {line, $sformat("\"rd_addr\": %s, ", jsonl_rd_addr)};
            line = {line, $sformat("\"rd_data\": \%s\", ", jsonl_rd_data)};
            line = {line, $sformat("\"mem_waddr\": \"%s\", ", json_mem_waddr)};
            line = {line, $sformat("\"mem_wdata\": \"%s\", ", json_mem_wdata)};
            line = {line, $sformat("\"mem_raddr\": \"%s\", ", json_mem_raddr)};
            line = {line, $sformat("\"mem_rdata\": \"%s\", ", json_mem_rdata)};
            line = {line, $sformat("\"csr_addr\": \"%s\", ", json_csr_addr)};
            line = {line, $sformat("\"csr_data\": \"%s\", ", json_csr_data)};

            $fdisplay(fd, "%s" ,line);

        end
    endtask

    function void final_phase(uvm_phase phase);
        $fclose(fd);
    endfunction

endclass
