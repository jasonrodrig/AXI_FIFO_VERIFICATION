class axi_fifo_base_test extends uvm_test;

  `uvm_component_utils(axi_fifo_base_test)
  cpu_sequence_item seq;
  axi_fifo_environment env;
  axi_fifo_report_server srv;

  extern function new(string name = "axi_fifo_base_test", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void end_of_elaboration();
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

function void axi_fifo_base_test::end_of_elaboration();
  uvm_top.print_topology();
endfunction

task axi_fifo_base_test::run_phase(uvm_phase phase);
  phase.raise_objection(this);
  seq = cpu_sequence_item::type_id::create("seq");
  seq.start(env.act_agt.sqr_h);
  //phase.phase_done.set_drain_time(this, 20);
  phase.drop_objection(this);
endtask
