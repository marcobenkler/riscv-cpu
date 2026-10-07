class uart_vsequence extends uvm_sequence;
    `uvm_object_utils(uart_vsequence)

    uart_sequencer seqcr;

    `uvm_object_new

    task body();
        uart_sequence       a;
        uart_sequence_cross seq_cross;
        uart_sequence_trans seq_trans;
        if (seqcr == null)
            `uvm_fatal("NO_SEQCR", {"No sequencer found in: ", get_full_name()})
        a = uart_sequence::type_id::create("a");
        seq_cross = uart_sequence_cross::type_id::create("seq_cross");
        seq_trans = uart_sequence_trans::type_id::create("seq_trans");
        a.start(seqcr);
        seq_cross.start(seqcr);
        seq_trans.start(seqcr);
    endtask

endclass
