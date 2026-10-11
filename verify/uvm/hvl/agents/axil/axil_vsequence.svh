class axil_vsequence extends uvm_sequence;
    `uvm_object_utils(axil_vsequence)

    axil_sequencer seqcr;

    `uvm_object_new

    task body();
        if (seqcr == null)
            `uvm_fatal("No sequencer found in axil virtual sequence");
        axil_test_seq test_seq;
        test_seq = axil_test_seq::type_id::create("test_seq");
        test_seq.start(seqcr);
    endtask
endclass
