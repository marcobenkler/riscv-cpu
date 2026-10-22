class retire_trace_writer extends uvm_subscriber#(retire_item);
    `uvm_component_utils(retire_trace_writer)
    `uvm_component_new
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


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        $value$plusargs("TRACE=%s", path);
        fd = $fopen(path, "w")
        if (!fd) `uvm_fatal("NOJSONL", {"Could not oepn jsonl file in: ", get_full_name()})
    endfunction

    function void write(retire_item item);
        forever begin
            jsonl_pc = item.rvfi.pc;
            jsonl_instr = item.rvfi.instr;
            //abused sformats as casting operator
            jsonl_rd_addr   = (item.rvfi.reg_write) ? $sformats("%0d",     item.rvfi.rd_addr)   : "null";
            jsonl_rd_addr   = (item.rvfi.reg_write) ? $sformats("0x%08h",  item.rvfi.rd_data)   : "null";
            jsonl_mem_waddr = (item.rvfi.wr_en)     ? $sformats("0x%08h",  item.rvfi.mem_addr)  : "null";
            jsonl_mem_wdata = (item.rvfi.wr_en)     ? $sformats("0x%08h",  item.rvfi.mem_wdata) : "null";
            jsonl_mem_raddr = (item.rvfi.rd_en)     ? $sformats("0x%08h",  item.rvfi.mem_addr)  : "null";
            jsonl_mem_rdata = (item.rvfi.rd_en)     ? $sformats("0x%08h",  item.rvfi.mem_rdata) : "null";
            jsonl_csr_addr  = (item.rvfi.csr_wr)    ? $sformats("0x%d",    item.rvfi.csr_addr)  : "null";
            jsonl_csr_data  = (item.rvfi.csr_wr)    ? $sformats("0x%08h",  item.rvfi.csr_data)  : "null";

            line =        $sformats("{\"pc\": \"0x%08h\", ", jsonl_pc);
            line = {line, $sformats("\"instr\": \"0x%08h\", ", jsonl_instr)};
            line = {line, $sformats("\"rd_addr\": %s, ", jsonl_rd_addr)};
            line = {line, $sformats("\"rd_data\": \%s\", ", jsonl_rd_data)};
            line = {line, $sformats("\"mem_waddr\": \"%s\", ", json_mem_waddr)};
            line = {line, $sformats("\"mem_wdata\": \"%s\", ", json_mem_wdata)};
            line = {line, $sformats("\"mem_raddr\": \"%s\", ", json_mem_raddr)};
            line = {line, $sformats("\"mem_rdata\": \"%s\", ", json_mem_rdata)};
            line = {line, $sformats("\"csr_addr\": \"%s\", ", json_csr_addr)};
            line = {line, $sformats("\"csr_data\": \"%s\", ", json_csr_data)};

            $fdisplay(fd, "%s" ,line);

        end
    endfunction

    function void final_phase(uvm_phase phase);
        $fclose(fd);
    endfunction

endclass
