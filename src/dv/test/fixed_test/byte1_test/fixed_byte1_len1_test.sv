class fixed_byte1_len1_test extends axi_fifo_base_test;

  `uvm_component_utils(fixed_byte1_len1_test)
  
  //axi_fifo_environment env;
  axi_fifo_report_server srv;
  fixed_byte1_len1_virtual_sequence vseq;

  extern function new(string name = "fixed_byte1_len1_test", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass

function fixed_byte1_len1_test::new(string name = "fixed_byte1_len1_test", uvm_component parent);
  super.new(name,parent);
endfunction

function void fixed_byte1_len1_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
  //env = axi_fifo_environment::type_id::create("env", this);
  srv = new();
  uvm_report_server::set_server(srv);
endfunction

function void fixed_byte1_len1_test::end_of_elaboration_phase(uvm_phase phase);
  uvm_top.print_topology();
endfunction

task fixed_byte1_len1_test::run_phase(uvm_phase phase);
  phase.raise_objection(this);
  vseq = fixed_byte1_len1_virtual_sequence::type_id::create("fixed_byte1_len1_vseq");
  vseq.start(env.vseqr);
  //phase.phase_done.set_drain_time(this, 20);
  phase.drop_objection(this);
endtask
