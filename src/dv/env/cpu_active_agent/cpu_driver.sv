/class cpu_driver extends uvm_driver #(cpu_sequence_item);

  `uvm_component_utils(cpu_driver)
  virtual fifo_interface vif;

  //-----------------------------------------------------------
  // CONSTRUCTOR
  //-----------------------------------------------------------
  function new(string name = "cpu_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //-----------------------------------------------------------
  // BUILD PHASE 
  //-----------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual fifo_interface)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", "cpu_driver: failed to get virtual interface")
  endfunction

  //-----------------------------------------------------------
  // RUN PHASE 
  //-----------------------------------------------------------
  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive_to_dut(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_to_dut(cpu_sequence_item txn);
    // TODO
  endtask

endclass : cpu_driver
/cpu_driver_code
