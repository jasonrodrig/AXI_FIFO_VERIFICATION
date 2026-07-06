class cpu_base_sequence extends uvm_sequence #(cpu_sequence_item);

  `uvm_object_utils(cpu_base_sequence)
  cpu_sequence_item req;

  extern function new(string name = "cpu_base_sequence");
  extern task reset();
  extern task send_transaction(
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

endclass

function cpu_base_sequence::new(string name = "cpu_base_sequence");
  super.new(name);
endfunction

task cpu_base_seqeunce::reset();
  req = cpu_sequence_item::type_id::create("req");
  start_item(req);
  if(!req.randomize() with {rstn == 0;}) 
   `uvm_fatal(get_type_name(),"Randomization Failed")
  finish_item(req);
endtask

