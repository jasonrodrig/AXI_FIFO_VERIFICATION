`uvm_analysis_imp_decl(_act_imp_scb)
`uvm_analysis_imp_decl(_pas_imp_scb)

// declaration for axi salve vip

class axi_fifo_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi_fifo_scoreboard)
  uvm_analysis_imp_act_imp_scb#(axi_fifo_sequence_item, axi_fifo_scoreboard) act_scb_port;
  uvm_analysis_imp_pas_imp_scb#(axi_fifo_sequence_item, axi_fifo_scoreboard) pas_scb_port;
  // connection for the axi_Salve avip

  axi_fifo_sequence_item act_q[$] , pas_q[$]; 
  axi_fifo_sequence_item act_seq, pas_seq ;
  // seqeunce_item handle for axi_vip_slave

  static int pass_count;
  static int fail_count;

  extern function new(string name = "axi_fifo_scoreboard", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void write_act_imp_scb(axi_fifo_sequence_item act_pkt);
  extern function void write_pas_imp_scb(axi_fifo_sequence_item pas_pkt);
  extern function void report_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task compare( );

endclass

function axi_fifo_scoreboard::new(string name = "axi_fifo_scoreboard", uvm_component parent);
  super.new(name,parent);
endfunction

function void axi_fifo_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
  act_scb_port = new("act_scb_port",this);
  pas_scb_port = new("pas_scb_port",this);
endfunction

function void axi_fifo_scoreboard::write_act_imp_scb(axi_fifo_sequence_item act_pkt);
  act_q.push_back(act_pkt);
endfunction

function void axi_fifo_scoreboard::write_pas_imp_scb(axi_fifo_sequence_item pas_pkt);
  pas_q.push_back(pas_pkt);
endfunction

// write function axi_vip_slave

function void axi_fifo_scoreboard::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info("SCOREBOARD", $sformatf("TOTAL PASS : %0d", pass_count), UVM_NONE)
  `uvm_info("SCOREBOARD", $sformatf("TOTAL FAIL : %0d", fail_count), UVM_NONE)
  `uvm_info("SCOREBOARD", $sformatf("TOTAL CASES : %0d", fail_count + pass_count), UVM_NONE)
endfunction

//need to think on run phasse logic
task axi_fifo_scoreboard::run_phase(uvm_phase phase);
  forever begin
    begin
      wait(act_q.size() > 0 && pas_q.size() > 0 );
      act_seq = act_q.pop_front();
      pas_seq = pas_q.pop_front();
      compare();
    end
  end
endtask

task axi_fifo_scoreboard::compare();

endtask


