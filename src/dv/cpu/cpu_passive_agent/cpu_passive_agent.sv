class cpu_passive_agent extends uvm_agent;

  `uvm_component_utils(cpu_passive_agent)

  cpu_passive_monitor cpu_pass_mon;

  extern function new(string name = "cpu_passive_agent",
                      uvm_component parent);

  extern function void build_phase(uvm_phase phase);

endclass


function cpu_passive_agent::new(string name = "cpu_passive_agent",
                                uvm_component parent);
  super.new(name, parent);
endfunction


function void cpu_passive_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);

  cpu_pass_mon = cpu_passive_monitor::type_id::create("cpu_pass_mon", this);

endfunction
