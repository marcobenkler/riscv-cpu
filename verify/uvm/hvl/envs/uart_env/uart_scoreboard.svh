`uvm_analysis_imp_decl(_sink)
`uvm_analysis_imp_decl(_source)

class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)
    uvm_analysis_imp_sink   #(uart_item, uart_scoreboard) item_collected_sink;
    uvm_analysis_imp_source #(uart_item, uart_scoreboard) item_collected_source;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        // AP in new better -> They exist whenever the comp is created
        // Works in build_phase as well, connect is later anyways
        item_collected_sink = new("item_collected_sink", this);
        item_collected_source = new("item_collected_source", this);
    endfunction

    // Take Queue, fill with values from source. Compare with values from sink
    uart_item queue[$];
    int       err_cnt;
    int       suc_cnt;

    function write_source(uart_item item);
        queue.push_back(item);
    endfunction

    function write_sink(uart_item item);
        uart_item exp;
        exp = queue.pop_front();
        if (item.data != exp.data || item.frame_err != exp.frame_err) begin
            `uvm_error("MISSMATCH", $sformatf(
                "exp data=0x%h, frame_err=%b, got data=0x%h, frame_err=%b",
                exp.data, exp.frame_err, item.data, item.frame_err
            ))
            err_cnt++;
        end
        else suc_cnt++;
    endfunction

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (queue.size() != 0)
            `uvm_error("MISSING", $sformatf("%b items still missing", queue.size()))
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB", $sformatf("%b frames matched, %b frames missmatched", suc_cnt, err_cnt))
    endfunction
endclass
