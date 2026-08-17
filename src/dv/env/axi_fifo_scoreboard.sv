`uvm_analysis_imp_decl(_act_imp_scb)
`uvm_analysis_imp_decl(_pas_imp_scb)
`uvm_analysis_imp_decl(_slave_write_data)
`uvm_analysis_imp_decl(_slave_read_data)
`uvm_analysis_imp_decl(_slave_write_address)
`uvm_analysis_imp_decl(_slave_read_address)
`uvm_analysis_imp_decl(_slave_write_response)

//==============================================================
// Scoreboard
//==============================================================

class axi_fifo_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi_fifo_scoreboard)

  //------------------------------------------------------------
  // Analysis Ports
  //------------------------------------------------------------

  uvm_analysis_imp_act_imp_scb#(cpu_sequence_item, axi_fifo_scoreboard) act_scb_port;
  uvm_analysis_imp_pas_imp_scb#(cpu_sequence_item, axi_fifo_scoreboard) pas_scb_port;
  uvm_analysis_imp_slave_write_address#(axi4_slave_tx,axi_fifo_scoreboard) axi_slave_write_address_port;
  uvm_analysis_imp_slave_write_data#(axi4_slave_tx,axi_fifo_scoreboard) axi_slave_write_data_port;
  uvm_analysis_imp_slave_write_response#(axi4_slave_tx,axi_fifo_scoreboard) axi_slave_write_response_port;
  uvm_analysis_imp_slave_read_address#(axi4_slave_tx,axi_fifo_scoreboard) axi_slave_read_address_port;
  uvm_analysis_imp_slave_read_data#(axi4_slave_tx,axi_fifo_scoreboard) axi_slave_read_data_port;

  //------------------------------------------------------------
  // FIFO Model
  //------------------------------------------------------------

  bit [127:0] write_fifo[$];
  bit [127:0] read_fifo[$];

  //------------------------------------------------------------
  // One Complete Packet
  //------------------------------------------------------------

  bit [87:0] aw_w_signals[$];
  bit [51:0] ar_signals[$];
  bit [7:0]  b_signals[$];
  bit [15:0] r_signals[$];

  //------------------------------------------------------------
  // Packet Queue
  //------------------------------------------------------------

  cpu_sequence_item act_pkt_q[$] , pas_pkt_q[$] ;
  cpu_sequence_item temp_in[$] , temp_out[$];
  cpu_sequence_item word_in , word_out;

  axi4_slave_tx write_address_q[$];
  axi4_slave_tx write_data_q[$];
  axi4_slave_tx write_resp_q[$];
  axi4_slave_tx read_address_q[$];
  axi4_slave_tx read_data_q[$];

  axi4_slave_tx aw_channel_seq;
  axi4_slave_tx wr_addr_seq; 
  axi4_slave_tx wr_data_seq;
  axi4_slave_tx wr_resp_seq;
  axi4_slave_tx rd_addr_seq; 
  axi4_slave_tx rd_data_seq;
  
  //------------------------------------------------------------
  // Reference Memory
  //------------------------------------------------------------

  typedef struct {
    bit [3:0]  awid;
    bit [31:0] addr;
    bit [31:0] data;
    bit [3:0]  strb;
    bit        last;
    int        beat; 
  } expected_w;

  expected_w expected_write_q[$];
  expected_w extract_w_struct;

  bit [31:0] ref_mem[bit[31:0]];  
  bit [31:0] vip_mem[bit[31:0]];

  bit [3:0]  aw_w_id[bit[3:0]];
  bit [31:0] awaddr [bit[3:0]];
  bit [3:0]  awlen  [bit[3:0]];
  bit [2:0]  awsize [bit[3:0]];
  bit [1:0]  awburst[bit[3:0]];
  bit [1:0]  awlock [bit[3:0]];
  bit [1:0]  awcache[bit[3:0]];
  bit [2:0]  awprot [bit[3:0]];

  bit [3:0]  ar_id  [bit[3:0]];
  bit [31:0] araddr [bit[3:0]];
  bit [3:0]  arlen  [bit[3:0]];
  bit [2:0]  arsize [bit[3:0]];
  bit [1:0]  arburst[bit[3:0]];
  bit [1:0]  arlock [bit[3:0]];
  bit [1:0]  arcache[bit[3:0]];
  bit [2:0]  arprot [bit[3:0]];

  bit [3:0]  bid    [bit[3:0]];
  bit [3:0]  bresp  [bit[3:0]];
  bit [3:0]  rid    [bit[3:0]][bit[3:0]];
  bit [3:0]  rresp  [bit[3:0]][bit[3:0]];

  event aw_captured;

  //------------------------------------------------------------
  // Statistics
  //------------------------------------------------------------

  int total_packets;
  int pass_count;
  int fail_count;

  //------------------------------------------------------------
  // Methods
  //------------------------------------------------------------

  extern function new(string name = "axi_fifo_scoreboard",uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

  //------------------------------------------------------------
  // Analysis Write Functions
  //------------------------------------------------------------

  extern function void write_act_imp_scb(cpu_sequence_item pkt);
  extern function void write_pas_imp_scb(cpu_sequence_item pkt);
  extern function void write_slave_write_address(axi4_slave_tx wr_addr_seq);
  extern function void write_slave_write_data(axi4_slave_tx wr_data_seq);
  extern function void write_slave_write_response(axi4_slave_tx wr_resp_seq);
  extern function void write_slave_read_address(axi4_slave_tx rd_addr_seq);
  extern function void write_slave_read_data(axi4_slave_tx rd_data_seq);

  //------------------------------------------------------------
  // Internal Function and Tasks
  //------------------------------------------------------------
  extern function bit [31:0] calculate_burst_addr( input bit [31:0] start_addr , input bit [3:0] len, input bit [2:0] size , input bit [1:0] burst , input int beat );
  extern task collect_packet();
  extern task decode_packet();
  extern task compare_write_address_channel();
  extern task compare_write_data_channel();
  extern task store_write_response_from_axi_slave();  
  extern task compare_write_response_channel( bit [3:0] b_id , bit [3:0] bresp );
  extern task compare_read_address_channel();  
  extern task store_read_data_and_response_from_axi_slave();  
  extern task compare_read_data_channel( bit [3:0] actual_r_id , bit [3:0] actual_rresp , bit [7:0] actual_rdata );

endclass

//==============================================================
// Constructor
//==============================================================

function axi_fifo_scoreboard::new(string name="axi_fifo_scoreboard", uvm_component parent);
  super.new(name,parent);
endfunction

//==============================================================
// Build Phase
//==============================================================

function void axi_fifo_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
  act_scb_port = new("act_scb_port",this);
  pas_scb_port = new("pas_scb_port",this);
  axi_slave_write_address_port = new("axi_slave_write_address_port",this);
  axi_slave_write_data_port = new("axi_slave_write_data_port",this);
  axi_slave_write_response_port = new("axi_slave_write_response_port",this);
  axi_slave_read_address_port= new("axi_slave_read_address_port",this);
  axi_slave_read_data_port= new("axi_slave_read_data_port",this);
endfunction

//==============================================================
// Active Monitor
//==============================================================

function void axi_fifo_scoreboard::write_act_imp_scb(cpu_sequence_item pkt);

  if( pkt.wr_data != 0 ) begin
    temp_in.push_back(pkt);
    write_fifo.push_back(pkt.wr_data);
    act_pkt_q.push_back(pkt);
  end

endfunction

//==============================================================
// Passive Monitor
//==============================================================

function void axi_fifo_scoreboard::write_pas_imp_scb(cpu_sequence_item pkt);

  if( pkt.rd_en == 1 && pkt.empty == 0 ) begin
    temp_out.push_back(pkt);
    read_fifo.push_back(pkt.rd_data);
    pas_pkt_q.push_back(pkt);
  end

endfunction

function void axi_fifo_scoreboard::write_slave_write_address(axi4_slave_tx wr_addr_seq);
  write_address_q.push_back(wr_addr_seq);
endfunction  

function void axi_fifo_scoreboard::write_slave_write_data(axi4_slave_tx wr_data_seq);
  write_data_q.push_back(wr_data_seq);
endfunction

function void axi_fifo_scoreboard::write_slave_write_response(axi4_slave_tx wr_resp_seq);
  write_resp_q.push_back(wr_resp_seq);
endfunction 

function void axi_fifo_scoreboard::write_slave_read_address(axi4_slave_tx rd_addr_seq);
  read_address_q.push_back(rd_addr_seq);
endfunction

function void axi_fifo_scoreboard::write_slave_read_data(axi4_slave_tx rd_data_seq);
  read_data_q.push_back(rd_data_seq);
endfunction

//==============================================================
// Run Phase
//==============================================================

task axi_fifo_scoreboard::run_phase(uvm_phase phase);
  cpu_sequence_item tx, rx ;

  forever
  begin

    fork
      begin
        wait(temp_in.size() > 0);
        tx = temp_in.pop_front();
      end
      begin
        wait(temp_out.size() > 0);
        rx = temp_out.pop_front();
      end
    join_any

    //-------------------------------------------------------
    // Wait until one complete packet is collected
    //-------------------------------------------------------

    collect_packet();

    //-------------------------------------------------------
    // Decode packet
    //-------------------------------------------------------

    decode_packet();

    //-------------------------------------------------------
    // Compare with DUT Output
    //-------------------------------------------------------
    if( tx.wr_data[63:56] != 0 ) 
    begin
      fork 
        compare_write_address_channel();
        compare_write_data_channel();
      join
      store_write_response_from_axi_slave();  
    end

    else if(tx.wr_data[63:56] == 0)
    begin
      compare_read_address_channel();
      store_read_data_and_response_from_axi_slave();  
    end

  end

endtask

//==============================================================
// Collect Complete Packet
//==============================================================

task axi_fifo_scoreboard::collect_packet();

  fork 

    begin

      wait(act_pkt_q.size() > 0);
      word_in = act_pkt_q.pop_front();

      if( word_in.wr_data[63:56] != 'b0 && word_in.wr_data[127:64] != 'b0 && word_in.wr_data[31:24] != 'b0) begin
        if( !(word_in.wr_data[127:120] == 8'hAA && word_in.wr_data[31:24] == 8'h53 ))  `uvm_error(get_type_name(), $sformatf(" Invalid SOP = %02h | Invalid EOP = %02h ", word_in.wr_data[127:120] , word_in.wr_data[31:24] ) );
        aw_w_signals.push_back(word_in.wr_data[119:32]);
      end

      else if( word_in.wr_data[63:56] == 'b0 && word_in.wr_data[127:64] != 'b0 && word_in.wr_data[55:48] != 'b0) begin
        if( !(word_in.wr_data[127:120] == 8'hAA && word_in.wr_data[55:48] == 8'h53 ) ) `uvm_error(get_type_name(), $sformatf(" Invalid SOP = %02h | Invalid EOP = %02h ", word_in.wr_data[127:120] , word_in.wr_data[31:24] ) );
        ar_signals.push_back(word_in.wr_data[119:68]);
      end

      else `uvm_error(get_type_name(),"invlaid write packet extracted from write fifo")

    end

    begin

      wait(pas_pkt_q.size() > 0);
      word_out = pas_pkt_q.pop_front();

      if( word_out.rd_data[103:0] == 'b0 && word_out.rd_data[127:104] != 'b0 ) begin   
        if( !(word_out.rd_data[127:120] == 8'hAA && word_out.rd_data[111:104] == 8'h53 ) ) `uvm_error(get_type_name(), $sformatf(" Invalid SOP = %02h | Invalid EOP = %02h ", word_out.rd_data[127:120] , word_out.rd_data[111:104] ) );
        b_signals.push_back(word_out.rd_data[119:112]);
      end
      
      else if( word_out.rd_data[103:96] != 'b0 && word_out.rd_data[127:104] != 'b0 && word_out.rd_data[95:0] != 'b0 ) begin
        if( !(word_out.rd_data[127:120] == 8'hAA && word_out.rd_data[103:96] == 8'h53 )) `uvm_error(get_type_name(), $sformatf(" Invalid SOP = %02h | Invalid EOP = %02h ", word_out.rd_data[127:120] , word_out.rd_data[103:96] ) );
        r_signals.push_back(word_out.rd_data[119:104]);
      end 

      else `uvm_error(get_type_name(),"invlaid read packet extracted from read fifo")

    end

  join_any

  total_packets++;

endtask


//==============================================================
// Decode Packet
//==============================================================

task axi_fifo_scoreboard::decode_packet();
  expected_w exp_w;
  int num_beats;

  bit [ 3:0] id;
  bit [87:0] aw_w_signals_temp;
  bit [51:0] ar_signals_temp;
  bit [ 7:0] b_signals_temp;
  bit [15:0] r_signals_temp;

  bit [31:0] bytes_per_beat;
  bit [31:0] burst_addr;
  bit [31:0] mem_word;

  bit [3:0] b_id;
  bit [3:0] bresp;

  bit [3:0] r_id;
  bit [3:0] rresp;
  bit [7:0] rdata;
  
  if(aw_w_signals.size() > 0) begin
    aw_w_signals_temp = aw_w_signals.pop_front(); 
    id          = aw_w_signals_temp[87:84];      
    aw_w_id[id] = aw_w_signals_temp[87:84];      
    awaddr[id]  = aw_w_signals_temp[83:52];
    awlen[id]   = aw_w_signals_temp[51:48];
    awsize[id]  = aw_w_signals_temp[47:45];
    awburst[id] = aw_w_signals_temp[44:43];
    awlock[id]  = aw_w_signals_temp[42:41];
    awcache[id] = aw_w_signals_temp[40:39];
    awprot[id]  = aw_w_signals_temp[38:36];

    `uvm_info(get_type_name() ," ",UVM_NONE)
    `uvm_info(get_type_name() ,"==============================================================",UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("%-7s | %-20s","FIELD", "VALUE"), UVM_NONE)
    `uvm_info(get_type_name(), "--------------------------------------------------------------",UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("AW_ID   = %0d (0x%0h)", id, id), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("AWADDR  = 0x%08h", awaddr[id]), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("AWLEN   = %0d (0x%0h)", awlen[id], awlen[id]), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("AWSIZE  = %0d (0x%0h)", awsize[id], awsize[id]), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("AWBURST = %0d (0x%0h)", awburst[id], awburst[id]), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("AWLOCK  = %0d (0x%0h)", awlock[id], awlock[id]), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("AWCACHE = %0d (0x%0h)", awcache[id], awcache[id]), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("AWPROT  = %0d (0x%0h)", awprot[id], awprot[id]), UVM_NONE)
    `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
    `uvm_info(get_type_name() ," ",UVM_NONE)

    //------------------------------------------------------
    // Generate expected W beats
    //------------------------------------------------------

    num_beats = aw_w_signals_temp[51:48] + 1;
    bytes_per_beat = 1 << aw_w_signals_temp[47:45];

    for( int beat = 0; beat < num_beats ; beat++) 
    begin

      burst_addr = calculate_burst_addr(  aw_w_signals_temp[83:52] , aw_w_signals_temp[51:48] ,  aw_w_signals_temp[47:45] , aw_w_signals_temp[44:43] , beat );

      //--------------------------------------------------
      // Build expected W transaction
      //--------------------------------------------------

      exp_w.addr = burst_addr;
      exp_w.awid = aw_w_signals_temp[87:84];
      exp_w.data = aw_w_signals_temp[31:0 ] ;
      exp_w.strb = aw_w_signals_temp[35:32];
      exp_w.beat = beat;
      exp_w.last = (beat == num_beats-1);
      expected_write_q.push_back(exp_w);

      `uvm_info( get_type_name(), $sformatf( "EXPECTED W : BEAT=%0d ID=%0h ADDR=%08h DATA=%08h STRB=%0h LAST=%0b" , beat , exp_w.awid , exp_w.addr ,  exp_w.data , exp_w.strb , exp_w.last ) , UVM_NONE )

      //======================================================
      // Check WSTRB against AWSIZE
      //======================================================

      if ($countones(exp_w.strb) != bytes_per_beat) 
        `uvm_warning( get_type_name(), $sformatf("WSTRB/AWSIZE mismatch : AWSIZE=%0d expects %0d bytes , but WSTRB=0x%0h has %0d active lanes" , awsize[id] , bytes_per_beat , exp_w.strb , $countones(exp_w.strb) ) )

      //--------------------------------------------------
      // Update reference memory
      //--------------------------------------------------

      for (int byte_lane = 0; byte_lane < bytes_per_beat; byte_lane++) begin
        if (exp_w.strb[byte_lane])  ref_mem[ burst_addr + byte_lane ] = exp_w.data[ ( byte_lane * 8 ) +: 8 ];
        else                        ref_mem[ burst_addr + byte_lane ] = 'b0;
      end

      `uvm_info(get_type_name() ," ",UVM_NONE)
      `uvm_info(get_type_name(), "==============================================================",UVM_NONE)
      `uvm_info(get_type_name(), "                  REFERENCE MEMORY                            ",UVM_NONE)
      `uvm_info(get_type_name(), "==============================================================",UVM_NONE)
      `uvm_info(get_type_name(), $sformatf("%-8s | %-12s | %-12s | %-8s", "LANE", "ADDRESS", "DATA", "WSTRB"), UVM_NONE)
      `uvm_info(get_type_name(), "--------------------------------------------------------------",UVM_NONE)

      for (int byte_lane = 0; byte_lane < bytes_per_beat ; byte_lane++) begin
        if (exp_w.strb[byte_lane]) begin
          `uvm_info(get_type_name(), $sformatf("%-8d | 0x%08h   | 0x%02h         | %0d", byte_lane, burst_addr + byte_lane,ref_mem[burst_addr + byte_lane],exp_w.strb[byte_lane]),UVM_NONE)
        end
        else begin
          `uvm_info(get_type_name(),$sformatf("%-8d | 0x%08h   | %-12s | %0d",  byte_lane , burst_addr + byte_lane ,"NOT WRITTEN" , exp_w.strb[byte_lane]) , UVM_NONE)
        end
      end
      `uvm_info(get_type_name(),"==============================================================",UVM_NONE)
      `uvm_info(get_type_name() ," ",UVM_NONE)

    end

  end

  else if(ar_signals.size() > 0) begin
    ar_signals_temp = ar_signals.pop_front();
    id          = ar_signals_temp[51:48];
    ar_id[id]   = ar_signals_temp[51:48];      
    araddr[id]  = ar_signals_temp[47:16];
    arlen[id]   = ar_signals_temp[15:12];
    arsize[id]  = ar_signals_temp[11:9];
    arburst[id] = ar_signals_temp[8:7];
    arlock[id]  = ar_signals_temp[6:5];
    arcache[id] = ar_signals_temp[4:3];
    arprot[id]  = ar_signals_temp[2:0];

    `uvm_info(get_type_name() ," ",UVM_NONE)
    `uvm_info(get_type_name() ,"==============================================================",UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("%-7s | %-20s","FIELD", "VALUE"), UVM_NONE)
    `uvm_info(get_type_name(), "--------------------------------------------------------------",UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("AR_ID   = %0d (0x%0h)", id, id), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("ARADDR  = 0x%08h", araddr[id]), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("ARLEN   = %0d (0x%0h)", arlen[id], arlen[id]), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("ARSIZE  = %0d (0x%0h)", arsize[id], arsize[id]), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("ARBURST = %0d (0x%0h)", arburst[id], arburst[id]), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("ARLOCK  = %0d (0x%0h)", arlock[id], arlock[id]), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("ARCACHE = %0d (0x%0h)", arcache[id], arcache[id]), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("ARPROT  = %0d (0x%0h)", arprot[id], arprot[id]), UVM_NONE)
    `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
    `uvm_info(get_type_name() ," ",UVM_NONE)
  end

  else if(b_signals.size() > 0) begin
    b_signals_temp = b_signals.pop_front();
    b_id           = b_signals_temp[7:4];      
    bresp          = b_signals_temp[3:0];
    compare_write_response_channel( b_id , bresp );
  end

  else if(r_signals.size() > 0) begin
   r_signals_temp = r_signals.pop_front();
    r_id  = r_signals_temp[119:116];
    rdata = r_signals_temp[115:108];
    rresp = r_signals_temp[107:104];  
   compare_read_data_channel( r_id , rresp, rdata );
  end

endtask

function bit[31:0] axi_fifo_scoreboard::calculate_burst_addr( input bit [31:0] start_addr , input bit [3:0] len , input bit [2:0] size , input bit [1:0] burst , input int beat );
  bit [31:0] bytes_per_beat , burst_bytes , wrap_base , offset , addr;

  bytes_per_beat = 32'd1 << size; // Number of bytes in one beat

  if(burst == 2'b11) addr = start_addr; // Reserved
  else if(burst == 2'b00) addr = start_addr; // FIXED
  else if(burst == 2'b01) addr = start_addr + (beat * bytes_per_beat); // INCR
  else if(burst == 2'b10)  // WRAP
  begin
   
    burst_bytes = (len + 1) * bytes_per_beat;// Total bytes in the burst
    wrap_base = (start_addr / burst_bytes) * burst_bytes;// Wrap boundary
    offset = (start_addr - wrap_base) + (beat * bytes_per_beat); // Offset from wrap boundary
 
    // Apply wrapping
    offset = offset % burst_bytes; 
    addr = wrap_base + offset;
  end

  return addr;

endfunction

task axi_fifo_scoreboard::compare_write_address_channel();

  wait(write_address_q.size() > 0) 
  wr_addr_seq = write_address_q.pop_front(); 

  if (!$cast(aw_channel_seq, wr_addr_seq.clone())) `uvm_fatal("SCB_CLONE_CAST", "Failed to cast clone to axi4_slave_tx");  
  -> aw_captured;

  `uvm_info(get_type_name() ," ",UVM_NONE)
  `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
  `uvm_info(get_type_name(), "FIELD       | ACTUAL       | EXPECTED     | RESULT", UVM_NONE)
  `uvm_info(get_type_name(), "--------------------------------------------------------------", UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("AW_ID       | %-12d | %-12d | %s", wr_addr_seq.awid, aw_w_id[wr_addr_seq.awid], (aw_w_id[wr_addr_seq.awid] == wr_addr_seq.awid) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("AWADDR      | 0x%08h   | 0x%08h   | %s", wr_addr_seq.awaddr, awaddr[wr_addr_seq.awid], (awaddr[wr_addr_seq.awid] == wr_addr_seq.awaddr) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("AWLEN       | %-12d | %-12d | %s", wr_addr_seq.awlen, awlen[wr_addr_seq.awid], (awlen[wr_addr_seq.awid] == wr_addr_seq.awlen) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("AWSIZE      | %-12d | %-12d | %s", wr_addr_seq.awsize, awsize[wr_addr_seq.awid], (awsize[wr_addr_seq.awid] == wr_addr_seq.awsize) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("AWBURST     | %-12d | %-12d | %s", wr_addr_seq.awburst, awburst[wr_addr_seq.awid], (awburst[wr_addr_seq.awid] == wr_addr_seq.awburst) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("AWLOCK      | %-12d | %-12d | %s", wr_addr_seq.awlock, awlock[wr_addr_seq.awid], (awlock[wr_addr_seq.awid] == wr_addr_seq.awlock) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("AWCACHE     | %-12d | %-12d | %s", wr_addr_seq.awcache, awcache[wr_addr_seq.awid], (awcache[wr_addr_seq.awid] == wr_addr_seq.awcache) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("AWPROT      | %-12d | %-12d | %s", wr_addr_seq.awprot, awprot[wr_addr_seq.awid], (awprot[wr_addr_seq.awid] == wr_addr_seq.awprot) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
  `uvm_info(get_type_name() ," ",UVM_NONE)

  if (!aw_w_id.exists(wr_addr_seq.awid))                    `uvm_error(get_type_name(), $sformatf("AW_ID mismatch   : actual %0h expected %0h", wr_addr_seq.awid ,aw_w_id[wr_addr_seq.awid] ) )
  if (awaddr[wr_addr_seq.awid]   !=  wr_addr_seq.awaddr)    `uvm_error(get_type_name(), $sformatf("AWADDR mismatch  : actual %0h expected %0h", wr_addr_seq.awaddr, awaddr[wr_addr_seq.awid]))
  if (awlen[wr_addr_seq.awid]    !=  wr_addr_seq.awlen)     `uvm_error(get_type_name(), $sformatf("AWLEN mismatch   : actual %0d expected %0d", wr_addr_seq.awlen, awlen[wr_addr_seq.awid]))
  if (awsize[wr_addr_seq.awid]   !=  wr_addr_seq.awsize)    `uvm_error(get_type_name(), $sformatf("AWSIZE mismatch  : actual %0d expected %0d", wr_addr_seq.awsize, awsize[wr_addr_seq.awid]))
  if (awburst[wr_addr_seq.awid]  !=  wr_addr_seq.awburst)   `uvm_error(get_type_name(), $sformatf("AWBURST mismatch : actual %0d expected %0d", wr_addr_seq.awburst, awburst[wr_addr_seq.awid]))
  if (awlock[wr_addr_seq.awid]   !=  wr_addr_seq.awlock)    `uvm_error(get_type_name(), $sformatf("AWLOCK mismatch  : actual %0d expected %0d", wr_addr_seq.awlock, awlock[wr_addr_seq.awid]))
  if (awcache[wr_addr_seq.awid]  !=  wr_addr_seq.awcache)   `uvm_error(get_type_name(), $sformatf("AWCACHE mismatch : actual %0d expected %0d", wr_addr_seq.awcache, awcache[wr_addr_seq.awid]))
  if (awprot[wr_addr_seq.awid]   !=  wr_addr_seq.awprot)    `uvm_error(get_type_name(), $sformatf("AWPROT mismatch  : actual %0d expected %0d", wr_addr_seq.awprot, awprot[wr_addr_seq.awid]))

endtask

task axi_fifo_scoreboard::compare_write_data_channel();
  bit [31:0] burst_addr , expected_wdata , byte_addr;
  bit [7:0] expected_byte , actual_byte;

  @aw_captured;

  for (int beat = 0 ; beat < aw_channel_seq.awlen + 1 ; beat++) 
  begin

    wait(write_data_q.size() > 0 && expected_write_q.size > 0) ;
    wr_data_seq = write_data_q.pop_front();
    extract_w_struct = expected_write_q.pop_front();

    burst_addr = calculate_burst_addr(aw_channel_seq.awaddr , aw_channel_seq.awlen , aw_channel_seq.awsize , aw_channel_seq.awburst , beat );

    `uvm_info(get_type_name() ," ",UVM_NONE)
    `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
    `uvm_info(get_type_name(), "FIELD      | ACTUAL       | EXPECTED     | RESULT", UVM_NONE)
    `uvm_info(get_type_name(), "--------------------------------------------------------------", UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("W_ID       | %-12d | %-12d | %s", aw_channel_seq.awid,aw_w_id[aw_channel_seq.awid],(aw_w_id[aw_channel_seq.awid] == aw_channel_seq.awid)? "MATCH" : "MISMATCH"),UVM_NONE) 
    `uvm_info(get_type_name(), $sformatf("BEAT       | %-12d | %-12d | %s", beat , extract_w_struct.beat, (beat == extract_w_struct.beat) ? "MATCH" : "MISMATCH"), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("WSTRB      | %-12d | %-12d | %s", wr_data_seq.wstrb[0], extract_w_struct.strb, (wr_data_seq.wstrb[0] == extract_w_struct.strb) ? "MATCH" : "MISMATCH"), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("WLAST      | %-12d | %-12d | %s", wr_data_seq.wlast, extract_w_struct.last, (wr_data_seq.wlast == extract_w_struct.last) ? "MATCH" : "MISMATCH"), UVM_NONE)   
    `uvm_info(get_type_name() ," ",UVM_NONE)

    if (!aw_w_id.exists(aw_channel_seq.awid))             `uvm_error(get_type_name(), $sformatf("W_ID mismatch : actual %0h expected %0h", aw_channel_seq.awid ,aw_w_id[aw_channel_seq.awid] ) )
    if (extract_w_struct.strb != wr_data_seq.wstrb[0])    `uvm_error(get_type_name(), $sformatf("WSTRB mismatch: actual %0h expected %0h", wr_data_seq.wstrb[0], extract_w_struct.strb )) 
    if (extract_w_struct.last != wr_data_seq.wlast)       `uvm_error(get_type_name(), $sformatf("WLAST mismatch: actual %0h expected %0h", wr_data_seq.wlast, extract_w_struct.last )) 
    if (extract_w_struct.beat != beat)                    `uvm_error(get_type_name(), $sformatf("BEAT mismatch : actual %0h expected %0h", extract_w_struct.beat ,beat ) )

    `uvm_info(get_type_name(), "---------------------------------------------------------------",UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("BEAT=%0d               |   BURST_ADDR=0x%08h",beat, burst_addr),UVM_NONE)
    `uvm_info(get_type_name(), "LANE    | ADDRESS    | ACTUAL  | EXPECTED  | WSTRB | RESULT",UVM_NONE)
    `uvm_info(get_type_name(), "---------------------------------------------------------------",UVM_NONE) 

    // ======================================================
    // BYTE LANE COMPARISON
    // ======================================================

    for (int lane = 0; lane < 4; lane++)
    begin

      if (wr_data_seq.wstrb[0][lane]) 
      begin

        byte_addr = burst_addr + lane;
        actual_byte = wr_data_seq.wdata[0][lane*8 +: 8];

        // -------------------------------------------
        // Check reference memory
        // -------------------------------------------

        if (!ref_mem.exists(byte_addr)) `uvm_error(get_type_name(),$sformatf("LANE[%0d] | 0x%08h | 0x%-05h | --------- | 1     | REF_MEM MISS",lane,byte_addr,actual_byte))     
        else begin

          expected_byte = ref_mem[byte_addr];

          // ---------------------------------------
          // Compare actual vs expected byte
          // ---------------------------------------

          if (actual_byte == expected_byte) `uvm_info(get_type_name(),$sformatf("LANE[%0d] | 0x%08h | 0x%-05h | 0x%-05h   | 1     | MATCH",lane,byte_addr,actual_byte,expected_byte),UVM_NONE) 
          else                              `uvm_error(get_type_name(),$sformatf("LANE[%0d] | 0x%08h | 0x%-05h | 0x%-05h   | 1     | MISMATCH",lane,byte_addr,actual_byte,expected_byte ))

        end
      end

      // ------------------------------------------------
      // WSTRB = 0 means this byte lane is not valid. We should NOT compare its data.
      // ------------------------------------------------
      else `uvm_error(get_type_name(), $sformatf("LANE[%0d] | 0x%08h | ------- | --------- | 0     | INVALID",lane,byte_addr))

    end
  end
  `uvm_info(get_type_name(),"---------------------------------------------------------------",UVM_NONE)
  `uvm_info(get_type_name() ," ",UVM_NONE)

endtask

task axi_fifo_scoreboard::store_write_response_from_axi_slave();  
  int id;

  wait(write_resp_q.size() > 0);
  wr_resp_seq = write_resp_q.pop_front();
  bid[id]    = wr_resp_seq.bid;      
  bresp[id]   = wr_resp_seq.bresp;

  `uvm_info(get_type_name() ," ",UVM_NONE)
  `uvm_info(get_type_name() ,"==============================================================",UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("%-7s | %-20s","FIELD", "VALUE"), UVM_NONE)
  `uvm_info(get_type_name(), "--------------------------------------------------------------",UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("B_ID    = %0d (0x%0h)", id, id), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("BRESP   = %0d (0x%0h)", bresp[id],bresp[id]), UVM_NONE)
  `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
  `uvm_info(get_type_name() ," ",UVM_NONE)

endtask

task axi_fifo_scoreboard::compare_write_response_channel( bit [3:0] b_id , bit [3:0] bresp );

  `uvm_info(get_type_name() ," ",UVM_NONE)
  `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
  `uvm_info(get_type_name(), "FIELD      | ACTUAL       | EXPECTED     | RESULT", UVM_NONE)
  `uvm_info(get_type_name(), "--------------------------------------------------------------", UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("B_ID       | %-12d | %-12d | %s", b_id, bid[b_id], ( b_id == bid[b_id]) ? "MATCH" : "MISMATCH"), UVM_NONE) 
  `uvm_info(get_type_name(), $sformatf("B_RESP     | %-12d | %-12d | %s", bresp, bresp[b_id], ( bresp == bresp[b_id]) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
  `uvm_info(get_type_name() ," ",UVM_NONE)

  if( b_id  != bid[b_id] )     `uvm_error(get_type_name(), $sformatf("B_ID mismatch    : actual %0h expected %0h", b_id , bid[b_id] ) )
  if( bresp != bresp[b_id] )   `uvm_error(get_type_name(), $sformatf("BRESP mismatch   : actual %0h expected %0h", bresp , bresp[b_id] ) )

endtask  

task axi_fifo_scoreboard::compare_read_address_channel();

  wait(read_address_q.size() > 0) 
  rd_addr_seq = read_address_q.pop_front(); 

  `uvm_info(get_type_name() ," ",UVM_NONE)
  `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
  `uvm_info(get_type_name(), "FIELD       | ACTUAL       | EXPECTED     | RESULT", UVM_NONE)
  `uvm_info(get_type_name(), "--------------------------------------------------------------", UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("AR_ID       | %-12d | %-12d | %s", rd_addr_seq.arid, ar_id[rd_addr_seq.arid], (ar_id[rd_addr_seq.arid] == rd_addr_seq.arid) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("ARADDR      | 0x%08h   | 0x%08h   | %s", rd_addr_seq.araddr, araddr[rd_addr_seq.arid], (araddr[rd_addr_seq.arid] == rd_addr_seq.araddr) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("ARLEN       | %-12d | %-12d | %s", rd_addr_seq.arlen, arlen[rd_addr_seq.arid], (arlen[rd_addr_seq.arid] == rd_addr_seq.arlen) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("ARSIZE      | %-12d | %-12d | %s", rd_addr_seq.arsize, arsize[rd_addr_seq.arid], (arsize[rd_addr_seq.arid] == rd_addr_seq.arsize) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("ARBURST     | %-12d | %-12d | %s", rd_addr_seq.arburst, arburst[rd_addr_seq.arid], (arburst[rd_addr_seq.arid] == rd_addr_seq.arburst) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("ARLOCK      | %-12d | %-12d | %s", rd_addr_seq.arlock, arlock[rd_addr_seq.arid], (arlock[rd_addr_seq.arid] == rd_addr_seq.arlock) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("ARCACHE     | %-12d | %-12d | %s", rd_addr_seq.arcache, arcache[rd_addr_seq.arid], (arcache[rd_addr_seq.arid] == rd_addr_seq.arcache) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("ARPROT      | %-12d | %-12d | %s", rd_addr_seq.arprot, arprot[rd_addr_seq.arid], (arprot[rd_addr_seq.arid] == rd_addr_seq.arprot) ? "MATCH" : "MISMATCH"), UVM_NONE)
  `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
  `uvm_info(get_type_name() ," ",UVM_NONE)

  if (!ar_id.exists(rd_addr_seq.arid))                     `uvm_error(get_type_name(), $sformatf("AR_ID mismatch   : actual %0h expected %0h", rd_addr_seq.arid ,ar_id[rd_addr_seq.arid] ) )
  if (araddr[rd_addr_seq.arid]   !=  rd_addr_seq.araddr)   `uvm_error(get_type_name(), $sformatf("ARADDR mismatch  : actual %0h expected %0h", rd_addr_seq.araddr, araddr[rd_addr_seq.arid]))
  if (arlen[rd_addr_seq.arid]    !=  rd_addr_seq.arlen)    `uvm_error(get_type_name(), $sformatf("ARLEN mismatch   : actual %0d expected %0d", rd_addr_seq.arlen, arlen[rd_addr_seq.arid]))
  if (arsize[rd_addr_seq.arid]   !=  rd_addr_seq.arsize)   `uvm_error(get_type_name(), $sformatf("ARSIZE mismatch  : actual %0d expected %0d", rd_addr_seq.arsize, arsize[rd_addr_seq.arid]))
  if (arburst[rd_addr_seq.arid]  !=  rd_addr_seq.arburst)  `uvm_error(get_type_name(), $sformatf("ARBURST mismatch : actual %0d expected %0d", rd_addr_seq.arburst, arburst[rd_addr_seq.arid]))
  if (arlock[rd_addr_seq.arid]   !=  rd_addr_seq.arlock)   `uvm_error(get_type_name(), $sformatf("ARLOCK mismatch  : actual %0d expected %0d", rd_addr_seq.arlock, arlock[rd_addr_seq.arid]))
  if (arcache[rd_addr_seq.arid]  !=  rd_addr_seq.arcache)  `uvm_error(get_type_name(), $sformatf("ARCACHE mismatch : actual %0d expected %0d", rd_addr_seq.arcache, arcache[rd_addr_seq.arid]))
  if (arprot[rd_addr_seq.arid]   !=  rd_addr_seq.arprot)   `uvm_error(get_type_name(), $sformatf("ARPROT mismatch  : actual %0d expected %0d", rd_addr_seq.arprot, arprot[rd_addr_seq.arid]))

endtask

task axi_fifo_scoreboard::store_read_data_and_response_from_axi_slave();  

  bit [31:0] burst_addr, byte_addr;
  bit [7:0] expected_byte;

  for (int beat = 0 ; beat < rd_addr_seq.arlen + 1 ; beat++) 
  begin

    wait( read_data_q.size() > 0 )
    rd_data_seq = read_data_q.pop_front();

    rid[rd_data_seq.rid][beat] = rd_data_seq.rid;
    rresp[rd_data_seq.rid][beat] = rd_data_seq.rresp;

    burst_addr = calculate_burst_addr( rd_addr_seq.araddr , rd_addr_seq.arlen , rd_addr_seq.arsize , rd_addr_seq.arburst , beat );
    
    `uvm_info(get_type_name() ," ",UVM_NONE)
    `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
    `uvm_info(get_type_name(), "FIELD      | EXPECTED     |                                   ", UVM_NONE)
    `uvm_info(get_type_name(), "--------------------------------------------------------------", UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("R_ID       | %-12d |  ", rd_data_seq.rid ) ,UVM_NONE) 
    `uvm_info(get_type_name(), $sformatf("BEAT       | %-12d |  ", beat            ), UVM_NONE )
    `uvm_info(get_type_name(), $sformatf("RDATA      | %-12d |  ", rd_data_seq.rdata[0] ) , UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("RLAST      | %-12d |  ", rd_data_seq.rlast ) , UVM_NONE)   
    `uvm_info(get_type_name() ," ",UVM_NONE)

    `uvm_info(get_type_name(), "---------------------------------------------------------------",UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("BEAT=%0d               | BURST_ADDR=0x%08h",beat, burst_addr),UVM_NONE)
    `uvm_info(get_type_name(), "LANE    | ADDRESS    | EXPECTED  |                             ",UVM_NONE)
    `uvm_info(get_type_name(), "---------------------------------------------------------------",UVM_NONE) 

    // ======================================================
    // BYTE LANE COMPARISON
    // ======================================================

    for (int lane = 0; lane < 4; lane++)
    begin
        byte_addr = burst_addr + lane;
        expected_byte = rd_data_seq.rdata[0][lane*8 +: 8];
        vip_mem[byte_addr] = expected_byte; // storing the read data information coming from slave vip
        `uvm_info(get_type_name(),$sformatf("LANE[%0d] | 0x%08h | 0x%-05h   | ",lane,byte_addr,expected_byte),UVM_NONE) 
    end
  
  `uvm_info(get_type_name(),"---------------------------------------------------------------",UVM_NONE)
  `uvm_info(get_type_name() ," ",UVM_NONE)

  end

endtask

task axi_fifo_scoreboard::compare_read_data_channel( bit [3:0] actual_r_id , bit [3:0] actual_rresp , bit [7:0] actual_rdata );
  bit [ 31 : 0 ] burst_addr, byte_addr;
  bit [  7 : 0 ] actual_byte, expected_byte;

  for (int beat = 0 ; beat < arlen[actual_r_id] + 1 ; beat++) 
  begin

    burst_addr = calculate_burst_addr( araddr[actual_r_id] , arlen[actual_r_id] , arsize[actual_r_id] , arburst[actual_r_id] , beat );

    `uvm_info(get_type_name() ," ",UVM_NONE)
    `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
    `uvm_info(get_type_name(), "FIELD      | ACTUAL       | EXPECTED     | RESULT", UVM_NONE)
    `uvm_info(get_type_name(), "--------------------------------------------------------------", UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("R_ID       | %-12d | %-12d | %s", actual_r_id, rid[actual_r_id][beat], ( actual_r_id == rid[actual_r_id][beat]) ? "MATCH" : "MISMATCH"), UVM_NONE) 
    `uvm_info(get_type_name(), $sformatf("R_RESP     | %-12d | %-12d | %s", actual_rresp, rresp[actual_r_id][beat], ( actual_rresp == rresp[actual_r_id][beat]) ? "MATCH" : "MISMATCH"), UVM_NONE)
    `uvm_info(get_type_name(), "==============================================================", UVM_NONE)
    `uvm_info(get_type_name() ," ",UVM_NONE)

    if( actual_r_id  != rid[actual_r_id][beat] )     `uvm_error(get_type_name(), $sformatf("R_ID mismatch    : actual %0h expected %0h", actual_r_id , rid[actual_r_id][beat] ) )
    if( actual_rresp != rresp[actual_r_id][beat] )   `uvm_error(get_type_name(), $sformatf("RRESP mismatch   : actual %0h expected %0h", actual_rresp , rresp[actual_r_id][beat] ) )

    `uvm_info(get_type_name(), "---------------------------------------------------------------",UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("BEAT=%0d               |   BURST_ADDR=0x%08h",beat, burst_addr),UVM_NONE)
    `uvm_info(get_type_name(), "LANE    | ADDRESS    | ACTUAL  | EXPECTED  | RESULT",UVM_NONE)
    `uvm_info(get_type_name(), "---------------------------------------------------------------",UVM_NONE) 

    // ======================================================
    // BYTE LANE COMPARISON
    // ======================================================

    for (int lane = 0; lane < 4; lane++)
    begin

      byte_addr = burst_addr + lane;
      actual_byte = actual_rdata[lane*8 +: 8];

      // Check reference memory
      if (!vip_mem.exists(byte_addr)) `uvm_error(get_type_name(),$sformatf("LANE[%0d] | 0x%08h | 0x%-05h | --------- | REF_MEM MISS",lane,byte_addr,actual_byte))     
      else begin
        expected_byte = vip_mem[byte_addr];

        // Compare actual vs expected byte
        if (actual_byte == expected_byte) `uvm_info(get_type_name(),$sformatf("LANE[%0d] | 0x%08h | 0x%-05h | 0x%-05h   | MATCH",lane,byte_addr,actual_byte,expected_byte),UVM_NONE) 
        else                              `uvm_error(get_type_name(),$sformatf("LANE[%0d] | 0x%08h | 0x%-05h | 0x%-05h   | MISMATCH",lane,byte_addr,actual_byte,expected_byte ))

      end
    end

    `uvm_info(get_type_name(),"---------------------------------------------------------------",UVM_NONE)
    `uvm_info(get_type_name() ," ",UVM_NONE)

  end  

endtask

//==============================================================
// Report Phase
//==============================================================

function void axi_fifo_scoreboard::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info(get_type_name(), "=========================================", UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("Total Packets : %0d", total_packets), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("Pass Count    : %0d", pass_count), UVM_NONE)
  `uvm_info(get_type_name(), $sformatf("Fail Count    : %0d", fail_count), UVM_NONE)
  `uvm_info(get_type_name(), "=========================================", UVM_NONE)
endfunction



