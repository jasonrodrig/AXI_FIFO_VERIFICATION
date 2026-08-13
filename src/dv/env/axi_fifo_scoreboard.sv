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

  //------------------------------------------------------------
  // Packet Queue
  //------------------------------------------------------------

  cpu_sequence_item act_pkt_q[$] ;
  cpu_sequence_item pas_pkt_q[$] ;
  cpu_sequence_item word ,temp[$] ;

  axi4_slave_tx write_address_q[$];
  axi4_slave_tx write_data_q[$];
  axi4_slave_tx write_resp_q[$];
  axi4_slave_tx read_address_q[$];
  axi4_slave_tx read_data_q[$];
  
  
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

  bit [31:0] ref_mem[bit[31:0]];  

  bit [3:0]  aw_w_id[bit[3:0]];
  bit [31:0] awaddr [bit[3:0]];
  bit [3:0]  awlen  [bit[3:0]];
  bit [2:0]  awsize [bit[3:0]];
  bit [1:0]  awburst[bit[3:0]];
  bit [1:0]  awlock [bit[3:0]];
  bit [1:0]  awcache[bit[3:0]];
  bit [2:0]  awprot [bit[3:0]];
  bit [3:0]  wstrobe[bit[3:0]];
  bit [31:0] wdata  [bit[3:0]];

  bit [3:0]  ar_id  [bit[3:0]];
  bit [31:0] araddr [bit[3:0]];
  bit [3:0]  arlen  [bit[3:0]];
  bit [2:0]  arsize [bit[3:0]];
  bit [1:0]  arburst[bit[3:0]];
  bit [1:0]  arlock [bit[3:0]];
  bit [1:0]  arcache[bit[3:0]];
  bit [2:0]  arprot [bit[3:0]];
  // bit [3:0]  wstrobe[bit[3:0]];

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
  // Internal Tasks
  //------------------------------------------------------------
  extern function bit [31:0] calculate_burst_addr( input bit [31:0] start_addr , input bit [3:0] len, input bit [2:0] size , input bit [1:0] burst , input int beat );

  extern task collect_packet();
  extern task decode_packet();
  extern task compare_write_address_channel();
  extern task compare_write_data_channel();
  //extern task compare_write_response_channel();  
  extern task compare_read_address_channel();  
  //extern task compare_read_data_channel();
  
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
//  cpu_sequence_item pkt_copy;

//  $cast( pkt_copy,pkt.clone() );
  
  if( pkt.wr_data != 0 ) begin
    temp.push_back(pkt);
    write_fifo.push_back(pkt.wr_data);
    act_pkt_q.push_back(pkt);
  end

endfunction

//==============================================================
// Passive Monitor
//==============================================================

function void axi_fifo_scoreboard::write_pas_imp_scb(cpu_sequence_item pkt);

  if(pkt.rd_data != 0) begin
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
  cpu_sequence_item tx;

  forever
  begin

    wait(temp.size() > 0);
    tx = temp.pop_front();

    $display( " wr_data = %0h ",tx.wr_data[63:56]);
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
     // compare_write_response_channel();
     join
    end
    
    else if(tx.wr_data[63:56] == 0)
    begin
      fork
        compare_read_address_channel();  
     // compare_read_data_channel();
      join
    end
   
  end

endtask


//==============================================================
// Collect Complete Packet
//==============================================================

task axi_fifo_scoreboard::collect_packet();

  wait(act_pkt_q.size() > 0);
  word = act_pkt_q.pop_front();

  if( word.wr_data[63:56] != 0 ) begin
    if( !word.wr_data[127:120] == 8'hAA && !word.wr_data[31:24] == 8'h53 ) 
      `uvm_error(get_type_name(), $sformatf(" Invalid SOP = %02h | Invalid EOP = %02h ", word.wr_data[127:120] , word.wr_data[31:24] ) );
    aw_w_signals.push_back(word.wr_data[119:32]);
  end

  else begin
    if( !word.wr_data[127:120] == 8'hAA && !word.wr_data[55:48] == 8'h53 ) 
      `uvm_error(get_type_name(), $sformatf(" Invalid SOP = %02h | Invalid EOP = %02h ", word.wr_data[127:120] , word.wr_data[31:24] ) );
    ar_signals.push_back(word.wr_data[119:68]);
  end
  
  total_packets++;

