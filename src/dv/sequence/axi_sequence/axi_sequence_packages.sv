
  package axi_sequence_pkg;

  //-------------------------------------------------------
  // Import uvm package
  //-------------------------------------------------------
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import axi4_globals_pkg::*;
  import axi4_slave_pkg::*;

  //-------------------------------------------------------
  // Importing the required packages
  //-------------------------------------------------------
  `include "axi_slave_bk_base_seq.sv"
  `include "response_id_0_slave_seq.sv"
  `include "response_id_1_slave_seq.sv"
  `include "response_id_2_slave_seq.sv"
  `include "response_id_3_slave_seq.sv"

endpackage : axi_sequence_pkg
