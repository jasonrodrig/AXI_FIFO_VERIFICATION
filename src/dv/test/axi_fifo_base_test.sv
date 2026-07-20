class axi_fifo_base_test extends uvm_test;

  `uvm_component_utils(axi_fifo_base_test)
  cpu_sequence_item seq;
  axi_fifo_environment env;
  axi_fifo_report_server srv;
  axi_fifo_virtual_base_sequence vseq;

  extern function new(string name = "axi_fifo_base_test", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass

function axi_fifo_base_test::new(string name = "axi_fifo_base_test", uvm_component parent);
  super.new(name,parent);
endfunction

function void axi_fifo_base_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
  env = axi_fifo_environment::type_id::create("env", this);
  srv = new();
  uvm_report_server::set_server(srv);
endfunction

function void axi_fifo_base_test::end_of_elaboration_phase(uvm_phase phase);
  uvm_top.print_topology();
endfunction

task axi_fifo_base_test::run_phase(uvm_phase phase);
  phase.raise_objection(this);
  vseq = axi_fifo_virtual_base_sequence::type_id::create("vseq");
  vseq.start(env.vseqr);
  //phase.phase_done.set_drain_time(this, 20);
  phase.drop_objection(this);
endtask
