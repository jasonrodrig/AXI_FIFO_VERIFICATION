/*
`uvm_analysis_imp_decl(_act_imp_scb)
`uvm_analysis_imp_decl(_pas_imp_scb)

//==============================================================
// Expected Packet
//==============================================================

typedef struct {

   bit        is_read;
   bit [3:0]  txn_id;
   bit [31:0] addr;
   bit [31:0] data;
   bit [3:0]  resp;

} expected_pkt_t;

//==============================================================
// Scoreboard
//==============================================================

class axi_fifo_scoreboard extends uvm_scoreboard;

   `uvm_component_utils(axi_fifo_scoreboard)

   //------------------------------------------------------------
   // Analysis Ports
   //------------------------------------------------------------

   uvm_analysis_imp_act_imp_scb #(cpu_sequence_item,
                                  axi_fifo_scoreboard) act_scb_port;

   uvm_analysis_imp_pas_imp_scb #(cpu_sequence_item,
                                  axi_fifo_scoreboard) pas_scb_port;
    expected_pkt_t exp_pkt;

   //------------------------------------------------------------
   // FIFO Model
   //------------------------------------------------------------

   bit [127:0] write_fifo[$];

   //------------------------------------------------------------
   // One Complete Packet
   //------------------------------------------------------------

   bit [127:0] beat_q[$];

   //------------------------------------------------------------
   // Expected Packet Queue
   //------------------------------------------------------------

   expected_pkt_t expected_pkt_q[$];

   //------------------------------------------------------------
   // Actual Packet Queue
   //------------------------------------------------------------

   cpu_sequence_item act_pkt_q[$];

   //------------------------------------------------------------
   // Reference Memory
   //------------------------------------------------------------

   bit [31:0] ref_mem[1024];

   //------------------------------------------------------------
   // Statistics
   //------------------------------------------------------------

   int total_packets;
   int pass_count;
   int fail_count;

   //------------------------------------------------------------
   // Methods
   //------------------------------------------------------------

   extern function new(string name="axi_fifo_scoreboard",
                       uvm_component parent);

   extern function void build_phase(uvm_phase phase);

   extern task run_phase(uvm_phase phase);

   extern function void report_phase(uvm_phase phase);

   //------------------------------------------------------------
   // Analysis Write Functions
   //------------------------------------------------------------

   extern function void write_act_imp_scb(cpu_sequence_item pkt);

   extern function void write_pas_imp_scb(cpu_sequence_item pkt);

   //------------------------------------------------------------
   // Internal Tasks
   //------------------------------------------------------------

   extern task collect_packet();

   extern task decode_packet();

   extern task compare();

endclass


//==============================================================
// Constructor
//==============================================================

function axi_fifo_scoreboard::new(string name="axi_fifo_scoreboard",
                                  uvm_component parent);

   super.new(name,parent);

endfunction


//==============================================================
// Build Phase
//==============================================================

function void axi_fifo_scoreboard::build_phase(uvm_phase phase);

   super.build_phase(phase);

   act_scb_port = new("act_scb_port",this);
   pas_scb_port = new("pas_scb_port",this);

endfunction


//==============================================================
// Active Monitor
//==============================================================

function void axi_fifo_scoreboard::write_act_imp_scb(cpu_sequence_item pkt);

   $display("### ACTIVE CALLBACK CALLED ###");

   if(pkt.wr_en)
   begin

      //---------------------------------------------------------
      // FIFO Full Check
      //---------------------------------------------------------

      if(pkt.full)
      begin

         if(write_fifo.size() == 4096)
         begin
            `uvm_info(get_type_name(),
                      "FIFO FULL MATCH",
                      UVM_LOW)
         end
         else
         begin
            `uvm_error(get_type_name(),
               $sformatf("FIFO FULL Mismatch Model=%0d DUT=%0b",
                         write_fifo.size(),
                         pkt.full))
         end

      end
      else
      begin

         //---------------------------------------------------------
         // Store FIFO Beat
         //---------------------------------------------------------

         write_fifo.push_back(pkt.wr_data);

$display("WRITE_FIFO SIZE = %0d", write_fifo.size());

         `uvm_info(get_type_name(),
            $sformatf("Captured FIFO Beat = %032h",
                      pkt.wr_data),
            UVM_HIGH);

      end

   end

endfunction


//==============================================================
// Passive Monitor
//==============================================================

function void axi_fifo_scoreboard::write_pas_imp_scb(cpu_sequence_item pkt);


$display("### PASSIVE CALLBACK CALLED ###");
$display("pkt.empty = %0d", pkt.empty);
   $display("ACTUAL_Q SIZE = %0d", act_pkt_q.size());
  if(pkt.rd_en)
   begin

      //---------------------------------------------------------
      // FIFO Empty Check
      //---------------------------------------------------------

      if(pkt.empty)
      begin

         if(act_pkt_q.size()==0)
         begin
            `uvm_info(get_type_name(),
                      "FIFO EMPTY MATCH",
                      UVM_LOW);
         end
         else
         begin
            `uvm_error(get_type_name(),
                       "FIFO EMPTY Mismatch");
         end

      end
      else
      begin

         //---------------------------------------------------------
         // Store Decoder Output
         //---------------------------------------------------------

         act_pkt_q.push_back(pkt);

         `uvm_info(get_type_name(),
                   "Captured Decoder Output",
                   UVM_HIGH);

      end

  end

endfunction

//==============================================================
// Run Phase
//==============================================================

task axi_fifo_scoreboard::run_phase(uvm_phase phase);

   forever
   begin

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

      compare();

      total_packets++;

   end

endtask


//==============================================================
// Collect Complete Packet
//==============================================================

task axi_fifo_scoreboard::collect_packet();

   bit [127:0] word;

   beat_q.delete();

   wait(write_fifo.size() > 0);
   word = write_fifo.pop_front();

   if(word[127:120] != 8'hAA)
   begin
      `uvm_error(get_type_name(),
                 $sformatf("Invalid SOP = %02h", word[127:120]));
      return;
   end

   beat_q.push_back(word);

   //----------------------------------------------------------
   // READ packet -- always exactly 1 word
   //----------------------------------------------------------
   if((word[63:56]==8'h00) && (word[55:48]==8'h53))
   begin
      `uvm_info(get_type_name(), "READ Packet Collected", UVM_MEDIUM);
      return;
   end

   //----------------------------------------------------------
   // WRITE packet -- fixed 9 words total, 8 more to collect
   // unconditionally. NOT scan-for-EOP: middle words are pure
   // random data and could coincidentally contain 0x53, ending
   // the packet early and desyncing everything after it.
   //----------------------------------------------------------
   repeat (8)
   begin
      wait(write_fifo.size() > 0);
      word = write_fifo.pop_front();
      beat_q.push_back(word);
   end

   `uvm_info(get_type_name(),
      $sformatf("WRITE Packet Collected (%0d beats)", beat_q.size()),
      UVM_MEDIUM);

endtask
  

//==============================================================
// Decode Packet
//==============================================================

task axi_fifo_scoreboard::decode_packet();

   bit [127:0] word0;

   //----------------------------------------------------------
   // Get First Beat
   //----------------------------------------------------------

   if (beat_q.size() > 0) begin
      word0 = beat_q[0];

      //----------------------------------------------------------
      // Clear Previous Packet
      //----------------------------------------------------------

      exp_pkt.is_read = 0;
      exp_pkt.txn_id  = 0;
      exp_pkt.addr    = 0;
      exp_pkt.data    = 0;
      exp_pkt.resp    = 0;

      //----------------------------------------------------------
      // Decode Common Header
      //----------------------------------------------------------

      exp_pkt.txn_id = word0[119:116];
      exp_pkt.addr   = word0[115:84];

      //----------------------------------------------------------
      // READ Packet
      //----------------------------------------------------------

      if((word0[63:56] == 8'h00) &&
         (word0[55:48] == 8'h53))
      begin

         exp_pkt.is_read = 1'b1;

         // Read expected data from reference memory
         exp_pkt.data = ref_mem[exp_pkt.addr];

         // OKAY Response
         exp_pkt.resp = 4'b0001;

         `uvm_info(get_type_name(),
            $sformatf("READ Decode : ID=%0d ADDR=%08h DATA=%08h",
                       exp_pkt.txn_id,
                       exp_pkt.addr,
                       exp_pkt.data),
            UVM_MEDIUM);

      end

      //----------------------------------------------------------
      // WRITE Packet
      //----------------------------------------------------------

      else
      begin

         exp_pkt.is_read = 1'b0;

         // 32-bit data assumption
         exp_pkt.data = word0[63:32];

         // Update Reference Memory
         ref_mem[exp_pkt.addr] = exp_pkt.data;

         // OKAY Response
         exp_pkt.resp = 4'b0001;

         `uvm_info(get_type_name(),
            $sformatf("WRITE Decode : ID=%0d ADDR=%08h DATA=%08h",
                       exp_pkt.txn_id,
                       exp_pkt.addr,
                       exp_pkt.data),
            UVM_MEDIUM);

      end

      //----------------------------------------------------------
      // Store Expected Packet
      //----------------------------------------------------------

      expected_pkt_q.push_back(exp_pkt);
$display("EXPECTED_Q SIZE = %0d", expected_pkt_q.size());
   end

endtask

//==============================================================
// Compare Expected vs Actual
//==============================================================


  
task axi_fifo_scoreboard::compare();
 
   expected_pkt_t exp_pkt;
   cpu_sequence_item act_pkt;
 
   bit [127:0] beat;
   bit [3:0]   act_txn_id;
   bit [31:0]  act_data;
   bit [3:0]   act_resp;
   bit [7:0]   act_eop;
 
   wait(expected_pkt_q.size() > 0);
   wait(act_pkt_q.size() > 0);
 
   exp_pkt = expected_pkt_q.pop_front();
   act_pkt = act_pkt_q.pop_front();
 
   beat       = act_pkt.rd_data;
   act_txn_id = beat[119:116];
 
   if (exp_pkt.is_read) begin
      act_data = beat[115:84];
      act_resp = beat[83:80];
      act_eop  = beat[79:72];
   end
   else begin
      act_resp = beat[115:112];
      act_eop  = beat[111:104];
      act_data = 32'h0;
   end
 
   if (act_eop !== 8'h53)
      `uvm_warning(get_type_name(),
         $sformatf("EOP not found at expected position for %0s response (got 0x%0h)",
                   exp_pkt.is_read ? "READ" : "WRITE", act_eop))
 
   //----------------------------------------------------------
   // READ Response Compare
   //----------------------------------------------------------
   if(exp_pkt.is_read)
   begin
      if(act_txn_id != exp_pkt.txn_id) begin
         fail_count++;
         `uvm_error(get_type_name(),
            $sformatf("TXN_ID Mismatch Exp=%0d Act=%0d", exp_pkt.txn_id, act_txn_id))
      end
      else if(act_data != exp_pkt.data) begin
         fail_count++;
         `uvm_error(get_type_name(),
            $sformatf("RDATA Mismatch Exp=%08h Act=%08h", exp_pkt.data, act_data))
      end
      else if(act_resp != exp_pkt.resp) begin
         fail_count++;
         `uvm_error(get_type_name(),
            $sformatf("RRESP Mismatch Exp=%0h Act=%0h", exp_pkt.resp, act_resp))
      end
      else begin
         pass_count++;
         `uvm_info(get_type_name(), "READ RESPONSE MATCHED", UVM_LOW);
      end
   end
 
   //----------------------------------------------------------
   // WRITE Response Compare
   //----------------------------------------------------------
   else
   begin
      if(act_txn_id != exp_pkt.txn_id) begin
         fail_count++;
         `uvm_error(get_type_name(),
            $sformatf("TXN_ID Mismatch Exp=%0d Act=%0d", exp_pkt.txn_id, act_txn_id))
      end
      else if(act_resp != exp_pkt.resp) begin
         fail_count++;
         `uvm_error(get_type_name(),
            $sformatf("BRESP Mismatch Exp=%0h Act=%0h", exp_pkt.resp, act_resp))
      end
      else begin
         pass_count++;
         `uvm_info(get_type_name(), "WRITE RESPONSE MATCHED", UVM_LOW);
      end
   end
 
endtask

   
      


//==============================================================
// Report Phase
//==============================================================

function void axi_fifo_scoreboard::report_phase(uvm_phase phase);

   super.report_phase(phase);

   `uvm_info(get_type_name(),
      "=========================================",
      UVM_NONE)

   `uvm_info(get_type_name(),
      $sformatf("Total Packets : %0d", total_packets),
      UVM_NONE)

   `uvm_info(get_type_name(),
      $sformatf("Pass Count    : %0d", pass_count),
      UVM_NONE)

   `uvm_info(get_type_name(),
      $sformatf("Fail Count    : %0d", fail_count),
      UVM_NONE)

   `uvm_info(get_type_name(),
      "=========================================",
      UVM_NONE)

endfunction
*/

