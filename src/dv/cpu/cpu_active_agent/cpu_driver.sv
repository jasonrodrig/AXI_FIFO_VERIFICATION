class cpu_driver extends uvm_driver #(cpu_sequence_item);

  `uvm_component_utils(cpu_driver)
  virtual fifo_interface.CPU_DRIVER_MP fifo_vif;

  extern function new(string name = "cpu_driver", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task drive_to_dut();

endclass : cpu_driver


//==============================================================
// Constructor
//==============================================================
function cpu_driver::new(string name = "cpu_driver", uvm_component parent);
  super.new(name, parent);
endfunction

//==============================================================
// Build Phase
//==============================================================
function void cpu_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual fifo_interface)::get(this, "", "fifo_vif", fifo_vif))
    `uvm_fatal(get_type_name(),"Failed to get virtual interface")
endfunction


//==============================================================
// Run Phase
//==============================================================
task cpu_driver::run_phase(uvm_phase phase);
  repeat(2)@(fifo_vif.cpu_driver_cb);
  forever begin
    seq_item_port.get_next_item(req);
    drive_to_dut();
    seq_item_port.item_done();
  end
endtask


//==============================================================
// Drive Task
//==============================================================
task cpu_driver::drive_to_dut();
 
  //------------------------------------------------------------
  // READ ONLY
  //------------------------------------------------------------
  if(req.rd_en && !req.wr_en)
  begin
    fifo_vif.cpu_driver_cb.wr_en   <= 0;
    fifo_vif.cpu_driver_cb.rd_en   <= 1;
    fifo_vif.cpu_driver_cb.wr_data <= '0;
    @(fifo_vif.cpu_driver_cb);
  end


  //------------------------------------------------------------
  // WRITE ONLY
  //------------------------------------------------------------
  else if(req.wr_en && !req.rd_en)
  begin
    fifo_vif.cpu_driver_cb.wr_en <= 1;
    fifo_vif.cpu_driver_cb.rd_en <= 0;
    foreach(req.fifo_word[i])
    begin
      fifo_vif.cpu_driver_cb.wr_data <= req.fifo_word[i];
      @(fifo_vif.cpu_driver_cb);
    end
  end

  //------------------------------------------------------------
  // SIMULTANEOUS READ & WRITE
  //------------------------------------------------------------
  else if(req.wr_en && req.rd_en)
  begin
    fifo_vif.cpu_driver_cb.wr_en <= 1;
    fifo_vif.cpu_driver_cb.rd_en <= 1;

    foreach(req.fifo_word[i])
    begin
      fifo_vif.cpu_driver_cb.wr_data <= req.fifo_word[i];
      @(fifo_vif.cpu_driver_cb);
    end
  end
  
  //------------------------------------------------------------
  // IDLE AFTER EVERY TRANSACTION
  //------------------------------------------------------------
  fifo_vif.cpu_driver_cb.wr_en   <= 0;
  fifo_vif.cpu_driver_cb.rd_en   <= 0;
  fifo_vif.cpu_driver_cb.wr_data <= '0;
  @(fifo_vif.cpu_driver_cb);

endtask
