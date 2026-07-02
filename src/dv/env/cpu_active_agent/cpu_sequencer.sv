class cpu_sequencer extends uvm_sequencer#(cpu_sequence_item);

  `uvm_component_utils(cpu_sequencer)

  extern function new(string name = "cpu_sequencer" , uvm_component parent);

endclass

function cpu_sequencer::new(string name = "cpu_sequencer" , uvm_component parent);
  super.new(name,parent);
endfunction`
