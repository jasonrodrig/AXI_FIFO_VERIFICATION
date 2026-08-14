`define DW 32

class cpu_sequence_item extends uvm_sequence_item;

  rand bit wr_en , rd_en; 
  rand bit [31:0] addr;
  rand bit [3:0]  wstrb;
  rand bit [`DW - 1:0] wdata;
  rand channel_e ch;
  rand txn_id_e txn_id;
  rand len_e  len;
  rand size_e  size;
  rand burst_e  burst;
  rand lock_e lock;
  rand cache_e  cache;
  rand prot_e  prot;

  bit [127:0] rd_data;
  bit [127:0] wr_data;
  bit full , empty;

  bit [7:0] sop = 8'hAA;
  bit [7:0] eop = 8'h53;

  //  FIFO Words  
  bit [127:0] fifo_word[];
  int fifo_size; // determine the fifo size

  `uvm_object_utils_begin(cpu_sequence_item)
  `uvm_field_int(wr_en , UVM_ALL_ON)
  `uvm_field_int(rd_en  , UVM_ALL_ON)
  `uvm_field_int(wstrb , UVM_ALL_ON)
  `uvm_field_int(addr  , UVM_ALL_ON)
  `uvm_field_int(wdata  , UVM_ALL_ON)

  `uvm_field_enum(channel_e, ch,       UVM_ALL_ON)
  `uvm_field_enum(txn_id_e,  txn_id,   UVM_ALL_ON)
  `uvm_field_enum(len_e,     len,      UVM_ALL_ON)
  `uvm_field_enum(size_e,    size,     UVM_ALL_ON)
  `uvm_field_enum(burst_e,   burst,    UVM_ALL_ON)
  `uvm_field_enum(lock_e,    lock,     UVM_ALL_ON)
  `uvm_field_enum(cache_e,   cache,    UVM_ALL_ON)
  `uvm_field_enum(prot_e,    prot,     UVM_ALL_ON)

  `uvm_field_int(rd_data, UVM_ALL_ON )
  `uvm_field_int(full, UVM_ALL_ON )
  `uvm_field_int(empty, UVM_ALL_ON )
  `uvm_object_utils_end

  extern function new(string name = "cpu_sequence_item");
  extern function void build_fifo_packet();

  // NEVER RANDOMIZING THE RESERVED
  constraint c1{
    ch    != RESERVED_CH;
    lock  != LOCK_RESERVED1;
    lock  != LOCK_RESERVED2;
    burst != BURST_RESERVED;
  }

  constraint c2{
/*    if( ch == AW_CH )
    {  
      wstrb == 4'b0000;
      wdata == 1024'b0;
    }
    else if(ch == W_CH)
    { 
      addr  == 32'b0;
      wstrb != 4'b0000;
      wdata != 1024'b0;
    }
 
    else 
   */   if(ch == AR_CH)
    {
      wstrb == 4'b0000;
      wdata == 'b0;
    }
  }

  constraint c3 { addr % ( 1 << size ) == 0; }
  constraint c4 { if( burst == WRAP ) addr % ( ( len + 1 ) * ( 1 << size ) ) == 0; }
  constraint c5 { if( burst == WRAP ) len inside { BURST_LEN2 , BURST_LEN4, BURST_LEN8, BURST_LEN16 } ;}

    /* function void post_randomize(); */
    /*   if(burst == WRAP) addr = addr + 4; */
    /* endfunction */

endclass

function cpu_sequence_item::new(string name = "cpu_sequence_item");
  super.new(name);
endfunction

function void cpu_sequence_item::build_fifo_packet();
  case(`DW)
    32  : fifo_size = 1;
    64  : fifo_size = 2;
    128 : fifo_size = 2;
    256 : fifo_size = 3;
    512 : fifo_size = 5;
    1024: fifo_size = 9;
    default: fifo_size = 9;
  endcase
 
  if( ch == AW_CH || ch == W_CH )
  begin

    fifo_word.delete();
    fifo_word = new[fifo_size];
    
    if(`DW == 32) begin
    fifo_word[0] = { sop , txn_id , addr , len , size , burst , lock , cache , prot , wstrb , wdata , eop , 24'h0 };
    end
    
    else if(`DW == 64) begin
    fifo_word[0] = { sop , txn_id , addr , len , size , burst , lock , cache , prot , wstrb , wdata };
    fifo_word[1] = { eop , 120'h0 };
    end

    else if(`DW == 128) begin
    fifo_word[0] = { sop , txn_id , addr , len , size , burst , lock , cache , prot , wstrb , wdata[127:64] };
    fifo_word[1] = { wdata[63:0] , eop , 72'h0 };
    end

    else if(`DW == 256) begin
    fifo_word[0] = { sop , txn_id , addr , len , size , burst , lock , cache , prot , wstrb , wdata[255:192] };
    fifo_word[1] = { wdata[191:64] };
    fifo_word[2] = {wdata[63:0],eop,56'h0}; 
    end
 
    else if(`DW == 512) begin
    fifo_word[0] = { sop , txn_id , addr , len , size , burst , lock , cache , prot , wstrb , wdata[511:448] };
    fifo_word[1] = { wdata[447:320] };
    fifo_word[2] = { wdata[319:192] };
    fifo_word[3] = { wdata[191:64] };
    fifo_word[4] = { wdata[63:0] , eop };
    end

    // First FIFO word
    else if(`DW == 1024) begin
    fifo_word[0] = { sop , txn_id , addr , len , size , burst , lock , cache , prot , wstrb , wdata[1023:960] };

    // Remaining data
    fifo_word[1] = wdata[959:832];
    fifo_word[2] = wdata[831:704];
    fifo_word[3] = wdata[703:576];
    fifo_word[4] = wdata[575:448];
    fifo_word[5] = wdata[447:320];
    fifo_word[6] = wdata[319:192];
    fifo_word[7] = wdata[191:64];

    // Last FIFO word
    fifo_word[8] = { wdata[63:0] , eop , 56'h0 };
    end

  end

  else if(ch == AR_CH)
  begin
    fifo_word.delete();
    fifo_word = new[1];
    fifo_word[0] = { sop , txn_id , addr , len , size , burst , lock , cache , prot , wstrb , 8'h0 , eop , 48'h0 };
  end

endfunction



