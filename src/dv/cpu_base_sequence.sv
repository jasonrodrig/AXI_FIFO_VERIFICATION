class cpu_base_sequence extends uvm_sequence #(cpu_sequence_item);

  `uvm_object_utils(cpu_base_sequence)
  cpu_sequence_item req;

  extern function new(string name = "cpu_base_sequence");
//  extern task reset();
  extern task send_transaction( 
    bit       wr_en  = 1'b1,
    bit       rd_en  = 1'b0,
    channel_e ch     = AW_CH,
    txn_id_e  txn_id = ID_0,
    len_e     len    = BURST_LEN1,
    size_e    size   = BYTE4,
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

/* task cpu_base_sequence::reset(); */
/*   req = cpu_sequence_item::type_id::create("req"); */
/*   start_item(req); */
/*   if(!req.randomize() with {rstn == 0;}) */ 
/*    `uvm_fatal(get_type_name(),"Randomization Failed") */
/*   finish_item(req); */
/* endtask */

task cpu_base_sequence::send_transaction(
  bit       wr_en  = 1'b1,
  bit       rd_en  = 1'b0,
  channel_e ch     = AW_CH,
  txn_id_e  txn_id = ID_0,
  len_e     len    = BURST_LEN1,
  size_e    size   = BYTE4,
  burst_e   burst  = FIXED,
  lock_e    lock   = NORMAL_ACCESS,
  cache_e   cache  = BUFFERABLE,
  prot_e    prot   = NORMAL_SECURE_DATA,
  bit [3:0] wstrb  = 4'b0000
);

  req = cpu_sequence_item::type_id::create("req");

  start_item(req);
  if(!req.randomize() with {
    this.wr_en  == wr_en;
    this.rd_en  == rd_en;
    this.ch     == ch;
    this.txn_id == txn_id;
    this.len    == len;
    this.size   == size;
    this.burst  == burst;
    this.lock   == lock;
    this.cache  == cache;
    this.prot   == prot;
    this.wstrb  == wstrb;
  }) `uvm_fatal(get_type_name(),"Randomization Failed")

  req.build_fifo_packet();
  finish_item(req);

endtask

task cpu_base_sequence::body();
  send_transaction();
endtask

