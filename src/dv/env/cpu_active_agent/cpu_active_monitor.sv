class cpu_active_monitor extends uvm_monitor;
  uvm_component_utils(cpu_active_monitor)
  virtual axi_fifo_interface vif;
  uvm_analysis_port#(cpu_seq_item) a_mon_port;
  cpu_seq_item in_item;

  extern function new(string name = "cpu_active_monitor",  uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass: cpu_active_monitor

function cpu_active_monitor::new(string name = "cpu_active_monitor",  uvm_component parent = null);
  super.new(name, parent);
endfunction: new

function void cpu_active_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  a_mon_port = new("a_mon_port", this);
  if( !(uvm_config_db#(virtual axi_fifo_interface)::get(this, "", "vif", vif) )
    `uvm_error("ACTIVE MONITOR", "NO VIRTUAL INTERFACE IN ACTIVE MONITOR")
endfunction: build_phase

task cpu_active_monitor::run_phase(uvm_phase phase);
  repeat(2)@(vif.mon_cb);
  forever begin
    in_item = cpu_seq_item::type_id::create("in_item");
    repeat(1)@(vif.mon_cb);
    
    a_mon_port.write(in_item);
    `uvm_info("CPU-ACT-MON ", $sformatf( ), UVM_LOW)
    repeat(1)@(vif.mon_cb);
  end
endtask: run_phase

