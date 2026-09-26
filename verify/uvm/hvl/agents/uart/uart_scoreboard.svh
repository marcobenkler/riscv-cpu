class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)
    uvm_analysis_imp#(uart_item, uart_scoreboard) item_collected_sink;
    uvm_analysis_imp#(uart_item, uart_scoreboard) item_collected_source;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function build_phase(uvm_phase phaseP);
        super.build_phase(phase);
        item_collected_sink = new("item_collected_sink", this);
        item_collected_source = new("item_collected_source", this);
    endfunction
endclass
