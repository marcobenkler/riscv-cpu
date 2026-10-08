package pipe_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "dv_macros.svh"
    import common_lsu_pkg::*;
    `include "pipe_config.svh"
    `include "pipe_item.svh"

    //Space for all sequences
    `include "pipe_sequence.svh"

    //

    `include "pipe_sequencer.svh"
    `include "pipe_driver.svh"
    `include "pipe_monitor.svh"
    `include "pipe_agent.svh"
endpackage
