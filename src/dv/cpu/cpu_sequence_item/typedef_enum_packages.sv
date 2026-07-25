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

