class uart_monitor extends uvm_monitor;
    virtual uart_bfm bfm;
    uvm_analysis_port#(uart_item) item_collected_port;

    `uvm_component_utils(uart_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual uart_bfm)::get(this, "", "bfm", bfm))
            `uvm_fatal("NO_BFM", {"No BFM found for: ", get_full_name()})
        item_collected_port = new("item_collected_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        uart_item    trans_collected;
        uart_trans_t t;
        forever begin
            bfm.wait_frame(t);
            trans_collected = uart_item::type_id::create("trans_collected");
            trans_collected.from_struct(t);
            item_collected_port.write(trans_collected);
        end
    endtask


endclass
