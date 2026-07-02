class cpu_driver extends uvm_driver #(cpu_sequence_item);

  `uvm_component_utils(cpu_driver)
  virtual fifo_interface.CPU_DRIVER_MP fifo_vif;
  extern function new(string name = "cpu_driver", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task drive_to_dut();

endclass : cpu_driver

function cpu_driver::new(string name = "cpu_driver", uvm_component parent);
  super.new(name, parent);
endfunction

function void cpu_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db #(virtual fifo_interface)::get(this, "", "fifo_vif", fifo_vif))
    `uvm_fatal(get_type_name(), "failed to get fifo virtual interface")
endfunction

task cpu_driver::run_phase(uvm_phase phase);
  forever begin
    seq_item_port.get_next_item(req);
    drive_to_dut();
    seq_item_port.item_done();
  end
endtask

task cpu_driver::drive_to_dut();
  @(fifo_vif.cpu_driver_cb);
 // coding logic  
endtask





