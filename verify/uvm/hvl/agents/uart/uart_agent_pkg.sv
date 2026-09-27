package uart_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Look in the module the pkg is made for, import every pkg needed. They are NOT transistive
    import common_uart_pkg::*;

    `include "uart_config.svh"
    `include "uart_item.svh"
    `include "uart_sequence.svh"
    `include "uart_sequencer.svh"
    `include "uart_driver.svh"
    `include "uart_monitor.svh"
    `include "uart_agent.svh"
endpackage : uart_agent_pkg
