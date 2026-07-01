class axi_fifo_passive_monitor extends uvm_monitor;

  `uvm_component_utils(axi_fifo_passive_monitor)
  virtual axi_fifo_interface.CPU_PASSIVE_MON_MP.vif;
  uvm_analysis_port#(axi_fifo_sequence_item) passive_mon_port;
  axi_fifo_sequence_item seq;

  extern function new (string name = "axi_fifo_passive_monitor", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task axi_fifo_monitor_code();

endclass

function axi_fifo_passive_monitor:: new (string name = "axi_fifo_passive_monitor", uvm_component parent);
  super.new(name, parent);
  passive_mon_port = new("passive_mon_port",this);
endfunction 

function void axi_fifo_passive_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual axi_fifo_interface)::get(this,"","vif", vif))
    `uvm_fatal("NO_VIF",{"virtual interface must be set for: axi_fifo_passive_monitor ",get_full_name(),".vif"});
endfunction

task axi_fifo_passive_monitor::run_phase(uvm_phase phase);
  forever begin  
    seq = axi_fifo_sequence_item::type_id::create("axi_fifo_seq");
    axi_fifo_monitor_code();   
  end
endtask

task axi_fifo_passive_monitor::axi_fifo_monitor_code();
// monitor logic
@(vif.cpu_passive_mon_cb);
passive_mon_port.write(seq);
endtask
