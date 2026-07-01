
class cpu_sequence_item extends uvm_sequence_item;

  `uvm_object_utils_begin(cpu_sequence_item)

    `uvm_field_int(sop,    UVM_ALL_ON)
    `uvm_field_int(txn_id, UVM_ALL_ON)
    `uvm_field_int(addr,   UVM_ALL_ON)
    `uvm_field_int(len,    UVM_ALL_ON)
    `uvm_field_int(size,   UVM_ALL_ON)
    `uvm_field_int(burst,  UVM_ALL_ON)
    `uvm_field_int(lock,   UVM_ALL_ON)
    `uvm_field_int(cache,  UVM_ALL_ON)
    `uvm_field_int(prot,   UVM_ALL_ON)
    `uvm_field_array_int(strobe, UVM_ALL_ON)
    `uvm_field_array_int(data, UVM_ALL_ON)
    `uvm_field_int(eop, UVM_ALL_ON)

  `uvm_object_utils_end


  rand bit [7:0]  sop;
  rand bit [3:0]  txn_id;
  rand bit [31:0] addr;
  rand bit [3:0]  len;
  rand bit [2:0]  size;
  rand bit [1:0]  burst;
  rand bit [1:0]  lock;
  rand bit [1:0]  cache;
  rand bit [2:0]  prot;
  rand bit strobe[];
  rand byte unsigned data[];

  rand bit [7:0] eop;


  //------------------------------------------------------------
  // Constructor
  //------------------------------------------------------------

  function new(string name = "cpu_sequence_item");
    super.new(name);
  endfunction


  //------------------------------------------------------------
  // Constraints
  //------------------------------------------------------------

  // SOP / EOP
  constraint c_pkt {
    sop == 8'hAA;
    eop == 8'h53;
  }

  // Burst Length
  constraint c_len {
    len inside {[0:15]};
  }

  // Transfer Size
  constraint c_size {
    size inside {[0:7]};
  }

  // Burst Type
  constraint c_burst {
    burst inside {2'b00,2'b01,2'b10};
  }

  // Lock
  constraint c_lock {
    lock == 2'b00;
  }

  // Cache
  constraint c_cache {
    cache == 2'b00;
  }
  constraint c_strobe {
   strobe.size() == data.size();
} 
 
  // Address Alignment
  constraint c_addr_align {

    if(size == 3'b001)
      addr[0] == 0;

    if(size == 3'b010)
      addr[1:0] == 0;

    if(size == 3'b011)
      addr[2:0] == 0;

  }

  // Payload Size (AXI Rule)
  constraint c_data_size {
    data.size() == ((len + 1) * (1 << size));
  }

endclass

