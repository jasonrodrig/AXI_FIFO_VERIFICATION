class axi_fifo_environment extends uvm_env;

  `uvm_component_utils(axi_fifo_environment)

  cpu_active_agent            act_agt;
  cpu_passive_agent           pas_agt;
  axi_fifo_virtual_sequencer  vseqr;
  axi4_master_agent           axi_master_agt;
  axi4_slave_agent            axi_slave_agt;
  axi4_master_agent_config    axi_master_cfg;
  axi4_slave_agent_config     axi_slave_cfg;
  cpu_subscriber              cpu_sub;

  extern function new(string name = "axi_fifo_environment", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass

function axi_fifo_environment::new(string name = "axi_fifo_environment", uvm_component parent);
  super.new(name, parent);
endfunction

function void axi_fifo_environment::build_phase(uvm_phase phase);
  super.build_phase(phase);

// creating the cfg handle and the configuration in AXI VIP

axi_master_cfg = axi4_master_agent_config::type_id::create("axi_mcfg");
axi_master_cfg.is_active = UVM_PASSIVE;
axi_master_cfg.has_coverage = 1;

axi_slave_cfg = axi4_slave_agent_config::type_id::create("axi_scfg");
axi_slave_cfg.is_active = UVM_ACTIVE;
axi_slave_cfg.has_coverage = 1;

axi_master_agt = axi4_master_agent::type_id::create("axi_magt", this);
axi_slave_agt  = axi4_slave_agent::type_id::create("axi_sagt", this);

axi_master_agt.axi4_master_agent_cfg_h = axi_master_cfg;
axi_slave_agt.axi4_slave_agent_cfg_h   = axi_slave_cfg;

act_agt = cpu_active_agent::type_id::create("cpu_active_agt", this);
pas_agt = cpu_passive_agent::type_id::create("cpu_passive_agt", this);

cpu_sub = cpu_subscriber::type_id::create("cpu_sub", this);
vseqr   = axi_fifo_virtual_sequencer::type_id::create("vseqr", this);

set_config_int("act_agt", "is_active", UVM_ACTIVE);
set_config_int("pas_agt", "is_active", UVM_PASSIVE);

endfunction

function void axi_fifo_environment::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  vseqr.cpu_seqr_h         = act_agt.sqr_h;
  vseqr.axi_slave_wr_seqr  = axi_slave_agt.axi4_slave_write_seqr_h;
  vseqr.axi_slave_rd_seqr  = axi_slave_agt.axi4_slave_read_seqr_h;

  act_agt.a_mon_h.a_mon_port.connect(cpu_sub.analysis_export);
  pas_agt.cpu_pass_mon.passive_mon_port.connect(cpu_sub.sub_pass_mon_port);

endfunction


