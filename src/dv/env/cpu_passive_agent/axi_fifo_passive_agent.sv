class axi_fifo_passive_agent extends uvm_agent;

  `uvm_component_utils(axi_fifo_passive_agent)
  axi_fifo_passive_monitor axi_fifo_pass_mon;

  extern function new(string name = "axi_fifo_passive_agent", uvm_component parent); 
  extern function void build_phase(uvm_phase phase);

endclass 

function axi_fifo_passive_agent::new(string name = "axi_fifo_passive_agent", uvm_component parent);
  super.new(name, parent);
endfunction 

function void axi_fifo_passive_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(get_is_passive() == UVM_PASSIVE) begin
    axi_fifo_pass_mon = axi_fifo_passive_monitor::type_id::create("axi_fifo_pass_mon", this);
  end
endfunction



