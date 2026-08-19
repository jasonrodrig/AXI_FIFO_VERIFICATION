class fixed_byte2_len1_sequence extends cpu_base_sequence;

  `uvm_object_utils(fixed_byte2_len1_sequence)
 
  extern function new(string name = "fixed_byte2_len1_sequence");
  extern task body();

endclass


function fixed_byte2_len1_sequence::new(string name = "fixed_byte2_len1_sequence");
    super.new(name);
endfunction

task fixed_byte2_len1_sequence::body();
  send_transaction(1,0,AW_CH,ID_0,BURST_LEN1,BYTE2,FIXED,NORMAL_ACCESS,BUFFERABLE,NORMAL_SECURE_DATA,4'b1111);
  send_transaction(1,0,AR_CH,ID_0,BURST_LEN1,BYTE2,FIXED,NORMAL_ACCESS,BUFFERABLE,NORMAL_SECURE_DATA,4'b0000);
endtask
