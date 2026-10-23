class retire_item extends uvm_sequence_item;
    rvfi_t     rvfi;
    bit [31:0] order;
    bit [31:0] cycle;

    `uvm_object_utils(retire_item)

    function new(string name = "retire_item");
        super.new(name);
    endfunction


endclass
