class axi_fifo_virtual_sequencer extends uvm_sequencer#(uvm_sequence_item);
  
 `uvm_component_utils(axi_fifo_virtual_sequencer)

  cpu_sequencer cpu_seqr_h;

  axi4_master_write_sequencer axi_master_wr_seqr; 
  axi4_master_read_sequencer  axi_master_rd_seqr; 
  axi4_slave_write_sequencer axi_slave_wr_seqr; 
  axi4_slave_read_sequencer  axi_slave_rd_seqr; 

 extern function new(string name = "axi_fifo_virtual_sequencer", uvm_component parent );

endclass : axi_fifo_virtual_sequencer

function axi_fifo_virtual_sequencer::new(string name = "axi_fifo_virtual_sequencer", uvm_component parent );
  super.new(name, parent);
endfunction : new



