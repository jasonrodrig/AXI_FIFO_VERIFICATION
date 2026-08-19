class fixed_byte1_len1_sequence extends cpu_base_sequence;

  `uvm_object_utils(fixed_byte1_len1_sequence)
 
  extern function new(string name = "fixed_byte1_len1_sequence");
  extern task body();

endclass


function fixed_byte1_len1_sequence::new(string name = "fixed_byte1_len1_sequence");
    super.new(name);
endfunction

task fixed_byte1_len1_sequence::body();
  send_transaction(1,0,AW_CH,ID_0,BURST_LEN1,BYTE1,FIXED,NORMAL_ACCESS,BUFFERABLE,NORMAL_SECURE_DATA,4'b1111);
//  $display("started");
  send_transaction(1,0,AR_CH,ID_0,BURST_LEN1,BYTE1,FIXED,NORMAL_ACCESS,BUFFERABLE,NORMAL_SECURE_DATA,4'b0000);
//  $display("ended");
  repeat(2) send_transaction(0,1,AR_CH,ID_1,BURST_LEN1,BYTE1,FIXED,NORMAL_ACCESS,BUFFERABLE,NORMAL_SECURE_DATA,4'b0000);
endtask