endtask


//==============================================================
// Decode Packet
//==============================================================

task axi_fifo_scoreboard::decode_packet();
  bit [3:0] id;
  bit [87:0] aw_w_signals_temp;
  bit [51:0] ar_signals_temp;

  expected_w exp_w;

  bit [31:0] bytes_per_beat;
  bit [31:0] burst_addr;
  bit [31:0] mem_word;
  int beat;
  int num_beats;

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
    wstrobe[id] = aw_w_signals_temp[35:32];
    wdata[id]   = aw_w_signals_temp[31:0];

    $display("==============================================");
    $display("AW transaction ID = %0d (0x%0h)", id, id);
    $display("aw_w_id = 0x%0h", aw_w_id[id]);
    $display("awaddr  = 0x%08h", awaddr[id]);
    $display("awlen   = 0x%0h (%0d)", awlen[id], awlen[id]);
    $display("awsize  = 0x%0h (%0d)", awsize[id], awsize[id]);
    $display("awburst = 0x%0h (%0d)", awburst[id], awburst[id]);
    $display("awlock  = 0x%0h (%0d)", awlock[id], awlock[id]);
    $display("awcache = 0x%0h (%0d)", awcache[id], awcache[id]);
    $display("awprot  = 0x%0h (%0d)", awprot[id], awprot[id]);
    $display("wstrobe = 0x%0h", wstrobe[id]);
    $display("wdata   = 0x%08h", wdata[id]);
    $display("==============================================");

    //------------------------------------------------------
    // Generate expected W beats
    //------------------------------------------------------

    num_beats = aw_w_signals_temp[51:48] + 1;
    bytes_per_beat = 1 << aw_w_signals_temp[47:45];
    
    for( beat = 0; beat < num_beats ; beat++) 
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
      // expected_write_q.push_back(exp_w);

      `uvm_info( get_type_name(), $sformatf( "EXPECTED W : BEAT=%0d ID=%0h ADDR=%08h DATA=%08h STRB=%0h LAST=%0b" , beat , exp_w.awid , exp_w.addr ,  exp_w.data , exp_w.strb , exp_w.last ) , UVM_NONE )


      //======================================================
      // Check WSTRB against AWSIZE
      //======================================================

      if ($countones(exp_w.strb) != bytes_per_beat) begin
        `uvm_warning(
          get_type_name(),
          $sformatf(
            "WSTRB/AWSIZE mismatch : 
            AWSIZE=%0d expects %0d bytes, 
            but WSTRB=0x%0h has %0d active lanes",
            awsize[id],
            bytes_per_beat,
            exp_w.strb,
            $countones(exp_w.strb)
          )
        )
      end
     
