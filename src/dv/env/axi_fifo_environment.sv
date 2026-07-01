class axi_fifo_environment extends uvm_env;

  `uvm_component_utils(axi_fifo_environment)
  cpu_active_agent act_agt;
  axi_fifo_passive_agent pas_agt;
  axi_fifo_scoreboard  scb;
  axi_fifo_subscriber  sub;

  extern function new(string name = "axi_fifo_environment", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass

function axi_fifo_environment::new(string name = "axi_fifo_environment", uvm_component parent);
  super.new(name, parent);
endfunction

function void axi_fifo_environment::build_phase(uvm_phase phase);
  super.build_phase(phase);
  act_agt = cpu_active_agent::type_id::create("active_agt", this);
  pas_agt = axi_fifo_passive_agent::type_id::create("passive_agt", this);
  scb = axi_fifo_scoreboard::type_id::create("scb", this);
  sub = axi_fifo_subscriber::type_id::create("sub", this);

  // need to think on axi slave vip building the componenents and the configuraions
  set_config_int("act_agt","is_active",UVM_ACTIVE);
  set_config_int("pas_agt","is_passive",UVM_PASSIVE);

endfunction

function void axi_fifo_environment::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  act_agt.a_mon_h.a_mon_port.connect(scb.act_scb_port);
  act_agt.a_mon_h.a_mon_port.connect(sub.analysis_export);
  pas_agt.axi_fifo_pass_mon.passive_mon_port.connect(sub.analysis_export);
  pas_agt.axi_fifo_pass_mon.passive_mon_port.connect(sub.pass_scb_port);

  // need to think on axi slave vip connecting the componenents

endfunction


