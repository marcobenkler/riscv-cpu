class retire_trace_writer extends uvm_subscriber#(retire_item);
    `uvm_component_utils(retire_trace_writer)
    `uvm_component_new
    string path;
    int    fd;

    string line;

    // jsonl inputs
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
        fd = $fopen(path, "w");
        if (!fd) `uvm_fatal("NOJSONL", {"Could not oepn jsonl file in: ", get_full_name()})
    endfunction

    function void write(retire_item item);
            //abused sformatf as casting operator
            jsonl_rd_addr   = (item.rvfi.reg_write) ? $sformatf("%0d",         item.rvfi.rd_addr)   : "null";
            jsonl_rd_data   = (item.rvfi.reg_write) ? $sformatf("\"0x%08h\"",  item.rvfi.rd_data)   : "null";
            jsonl_mem_waddr = (item.rvfi.wr_en)     ? $sformatf("\"0x%08h\"",  item.rvfi.mem_addr)  : "null";
            jsonl_mem_wdata = (item.rvfi.wr_en)     ? $sformatf("\"0x%08h\"",  item.rvfi.mem_wdata) : "null";
            jsonl_mem_raddr = (item.rvfi.rd_en)     ? $sformatf("\"0x%08h\"",  item.rvfi.mem_addr)  : "null";
            jsonl_mem_rdata = (item.rvfi.rd_en)     ? $sformatf("\"0x%08h\"",  item.rvfi.mem_rdata) : "null";
            jsonl_csr_addr  = (item.rvfi.csr_wr)    ? $sformatf("\"0x%0d\"",   item.rvfi.csr_addr)  : "null";
            jsonl_csr_data  = (item.rvfi.csr_wr)    ? $sformatf("\"0x%08h\"",  item.rvfi.csr_data)  : "null";

            line =        $sformatf("{\"pc\": \"0x%08h\", ", item.rvfi.pc);
            line = {line, $sformatf("\"instr\": \"0x%08h\", ", item.rvfi.instr)};
            line = {line, $sformatf("\"rd_addr\": %s, ", jsonl_rd_addr)};
            line = {line, $sformatf("\"rd_data\": %s, ", jsonl_rd_data)};
            line = {line, $sformatf("\"mem_waddr\": %s, ", jsonl_mem_waddr)};
            line = {line, $sformatf("\"mem_wdata\": %s, ", jsonl_mem_wdata)};
            line = {line, $sformatf("\"mem_raddr\": %s, ", jsonl_mem_raddr)};
            line = {line, $sformatf("\"mem_rdata\": %s, ", jsonl_mem_rdata)};
            line = {line, $sformatf("\"csr_addr\": %s, ", jsonl_csr_addr)};
            line = {line, $sformatf("\"csr_data\": %s, ", jsonl_csr_data)};
            line = {line, $sformatf("\"cycle\": %0d, \"order\": %0d}", item.cycle, item.order)};


            $fdisplay(fd, "%s" ,line);

    endfunction

    function void final_phase(uvm_phase phase);
        $fclose(fd);
    endfunction

endclass