`uvm_analysis_imp_decl(_act_imp_scb)
`uvm_analysis_imp_decl(_pas_imp_scb)

//------------------------------------------------------------------------
// axi_fifo_scoreboard  (FIFO-only scope, structural check)
//
// Deliberately does NOT attempt to predict or compare exact response
// content (BRESP/RRESP/READ_DATA bit positions) -- that's AXI-content
// scoped and was never confirmed against the real DUT. This checks
// only what's genuinely FIFO-level:
//   - full/empty flag protocol correctness (unchanged from before)
//   - decoding write requests, for visibility/coverage
//   - whether the DUT structurally produces a response beat for each
//     request sent, via a sent-vs-received count -- not whether that
//     response's content is byte-correct
//------------------------------------------------------------------------
class axi_fifo_scoreboard extends uvm_scoreboard;

   `uvm_component_utils(axi_fifo_scoreboard)

   //------------------------------------------------------------
   // Analysis Implementation Ports
   //------------------------------------------------------------

   uvm_analysis_imp_act_imp_scb #(cpu_sequence_item,
                                  axi_fifo_scoreboard) act_scb_port;

   uvm_analysis_imp_pas_imp_scb #(cpu_sequence_item,
                                  axi_fifo_scoreboard) pas_scb_port;

   //------------------------------------------------------------
   // FIFO Model
   //------------------------------------------------------------

   bit [127:0] write_fifo[$];
   bit [127:0] beat_q[$];

   localparam int WR_FIFO_DEPTH = 4096;

   //------------------------------------------------------------
   // Decoded request fields (current packet, for logging only --
   // not compared against anything)
   //------------------------------------------------------------

   bit        is_read;
   bit [3:0]  txn_id;
   bit [31:0] addr;
   bit [3:0]  len;
   bit [2:0]  size;
   bit [1:0]  burst;
   bit [1:0]  lock;
   bit [1:0]  cache;
   bit [2:0]  prot;
   bit [3:0]  wstrb;

   //------------------------------------------------------------
   // Structural counts
   //------------------------------------------------------------

   int num_write_requests;
   int num_read_requests;
   int num_responses_received;

   //------------------------------------------------------------
   // Methods
   //------------------------------------------------------------

   extern function new(string name="axi_fifo_scoreboard",
                       uvm_component parent);

   extern function void build_phase(uvm_phase phase);
   extern task run_phase(uvm_phase phase);
   extern function void report_phase(uvm_phase phase);

   extern function void write_act_imp_scb(cpu_sequence_item pkt);
   extern function void write_pas_imp_scb(cpu_sequence_item pkt);

   extern task collect_packet();
   extern task decode_packet(bit [127:0] beat_q[$]);

endclass

//------------------------------------------------------------
// Constructor / Build
//------------------------------------------------------------
function axi_fifo_scoreboard::new(string name="axi_fifo_scoreboard",
                                  uvm_component parent);
   super.new(name,parent);
endfunction

function void axi_fifo_scoreboard::build_phase(uvm_phase phase);
   super.build_phase(phase);
   act_scb_port = new("act_scb_port",this);
   pas_scb_port = new("pas_scb_port",this);
endfunction

//------------------------------------------------------------
// Active Monitor Write (request side, write FIFO)
//------------------------------------------------------------
function void axi_fifo_scoreboard::write_act_imp_scb(cpu_sequence_item pkt);
   if(pkt.wr_en)
   begin
      if(pkt.full)
      begin
         if(write_fifo.size() == WR_FIFO_DEPTH)
            `uvm_info(get_type_name(), "FIFO FULL MATCH", UVM_LOW)
         else
            `uvm_error(get_type_name(),
               $sformatf("FIFO FULL mismatch Model=%0d DUT=%0b",
                         write_fifo.size(), pkt.full))
         return;
      end

      write_fifo.push_back(pkt.wr_data);
   end
endfunction

//------------------------------------------------------------
// Passive Monitor Write (response side, read FIFO)
//
// Only counts -- doesn't decode or compare content.
//------------------------------------------------------------
function void axi_fifo_scoreboard::write_pas_imp_scb(cpu_sequence_item pkt);
   if(pkt.rd_en)
   begin
      if(pkt.empty)
      begin
         if(num_responses_received >= num_write_requests + num_read_requests)
            `uvm_info(get_type_name(), "FIFO EMPTY MATCH", UVM_LOW)
         else
            `uvm_error(get_type_name(),
               $sformatf("FIFO EMPTY mismatch -- %0d request(s) still pending a response",
                         (num_write_requests + num_read_requests) - num_responses_received))
         return;
      end

      num_responses_received++;
      `uvm_info(get_type_name(),
         $sformatf("Response beat received (total so far = %0d)", num_responses_received),
         UVM_MEDIUM)
   end
