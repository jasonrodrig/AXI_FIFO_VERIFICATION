
package cpu_active_agent_pkg;

  //-------------------------------------------------------
  // Import uvm package
  //-------------------------------------------------------
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import cpu_sequence_item_pkg::*;

  //-------------------------------------------------------
  // Include all other files
  //-------------------------------------------------------

  `include "cpu_sequencer.sv"
  `include "cpu_driver.sv"
  `include "cpu_active_monitor.sv"
  `include "cpu_active_agent.sv"
  
endpackage : cpu_active_agent_pkg
