class cpu_active_agent extends uvm_agent;

  `uvm_component_utils(cpu_active_agent)
  cpu_driver drv_h;
  cpu_active_monitor a_mon_h;
  cpu_sequencer sqr_h;

  extern function new(string name = "cpu_active_agent", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass

function cpu_active_agent::new(string name = "cpu_active_agent", uvm_component parent );
  super.new(name, parent);
endfunction: new

function void cpu_active_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if(get_is_active == UVM_ACTIVE) begin
    drv_h = cpu_driver::type_id::create("drv_h", this);
    sqr_h = cpu_sequencer::type_id::create("sqr_h", this);
  end

  a_mon_h = cpu_active_monitor::type_id::create("a_mon_h", this);

endfunction: build_phase

function void cpu_active_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  if(get_is_active == UVM_ACTIVE)
    drv_h.seq_item_port.connect(sqr_h.seq_item_export);

endfunction: connect_phase

