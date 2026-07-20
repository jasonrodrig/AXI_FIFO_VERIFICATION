
package cpu_passive_agent_pkg;

  //-------------------------------------------------------
  // Import uvm package
  //-------------------------------------------------------
  `include "uvm_macros.svh"
  import uvm_pkg::*; 
  import cpu_sequence_item_pkg::*;
  //-------------------------------------------------------
  // Include all other files
  //-------------------------------------------------------

  `include "cpu_passive_monitor.sv"
  `include "cpu_passive_agent.sv"

endpackage : cpu_passive_agent_pkg