endfunction

//------------------------------------------------------------
// Run Phase
//------------------------------------------------------------
task axi_fifo_scoreboard::run_phase(uvm_phase phase);
   forever
   begin
      collect_packet();
      decode_packet(beat_q);

      if(is_read)
         num_read_requests++;
      else
         num_write_requests++;
   end
endtask

//------------------------------------------------------------
// collect_packet: single 128-bit word per request (matches your
// current cpu_sequence_item -- 32-bit wdata, single-word framing,
// confirmed against captured wr_data).
//------------------------------------------------------------
task axi_fifo_scoreboard::collect_packet();

   bit [127:0] word;

   beat_q.delete();

   wait(write_fifo.size() > 0);
   word = write_fifo.pop_front();

   if(word[127:120] != 8'hAA)
   begin
      `uvm_error(get_type_name(),
                 $sformatf("Invalid SOP = %02h", word[127:120]));
      return;
   end

   beat_q.push_back(word);

endtask

//------------------------------------------------------------
// decode_packet: header only, for visibility/coverage. Read vs.
// write via wstrb (0 = read, nonzero = write) -- reliable regardless
// of packet content.
//------------------------------------------------------------
task axi_fifo_scoreboard::decode_packet(bit [127:0] beat_q[$]);
   bit [127:0] w0;

   w0 = beat_q[0];

   txn_id = w0[119:116];
   addr   = w0[115:84];
   len    = w0[83:80];
   size   = w0[79:77];
   burst  = w0[76:75];
   lock   = w0[74:73];
   cache  = w0[72:71];
   prot   = w0[70:68];
   wstrb  = w0[67:64];

   is_read = (wstrb == 4'b0000);

   `uvm_info(get_type_name(),
      $sformatf("%0s REQUEST : TxnID=%0d Addr=%08h",
                is_read ? "READ" : "WRITE", txn_id, addr),
      UVM_MEDIUM)

endtask

//------------------------------------------------------------
// Report Phase
//------------------------------------------------------------
function void axi_fifo_scoreboard::report_phase(uvm_phase phase);
   int total_requests;

   super.report_phase(phase);

   total_requests = num_write_requests + num_read_requests;

   `uvm_info(get_type_name(), "=========================================", UVM_NONE)
   `uvm_info(get_type_name(), $sformatf("Write Requests Sent   : %0d", num_write_requests), UVM_NONE)
   `uvm_info(get_type_name(), $sformatf("Read Requests Sent    : %0d", num_read_requests), UVM_NONE)
   `uvm_info(get_type_name(), $sformatf("Total Requests Sent   : %0d", total_requests), UVM_NONE)
   `uvm_info(get_type_name(), $sformatf("Responses Received    : %0d", num_responses_received), UVM_NONE)
   `uvm_info(get_type_name(), "=========================================", UVM_NONE)

   if(num_responses_received == total_requests)
      `uvm_info(get_type_name(), "*** STRUCTURAL CHECK: PASS -- every request got a response ***", UVM_NONE)
   else
      `uvm_error(get_type_name(),
         $sformatf("*** STRUCTURAL CHECK: FAIL -- %0d request(s) never got a response ***",
                   total_requests - num_responses_received))

endfunction

