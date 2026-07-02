class cpu_active_monitor extends uvm_monitor;

  `uvm_component_utils(cpu_active_monitor)
  virtual fifo_interface.CPU_ACTIVE_MON_MP fifo_vif;
  uvm_analysis_port#(cpu_sequence_item) a_mon_port;
  cpu_sequence_item in_item;

  extern function new(string name = "cpu_active_monitor",  uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass: cpu_active_monitor

function cpu_active_monitor::new(string name = "cpu_active_monitor",  uvm_component parent );
  super.new(name, parent);
endfunction: new

function void cpu_active_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  a_mon_port = new("a_mon_port", this);
  if( !(uvm_config_db#(virtual fifo_interface)::get(this, "", "fifo_vif", fifo_vif) )
   `uvm_fatal(get_type_name(), "NO VIRTUAL INTERFACE IN FIFO ACTIVE MONITOR")
endfunction: build_phase

task cpu_active_monitor::run_phase(uvm_phase phase);
  repeat(2)@(vif.cpu_active_mon_cb);
  forever begin
   in_item = cpu_sequence_item::type_id::create("in_item");
   repeat(1)@(vif.cpu_active_mon_cb);
   // coding logic
   a_mon_port.write(in_item);
  end
endtask: run_phase

