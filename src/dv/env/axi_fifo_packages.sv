
package axi_fifo_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  // AXI VIP Packages

  import axi4_globals_pkg::*;
  import axi4_master_pkg::*;
  import axi4_slave_pkg::*;

  // CPU Package
  import cpu_sequence_item_pkg::*;
  import cpu_active_agent_pkg::*;
  import cpu_passive_agent_pkg::*;
  import cpu_pkg::*;

  // Integration Components
  `include "axi_fifo_virtual_sequencer.sv"
  `include "axi_fifo_environment.sv"
  //`include "axi_fifo_scoreboard.sv"
  `include "axi_fifo_report_server.sv"

endpackage : axi_fifo_pkg 
