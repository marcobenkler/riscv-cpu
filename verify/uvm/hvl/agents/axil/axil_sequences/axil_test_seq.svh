class axil_test_seq extends uvm_sequence;
    `uvm_object_utils(axil_test_seq)

    function new(string name = "axil_test_seq");
        super.new(name);
    endfunction

    virtual task body();
        req = axil_item::type_id::create("req");
        start_item(req); finish_item(req); // item was filled from sub_bfm
        if (req.aborted) continue;
        `uvm_info("TST_SEQ", "Item got from bfm and checked for abortion", UVM_DEFAULT)
        start_item(req);
        if(!req.randomize(resp))
            `uvm_fatal("RND", {"Could not randomize resp for: ", get_full_name()})
        if (req.kind == READ) begin
            if (!req.randomize(data))
            `uvm_fatal("RND", {"Could not randomize data for: ", get_full_name()})
        end
        finish_item(req);
    endtask
endclass
