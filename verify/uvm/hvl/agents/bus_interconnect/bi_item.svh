class bi_item extends uvm_sequence_item;
    `uvm_object_utils(bi_item)

    rand bit [7:0]  wdata;
    rand bit [31:0] addr;

    bit      [7:0]  rdata;
endclass
