class cpu_sequencer extends uvm_sequencer #(cpu_sequence_item);

  `uvm_component_utils(cpu_sequencer)

  //-----------------------------------------------------------
  // CONSTRUCTOR
  //-----------------------------------------------------------
  function new(string name = "cpu_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass : cpu_sequencer

