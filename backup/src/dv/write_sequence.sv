class write_seq extends cpu_base_sequence;

  `uvm_object_utils(write_seq)
 
 extern function new(string name = "write_seq");
 extern task body();

endclass

function write_seq::new(string name = "write_seq");
    super.new(name);
endfunction : new

task write_seq::body(); 
  send_transaction( 1 , 0 , AW_CH , ID_0 , BURST_LEN1 , BYTE1, FIXED , NORMAL_ACCESS , BUFFERABLE, NORMAL_SECURE_DATA , 0 );

  send_transaction( 1 , 0 , W_CH , ID_0 , BURST_LEN1 , BYTE1, FIXED , NORMAL_ACCESS , BUFFERABLE, NORMAL_SECURE_DATA , 4'b1111 );

endtask : body


