package axi_fifo_virtual_sequence_pkg;

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import axi4_globals_pkg::*;
    import axi4_slave_pkg::*;
    import axi_sequence_pkg::*;
    import cpu_sequence_pkg::*;
    import axi_fifo_pkg::*;
     
    `include "axi_fifo_virtual_base_sequence.sv"
    `include "fixed_virtual_sequence/byte1_virtual_sequence/fixed_byte1_len1_virtual_sequence.sv"

endpackage : axi_fifo_virtual_sequence_pkg
