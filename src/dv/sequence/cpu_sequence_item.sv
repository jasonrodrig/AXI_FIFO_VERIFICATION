typedef enum bit [3:0] {
  ID_0  = 4'd0,
  ID_1  = 4'd1,
  ID_2  = 4'd2,
  ID_3  = 4'd3,
  ID_4  = 4'd4,
  ID_5  = 4'd5,
  ID_6  = 4'd6,
  ID_7  = 4'd7,
  ID_8  = 4'd8,
  ID_9  = 4'd9,
  ID_10 = 4'd10,
  ID_11 = 4'd11,
  ID_12 = 4'd12,
  ID_13 = 4'd13,
  ID_14 = 4'd14,
  ID_15 = 4'd15
} txn_id_e;

typedef enum bit [3:0] {
  BURST_LEN1 = 4'd0,
  BURST_LEN2 = 4'd1,
  BURST_LEN3 = 4'd2,
  BURST_LEN4 = 4'd3,
  BURST_LEN5 = 4'd4,
  BURST_LEN6 = 4'd5,
  BURST_LEN7 = 4'd6,
  BURST_LEN8 = 4'd7,
  BURST_LEN9 = 4'd8,
  BURST_LEN10 = 4'd9,
  BURST_LEN11 = 4'd10,
  BURST_LEN12 = 4'd11,
  BURST_LEN13 = 4'd12,
  BURST_LEN14 = 4'd13,
  BURST_LEN15 = 4'd14,
  BURST_LEN16 = 4'd15
} len_e;

typedef enum bit [2:0] {
  BYTE1   = 3'b000,
  BYTE2   = 3'b001,
  BYTE4   = 3'b010,
  BYTE8   = 3'b011,
  BYTE16  = 3'b100,
  BYTE32  = 3'b101,
  BYTE64  = 3'b110,
  BYTE128 = 3'b111
} size_e;

typedef enum bit [1:0] {
  FIXED = 2'b00 ,
  INCR = 2'b01 ,
  WRAP = 2'b10 ,
  BURST_RESERVED = 2'b11
} burst_e;

typedef enum bit [1:0] {
  NORMAL_ACCESS    = 2'b00,
  EXCLUSIVE_ACCESS = 2'b01,
  LOCK_RESERVED1   = 2'b10,
  LOCK_RESERVED2   = 2'b11
} lock_e;

typedef enum bit [1:0] {
  BUFFERABLE       = 2'b00,
  MODIFIABLE       = 2'b01,
  OTHER_ALLOCATE   = 2'b10,
  ALLOCATE         = 2'b11
} cache_e;

typedef enum bit [2:0] {
  NORMAL_SECURE_DATA                = 3'b000,
  NORMAL_SECURE_INSTRUCTION         = 3'b001,
  NORMAL_NONSECURE_DATA             = 3'b010,
  NORMAL_NONSECURE_INSTRUCTION      = 3'b011,
  PRIVILEGED_SECURE_DATA            = 3'b100,
  PRIVILEGED_SECURE_INSTRUCTION     = 3'b101,
  PRIVILEGED_NONSECURE_DATA         = 3'b110,
  PRIVILEGED_NONSECURE_INSTRUCTION  = 3'b111
} prot_e;

typedef enum bit [1:0] {
  AW_CH        = 2'b00,
  W_CH         = 2'b01,
  AR_CH        = 2'b10,
  RESERVED_CH  = 2'b11
} channel_e;

class cpu_sequence_item extends uvm_sequence_item;

  rand bit rstn , wr_en , rd_en; 

  rand bit [31:0] addr;
  rand bit [3:0]  wstrb;
  rand bit [1023:0] wdata;

  rand channel_e ch;
  rand txn_id_e txn_id;
  rand len_e  len;
  rand size_e  size;
  rand burst_e  burst;
  rand lock_e lock;
  rand cache_e  cache;
  rand prot_e  prot;

  bit [127:0] rd_data;
  bit full , empty;

  bit [7:0] sop = 8'hAA;
  bit [7:0] eop = 8'h53;
  bit [7:0] rdata = 8'h00;

  //  FIFO Words  
  bit [127:0] fifo_word[];

  `uvm_object_utils_begin(cpu_sequence_item)
  `uvm_field_int(rstn , UVM_ALL_ON)
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
    if( ch == AW_CH )
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
    else if(ch == AR_CH)
    {
      wstrb == 4'b0000;
    }
  }

  constraint c3 { addr % ( 1 << size ) == 0; }
  constraint c4 { if( burst == WRAP ) addr % ( ( len + 1 ) * ( 1 << size ) ) == 0; }
  
endclass

function cpu_sequence_item::new(string name = "cpu_sequence_item");
  super.new(name);
endfunction

function void cpu_sequence_item::build_fifo_packet();
  if( ch == AW_CH || ch == W_CH )
  begin

    fifo_word = new[9];
    fifo_word.delete();
   
    // First FIFO word
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

  else if(ch == AR_CH)
  begin

    fifo_word = new[1];
    fifo_word.delete();
    fifo_word[0] = { sop , txn_id , addr , len , size , burst , lock , cache , prot , wstrb , rdata , eop , 48'h0 };
  
  end
endfunction


