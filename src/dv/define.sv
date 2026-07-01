`ifndef AXI_DEFINES_SV
`define AXI_DEFINES_SV

// AXI Bus Widths
`define AXI_ID_WIDTH      4
`define AXI_ADDR_WIDTH    32
`define AXI_DATA_WIDTH    64

// AXI Control Widths
`define AXI_LEN_WIDTH     4
`define AXI_SIZE_WIDTH    3
`define AXI_BURST_WIDTH   2
`define AXI_LOCK_WIDTH    2
`define AXI_CACHE_WIDTH   2
`define AXI_PROT_WIDTH    3
`define AXI_QOS_WIDTH     4
`define AXI_REGION_WIDTH  4
`define AXI_USER_WIDTH    4
`define AXI_RESP_WIDTH    2
`define AXI_STRB_WIDTH    (`AXI_DATA_WIDTH/8)

`endif