//--------------------------------------------------
     // Update reference memory
     //--------------------------------------------------

      for (int byte_lane = 0; byte_lane < bytes_per_beat; byte_lane++) begin
        if (exp_w.strb[byte_lane]) begin
          ref_mem[ burst_addr + byte_lane ] = exp_w.data[ ( byte_lane * 8 ) +: 8 ];
          $display(
            "BYTE[%0d] : 
            ADDR = 0x%08h | 
            DATA = 0x%02h | 
            WSTRB = 1",
            byte_lane,
            burst_addr + byte_lane,
            exp_w.data[(byte_lane * 8) +: 8]

          );
        end
        else begin

          $display(
            "BYTE[%0d] : 
            ADDR = 0x%08h | 
            DATA = NOT WRITTEN | 
            WSTRB = 0",
            byte_lane,
            burst_addr + byte_lane

          );

        end
      end

      //------------------------------------------------------
      // Print memory after byte-lane operation
      //------------------------------------------------------
      
      $display("------------------------------------------------");
      $display("REFERENCE MEMORY AFTER WRITE");
      $display("BASE ADDR = 0x%08h", burst_addr);
      for (int byte_lane = 0; byte_lane < bytes_per_beat; byte_lane++) 
        $display( "MEM[0x%08h] = 0x%02h", burst_addr + byte_lane, ref_mem[burst_addr + byte_lane] );
      $display("------------------------------------------------");

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

    $display("==============================================");
    $display("AR transaction ID = %0d (0x%0h)", id, id);
    $display("ar_id   = 0x%0h", ar_id[id]);
    $display("araddr  = 0x%08h", araddr[id]);
    $display("arlen   = 0x%0h (%0d)", arlen[id], arlen[id]);
    $display("arsize  = 0x%0h (%0d)", arsize[id], arsize[id]);
    $display("arburst = 0x%0h (%0d)", arburst[id], arburst[id]);
    $display("arlock  = 0x%0h (%0d)", arlock[id], arlock[id]);
    $display("arcache = 0x%0h (%0d)", arcache[id], arcache[id]);
    $display("arprot  = 0x%0h (%0d)", arprot[id], arprot[id]);
    $display("==============================================");
  end

endtask


