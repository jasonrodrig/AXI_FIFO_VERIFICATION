package axi_fifo_test_pkg;

  //-------------------------------------------------------
  // Import uvm package
  //-------------------------------------------------------
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import axi4_globals_pkg::*;
  import axi4_slave_pkg::*;
  import cpu_sequence_item_pkg::*;
  import axi_sequence_pkg::*;
  import cpu_sequence_pkg::*; 
  import axi_fifo_pkg::*;
  import axi_fifo_virtual_sequence_pkg::*;

  //including base_test for testing
  `include "axi_fifo_base_test.sv"

endpackage : axi_fifo_test_pkg
