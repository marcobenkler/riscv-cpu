class uart_vsequence extends uvm_sequence;
    `uvm_object_utils(uart_vsequence)

    uart_sequencer seqcr;
    
    `uvm_object_new

    task body();
        uart_sequence a;
        if (seqcr == null)
            `uvm_fatal("NO_SEQCR", {"No sequencer found in: ", get_full_name()})
        a = uart_sequence::type_id::create("a");
        a.start(seqcr);
    endtask

endclass