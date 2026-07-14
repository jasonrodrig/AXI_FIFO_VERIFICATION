
package axi_fifo_pkg;

   import uvm_pkg::*;
   `include "uvm_macros.svh"

   // AXI VIP Packages
   
   import axi4_globals_pkg::*;
   import axi4_master_pkg::*;
   import axi4_slave_pkg::*;
      
   // DVP Package
   import cpu_pkg::*;

   // Integration Components
   `include "axi_fifo_virtual_sequencer.sv"
   `include "axi_fifo_environment.sv"

   // Sequences & Test
   `include "axi_fifo_report_server.sv"
   `include "axi_slave_bk_base_seq.sv" // VIP Base
   `include "axi_fifo_virtual_base_sequence.sv"  // Virtual sequence
   `include "axi_fifo_base_test.sv"    // Test

endpackage 
