class uart_agent extends uvm_agent;
    uart_driver    drv;
    uart_monitor   mntr;
    uart_sequencer seqcr;

    uvm_analysis_port#(uart_item) ap;

    `uvm_component_utils(uart_agent)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(get_is_active() == UVM_ACTIVE) begin
            drv = uart_driver::type_id::create("drv", this);
            seqcr = uart_sequencer::type_id::create("seqcr", this);
        end
        mntr = uart_monitor::type_id::create("mntr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(get_is_active() == UVM_ACTIVE)
            drv.seq_item_port.connect(seqcr.seq_item_export);
        ap = mntr.item_collected_port;
    endfunction
endclass

