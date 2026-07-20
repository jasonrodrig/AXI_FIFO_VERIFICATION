`uvm_analysis_imp_decl(_pas_mon_cg)

class cpu_subscriber extends uvm_subscriber#(cpu_sequence_item);

  `uvm_component_utils(cpu_subscriber)
  cpu_sequence_item act_seq;
  cpu_sequence_item pas_seq;

  bit [ 127 : 0 ] read_fifo_pkt;
  bit [ 127 : 0 ] write_fifo_pkt;
  int packet_count;

  // one analysis port is in-built used for active monitor..........
  uvm_analysis_imp_pas_mon_cg#(cpu_sequence_item,cpu_subscriber) sub_pass_mon_port;
  
  real act_cov_results, pas_cov_results;

  covergroup act_cov;
    
    option.per_instance = 1;
   
    WRITE_ENABLE: coverpoint act_seq.wr_en {
      bins wr_en_active = {1};
      bins wr_en_inactive = {0};
    } 

    READ_ENABLE: coverpoint act_seq.rd_en {
      bins rd_en_active = {1};
      bins rd_en_inactive = {0};
    }

    AR_CHANNEL: coverpoint write_fifo_pkt[63:56] iff( !packet_count && write_fifo_pkt[55:0] == 56'h0 ){
      bins ar_eop = { 8'h53 }; 
    }

    AW_CHANNEL: coverpoint write_fifo_pkt[127:0] iff( packet_count > 1 && packet_count < 8 ) {
      bins no_data = { 128'b0 };
    }

    W_CHANNEL: coverpoint write_fifo_pkt[127:0] iff( packet_count > 1 && packet_count < 8 ) {
      bins data = default; 
    }

  endgroup

  covergroup pas_cov;
    
    option.per_instance = 1;

    B_CHANNEL: coverpoint read_fifo_pkt[111:104] iff( read_fifo_pkt[103:0] == 104'b0 ){ 
     bins b_eop = {8'h53};
    }

    R_CHANNEL: coverpoint read_fifo_pkt[111:104] iff( read_fifo_pkt[103:0] != 104'b0 ){ 
      bins r_eop = default;
    }

    FIFO_FULL: coverpoint pas_seq.full{
      bins full_active = {1};
      bins full_inactive = {0};
    }

    FIFO_EMPTY: coverpoint pas_seq.empty{
      bins empty_active = {1};
      bins empty_inactive = {0};
    }

  endgroup

  extern function new(string name = "cpu_subscriber", uvm_component parent );
  extern function void write(cpu_sequence_item t);
  extern function void write_pas_mon_cg(cpu_sequence_item t);
  extern virtual function void extract_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);

endclass

function cpu_subscriber::new(string name = "cpu_subscriber", uvm_component parent );
  super.new(name, parent);
  act_seq = cpu_sequence_item::type_id::create("act_sequence_item");
  pas_seq = cpu_sequence_item::type_id::create("pas_sequence_item");
  act_cov = new();
  pas_cov = new();
  sub_pass_mon_port = new("subscriber_passive_monitor_port",this);
endfunction 

function void cpu_subscriber::write(cpu_sequence_item t);
  act_seq = t;
  packet_count++;
  if( t.wr_data[63:56] == 8'h53 ) packet_count = 0;
  else if( packet_count >= 9 ) packet_count = 1;
  act_cov.sample();
endfunction 

function void cpu_subscriber::write_pas_mon_cg(cpu_sequence_item t);
  pas_seq = t;
  read_fifo_pkt = t.rd_data;
  pas_cov.sample();
endfunction 

function void cpu_subscriber::extract_phase(uvm_phase phase);
  super.extract_phase(phase);
  act_cov_results = act_cov.get_coverage();
  pas_cov_results = pas_cov.get_coverage();
endfunction

function void cpu_subscriber::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info(get_type_name(), $sformatf("Input Coverage = %0.2f %%", act_cov_results ), UVM_NONE);
  `uvm_info(get_type_name(), $sformatf("Output Coverage = %0.2f %%", pas_cov_results ), UVM_NONE);
endfunction