function bit[31:0] axi_fifo_scoreboard::calculate_burst_addr(
  input bit [31:0] start_addr,
  input bit [3:0]  len,
  input bit [2:0]  size,
  input bit [1:0]  burst,
  input int        beat
);

  bit [31:0] bytes_per_beat;
  bit [31:0] burst_bytes;
  bit [31:0] wrap_base;
  bit [31:0] offset;
  bit [31:0] addr;

  begin
    //------------------------------------------------------
    // Number of bytes in one beat
    //------------------------------------------------------

    bytes_per_beat = 32'd1 << size;

    //------------------------------------------------------
    // FIXED
    //------------------------------------------------------

    if(burst == 2'b00) begin
      addr = start_addr;
    end

    //------------------------------------------------------
    // INCR
    //------------------------------------------------------
    else if(burst == 2'b01) begin
      addr = start_addr + (beat * bytes_per_beat);
    end

    //------------------------------------------------------
    // WRAP
    //------------------------------------------------------

    else if(burst == 2'b10) begin
      //--------------------------------------------------
      // Total bytes in the burst
      //--------------------------------------------------

      burst_bytes = (len + 1) * bytes_per_beat;

      //--------------------------------------------------
      // Wrap boundary
      //--------------------------------------------------
      wrap_base = (start_addr / burst_bytes) * burst_bytes;

      //--------------------------------------------------
      // Offset from wrap boundary
      //--------------------------------------------------
      offset = (start_addr - wrap_base) + (beat * bytes_per_beat);

      //--------------------------------------------------
      // Apply wrapping
      //--------------------------------------------------
      offset = offset % burst_bytes;
      addr = wrap_base + offset;

    end

    //------------------------------------------------------
    // Reserved
    //------------------------------------------------------

    else begin
      addr = start_addr;
    end

    return addr;

  end
endfunction


task axi_fifo_scoreboard::compare_write_address_channel();
  axi4_slave_tx wr_addr_seq;

  wait(write_address_q.size() > 0) 
  wr_addr_seq = write_address_q.pop_front(); 
  
  `uvm_info( get_type_name(), " ENTERD THE WRITE ADDRESS CHANNEL " , UVM_NONE) 

  if(!aw_w_id.exists(wr_addr_seq.awid)) `uvm_error(get_type_name(), $sformatf("AW_ID mismatch : expected %0h actual %0h", wr_addr_seq.awid ,aw_w_id[wr_addr_seq.awid] ) )
  else begin
    `uvm_info(get_type_name(), $sformatf("AW_id : %d exists",wr_addr_seq.awid ) ,UVM_NONE) 

    if (awaddr[wr_addr_seq.awid] == wr_addr_seq.awaddr) `uvm_info(get_type_name(), $sformatf("AWADDR match: %0h", wr_addr_seq.awaddr), UVM_NONE)
    else                                                `uvm_error(get_type_name(), $sformatf("AWADDR mismatch: expected %0h actual %0h", wr_addr_seq.awaddr, awaddr[wr_addr_seq.awid]))

    if (awlen[wr_addr_seq.awid] == wr_addr_seq.awlen)   `uvm_info(get_type_name(), $sformatf("AWLEN match: %0d", wr_addr_seq.awlen), UVM_NONE)
    else                                                `uvm_error(get_type_name(), $sformatf("AWLEN mismatch: expected %0d actual %0d", wr_addr_seq.awlen, awlen[wr_addr_seq.awid]))

    if (awsize[wr_addr_seq.awid] == wr_addr_seq.awsize) `uvm_info(get_type_name(), $sformatf("AWSIZE match: %0d", wr_addr_seq.awsize), UVM_NONE)
    else                                                `uvm_error(get_type_name(), $sformatf("AWSIZE mismatch: expected %0d actual %0d", wr_addr_seq.awsize, awsize[wr_addr_seq.awid]))

    if (awburst[wr_addr_seq.awid] == wr_addr_seq.awburst) `uvm_info(get_type_name(), $sformatf("AWBURST match: %0d", wr_addr_seq.awburst), UVM_NONE)
    else                                                  `uvm_error(get_type_name(), $sformatf("AWBURST mismatch: expected %0d actual %0d", wr_addr_seq.awburst, awburst[wr_addr_seq.awid]))

    if (awlock[wr_addr_seq.awid] == wr_addr_seq.awlock)   `uvm_info(get_type_name(), $sformatf("AWLOCK match: %0d", wr_addr_seq.awlock), UVM_NONE)
    else                                                  `uvm_error(get_type_name(), $sformatf("AWLOCK mismatch: expected %0d actual %0d", wr_addr_seq.awlock, awlock[wr_addr_seq.awid]))

    if (awcache[wr_addr_seq.awid] == wr_addr_seq.awcache) `uvm_info(get_type_name(), $sformatf("AWCACHE match: %0d", wr_addr_seq.awcache), UVM_NONE)
    else                                                  `uvm_error(get_type_name(), $sformatf("AWCACHE mismatch: expected %0d actual %0d", wr_addr_seq.awcache, awcache[wr_addr_seq.awid]))

    if (awprot[wr_addr_seq.awid] == wr_addr_seq.awprot)   `uvm_info(get_type_name(), $sformatf("AWPROT match: %0d", wr_addr_seq.awprot), UVM_NONE)
    else                                                  `uvm_error(get_type_name(), $sformatf("AWPROT mismatch: expected %0d actual %0d", wr_addr_seq.awprot, awprot[wr_addr_seq.awid]))
  end
 
endtask

task axi_fifo_scoreboard::compare_write_data_channel();
  axi4_slave_tx wr_data_seq;

  wait(write_data_q.size() > 0) 
  wr_data_seq = write_data_q.pop_front();  

  `uvm_info( get_type_name(), " ENTERD THE WRITE DATA CHANNEL " , UVM_NONE) 

  if(!aw_w_id.exists(wr_data_seq.awid)) `uvm_error(get_type_name(), $sformatf("W_ID mismatch : expected %0h actual %0h", wr_data_seq.awid ,aw_w_id[wr_data_seq.awid] ) )
  else begin
    `uvm_info(get_type_name(), $sformatf("W_id : %d exists",wr_data_seq.awid ) ,UVM_NONE) 

  if (wstrobe[wr_data_seq.awid] == wr_data_seq.wstrb[0]) `uvm_info(get_type_name(), $sformatf("WSTRB match: %0h", wr_data_seq.wstrb[0]), UVM_NONE) 
  else                                                `uvm_error(get_type_name(), $sformatf("WSTRB mismatch: expected %0h actual %0h", wr_data_seq.wstrb[0], wstrobe[wr_data_seq.awid])) 
  
  $display("BURST_TYPE = %D" , wr_data_seq.awburst.name() );
  $display("BURST_LEN = %D"  , wr_data_seq.awlen) ;
  $display("BURST_SIZE = %D" , wr_data_seq.awsize.name() );

  end
 
endtask



task axi_fifo_scoreboard::compare_read_address_channel();
 axi4_slave_tx rd_addr_seq;

  wait(read_address_q.size() > 0) 
  rd_addr_seq = read_address_q.pop_front(); 
  
  `uvm_info( get_type_name(), " ENTERD THE READ ADDRESS CHANNEL " , UVM_NONE) 

  if(!ar_id.exists(rd_addr_seq.arid)) `uvm_error(get_type_name(), $sformatf("AR_ID mismatch : expected %0h actual %0h", rd_addr_seq.arid ,ar_id[rd_addr_seq.arid] ) )
  else begin
    `uvm_info(get_type_name(), $sformatf("ar_id : %d exists",rd_addr_seq.arid ) ,UVM_NONE) 

    if (araddr[rd_addr_seq.arid] == rd_addr_seq.araddr) `uvm_info(get_type_name(), $sformatf("ARADDR match: %0h", rd_addr_seq.araddr), UVM_NONE)
    else                                                `uvm_error(get_type_name(), $sformatf("ARADDR mismatch: expected %0h actual %0h", rd_addr_seq.araddr, araddr[rd_addr_seq.arid]))

    if (arlen[rd_addr_seq.arid] == rd_addr_seq.arlen)   `uvm_info(get_type_name(), $sformatf("ARLEN match: %0d", rd_addr_seq.arlen), UVM_NONE)
    else                                                `uvm_error(get_type_name(), $sformatf("ARLEN mismatch: expected %0d actual %0d", rd_addr_seq.arlen, arlen[rd_addr_seq.arid]))

    if (arsize[rd_addr_seq.arid] == rd_addr_seq.arsize) `uvm_info(get_type_name(), $sformatf("ARSIZE match: %0d", rd_addr_seq.arsize), UVM_NONE)
    else                                                `uvm_error(get_type_name(), $sformatf("ARSIZE mismatch: expected %0d actual %0d", rd_addr_seq.arsize, arsize[rd_addr_seq.arid]))

    if (arburst[rd_addr_seq.arid] == rd_addr_seq.arburst) `uvm_info(get_type_name(), $sformatf("ARBURST match: %0d", rd_addr_seq.arburst), UVM_NONE)
    else                                                  `uvm_error(get_type_name(), $sformatf("ARBURST mismatch: expected %0d actual %0d", rd_addr_seq.arburst, arburst[rd_addr_seq.arid]))

    if (arlock[rd_addr_seq.arid] == rd_addr_seq.arlock)   `uvm_info(get_type_name(), $sformatf("ARLOCK match: %0d", rd_addr_seq.arlock), UVM_NONE)
    else                                                  `uvm_error(get_type_name(), $sformatf("ARLOCK mismatch: expected %0d actual %0d", rd_addr_seq.arlock, arlock[rd_addr_seq.arid]))

    if (arcache[rd_addr_seq.arid] == rd_addr_seq.arcache) `uvm_info(get_type_name(), $sformatf("ARCACHE match: %0d", rd_addr_seq.arcache), UVM_NONE)
    else                                                  `uvm_error(get_type_name(), $sformatf("ARCACHE mismatch: expected %0d actual %0d", rd_addr_seq.arcache, arcache[rd_addr_seq.arid]))

    if (arprot[rd_addr_seq.arid] == rd_addr_seq.arprot)   `uvm_info(get_type_name(), $sformatf("ARPROT match: %0d", rd_addr_seq.arprot), UVM_NONE)
    else                                                  `uvm_error(get_type_name(), $sformatf("ARPROT mismatch: expected %0d actual %0d", rd_addr_seq.arprot, arprot[rd_addr_seq.arid]))
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



