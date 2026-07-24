//--------------------------------------------------------------------------------------------
// Class: axi4_slave_bk_base_seq 
// creating axi4_slave_bk_base_seq class extends from uvm_sequence
//--------------------------------------------------------------------------------------------
class axi_slave_bk_base_seq extends uvm_sequence #(axi4_slave_tx);
  //factory registration
  `uvm_object_utils(axi_slave_bk_base_seq)

  //-------------------------------------------------------
  // Externally defined Function
  //-------------------------------------------------------
  extern function new(string name = "axi_slave_bk_base_seq");
  extern task body();
endclass : axi_slave_bk_base_seq

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes the axi4_slave_sequence class object
//
// Parameters:
//  name - instance name of the config_template
//-----------------------------------------------------------------------------
function axi_slave_bk_base_seq::new(string name = "axi_slave_bk_base_seq");
  super.new(name);
endfunction : new

//-----------------------------------------------------------------------------
// Task : body
// based on the request from driver task will drive the transactions
//-----------------------------------------------------------------------------
task axi_slave_bk_base_seq::body();
  req = axi4_slave_tx::type_id::create("req");

//  req.transfer_type=BLOCKING_WRITE;
//  req.no_of_wait_states = 0;
   start_item(req); 
   if(!req.randomize)`uvm_fatal("axi4","Rand failed") 
   finish_item(req);
  req.print();

endtask : body

