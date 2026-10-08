package axil_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "dv_macros.svh"

    import common_axil_pkg::*;

    `include "axil_config.svh"
    `include "axil_item.svh"

    //Space for all sequences
    `include "axil_sequence.svh"

    //

    `include "axil_sequencer.svh"
    `include "axil_driver.svh"
    `include "axil_monitor.svh"
    `include "axil_agent.svh"
endpackage : axil_agent_pkg
