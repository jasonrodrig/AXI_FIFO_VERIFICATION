`ifndef AXI_DEFINES_SV
`define AXI_DEFINES_SV

// Width Parameters
`define id_wid       4
`define adr_wid      32
`define data_wid     32
`define strb_wid     (`data_wid/8)
`define len_wid      4
`define siz_wid      3
`define bst_wid      2
`define loc_wid      2
`define cach_wid     4
`define prot_wid     3
`define rsp_wid      2
`define qos_wid      4
`define region_wid   4
`define user_wid     4

`endif
