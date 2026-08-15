class cpu_base_sequence extends uvm_sequence #(cpu_sequence_item);

  `uvm_object_utils(cpu_base_sequence)
  cpu_sequence_item req;

  extern function new(string name = "cpu_base_sequence");
  extern task send_transaction( 
    bit       wr_en  = 1'b0,
    bit       rd_en  = 1'b0,
    channel_e ch     = AW_CH,
    txn_id_e  txn_id = ID_0,
    len_e     len    = BURST_LEN1,
    size_e    size   = BYTE1,
    burst_e   burst  = FIXED,
    lock_e    lock   = NORMAL_ACCESS,
    cache_e   cache  = BUFFERABLE,
    prot_e    prot   = NORMAL_SECURE_DATA,
    bit [3:0] wstrb  = 4'b0000
  );
  extern task body();

endclass

function cpu_base_sequence::new(string name = "cpu_base_sequence");
  super.new(name);
endfunction

task cpu_base_sequence::send_transaction(
  bit       wr_en  = 1'b0,
  bit       rd_en  = 1'b0,
  channel_e ch     = AW_CH,
  txn_id_e  txn_id = ID_0,
  len_e     len    = BURST_LEN1,
  size_e    size   = BYTE1,
  burst_e   burst  = FIXED,
  lock_e    lock   = NORMAL_ACCESS,
  cache_e   cache  = BUFFERABLE,
  prot_e    prot   = NORMAL_SECURE_DATA,
  bit [3:0] wstrb  = 4'b0000
);

  req = cpu_sequence_item::type_id::create("req");
  
  start_item(req);

  if(!req.randomize() with {
    this.wr_en  == local::wr_en;
    this.rd_en  == local::rd_en;
    this.ch     == local::ch;
    this.txn_id == local::txn_id;
    this.len    == local::len;
    this.size   == local::size;
    this.burst  == local::burst;
    this.lock   == local::lock;
    this.cache  == local::cache;
    this.prot   == local::prot;
    this.wstrb  == local::wstrb;
  }) `uvm_fatal(get_type_name(),"Randomization Failed")

  req.build_fifo_packet();
  finish_item(req);

endtask

task cpu_base_sequence::body();

  send_transaction(1,0,AW_CH,ID_0,BURST_LEN4,BYTE4,INCR,NORMAL_ACCESS,BUFFERABLE,NORMAL_SECURE_DATA,4'b1111);
//  req.print();
  
  send_transaction(1,0,AR_CH,ID_0,BURST_LEN2,BYTE2,FIXED,NORMAL_ACCESS,BUFFERABLE,NORMAL_SECURE_DATA,4'b0000);
//  req.print();

  // ---- WRITE #2 ----
  //send_transaction(1,0,W_CH,ID_1,BURST_LEN2,BYTE2,INCR,
  //                  NORMAL_ACCESS,BUFFERABLE,NORMAL_SECURE_DATA,4'b1111);
  //req.print();

  // Pop the response for WRITE #2
  send_transaction(0,1,AR_CH,ID_1,BURST_LEN1,BYTE1,FIXED,NORMAL_ACCESS,BUFFERABLE,NORMAL_SECURE_DATA,4'b0000);
//  req.print();

endtask

