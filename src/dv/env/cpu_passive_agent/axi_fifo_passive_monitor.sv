class axi_fifo_passive_monitor extends uvm_monitor;

  `uvm_component_utils(axi_fifo_passive_monitor)
  virtual fifo_interface.CPU_PASSIVE_MON_MP fifo_vif;
  uvm_analysis_port#(axi_fifo_sequence_item) passive_mon_port;
  axi_fifo_sequence_item seq;

  extern function new (string name = "axi_fifo_passive_monitor", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task axi_fifo_monitor_code();

endclass

function axi_fifo_passive_monitor:: new (string name = "axi_fifo_passive_monitor", uvm_component parent);
  super.new(name, parent);
endfunction 

function void axi_fifo_passive_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  passive_mon_port = new("passive_mon_port",this);
  if(!uvm_config_db#(virtual fifo_interface)::get(this,"","fifo_vif", fifo_vif))
    `uvm_fatal(get_type_name(),{"virtual interface must be set for: axi_fifo_passive_monitor ",get_full_name(),".vif"});
endfunction

task axi_fifo_passive_monitor::run_phase(uvm_phase phase);
  forever begin  
    seq = axi_fifo_sequence_item::type_id::create("axi_fifo_seq");
    axi_fifo_monitor_code();   
  end
endtask

task axi_fifo_passive_monitor::axi_fifo_monitor_code();
// monitor logic
@(fifo_vif.cpu_passive_mon_cb);
passive_mon_port.write(seq);
endtask
