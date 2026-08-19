class response_id_0_slave_seq extends axi_slave_bk_base_seq;
  `uvm_object_utils(response_id_0_slave_seq)

  //-------------------------------------------------------
  // Externally defined Function
  //-------------------------------------------------------
  extern function new(string name = "response_id_0_slave_seq");
  extern task body();

endclass

function response_id_0_slave_seq::new(string name = "response_id_0_slave_seq");
  super.new(name);
endfunction : new

task response_id_0_slave_seq::body();
  assign_bid(0);
endtask : body


