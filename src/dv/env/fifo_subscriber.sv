`uvm_analysis_imp_decl(_pas_mon_cg)

class fifo_subscriber extends uvm_subscriber#(fifo_sequence_item);

  `uvm_component_utils(fifo_subscriber)
  cpu_sequence_item act_seq;
  axi_fifo_sequence_item pas_seq;

  // one analysis port is in-built used for active monitor..........
  uvm_analysis_imp_pas_mon_cg#(axi_fifo_sequence_item,fifo_subscriber) sub_pass_mon_port;
  
  real act_cov_results, pas_cov_results;
  int total_bits_read_fifo_packet;
  int total_bits_write_fifo_packet;
  bit [ 1023 : 0 ] data ;
  bit [    3 : 0 ] strb ;

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

    WRITE_DATA: coverpoint act_seq.wr_data {
      bins valid_aw_channel    = {1} 
      iff( total_bits_write_fifo_packet == 1096 && strb == 0 && data == 0 );
      
      bins valid_w_channel     = {1} 
      iff( total_bits_write_fifo_packet == 1096 && strb != 0 && data != 0 );
      
      bins valid_ar_channel    = {1} 
      iff( total_bits_write_fifo_packet ==   80 && strb != 0 && data != 0 );
      
    }

  endgroup

  covergroup pas_cov;
    
    option.per_instance = 1;

    READ_DATA: coverpoint pas_seq.rd_data{
      bins b_channel = {1} iff( total_bits_read_fifo_packet == 24 );
      bins r_channel = {1} iff( total_bits_read_fifo_packet == 1048 );
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

  extern function new(string name = "fifo_subscriber", uvm_component parent );
  extern function void write(cpu_sequence_item t);
  extern function void write_pas_mon_cg(axi_fifo_sequence_item t);
  extern virtual function void extract_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);

endclass

function fifo_subscriber::new(string name = "fifo_subscriber", uvm_component parent );
  super.new(name, parent);
  act_seq = cpu_sequence_item::type_id::create("act_sequence_item");
  pas_seq = axi_fifo_sequence_item::type_id::create("pas_sequence_item");
  act_cov = new();
  pas_cov = new();
  sub_pass_mon_port = new("subscriber_passive_monitor_port",this);
endfunction 

function void fifo_subscriber::write(fifo_sequence_item t);
  act_seq = t;

  total_bits_write_fifo_packet = $bits(act_seq.wr_data);
  if(total_bits_write_fifo_packet == 1096 )
  begin
    data = wr_data[1031:8];
    strb = wr_data[1035:1032];
  end
  else if(total_bits_write_fifo_packet == 80)
  begin
    data = wr_data[15:8];
    strb = wr_data[19:16];
  end

  act_cov.sample();
endfunction 

function void fifo_subscriber::write_pas_mon_cg(fifo_sequence_item t);
  pas_seq = t;
  total_bits_read_fifo_packet = $bits(pas_seq.rd_data);
  pas_cov.sample();
endfunction 

function void fifo_subscriber::extract_phase(uvm_phase phase);
  super.extract_phase(phase);
  act_cov_results = act_mon_cov.get_coverage();
  pas_cov_results = pas_mon_cov.get_coverage();
endfunction

function void fifo_subscriber::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info(get_type_name(), $sformatf("Input Coverage = %0.2f %%", act_cov_results ), UVM_NONE);
  `uvm_info(get_type_name(), $sformatf("Output Coverage = %0.2f %%", pas_cov_results ), UVM_NONE);
endfunction




