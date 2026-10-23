class cosim_coverage extends uvm_subscriber #(retire_item);
    `uvm_component_utils(cosim_coverage)
    uvm_analysis_imp#(retire_item, cosim_coverage) imp;

    covergroup cg with function sample(retire_item t);

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
        cg = new();
    endfunction

    function void write(retire_item t);
        cg.sample(t);
    endfunction

endclass
