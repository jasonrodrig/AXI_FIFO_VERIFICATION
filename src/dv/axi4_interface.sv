`include "axi_defines.sv"

interface axi4_if(input logic aclk,
                  input logic aresetn);

  // Write Address Channel
  logic [`id_wid-1:0]      awid;
  logic [`adr_wid-1:0]     awaddr;
  logic [`len_wid-1:0]     awlen;
  logic [`siz_wid-1:0]     awsize;
  logic [`bst_wid-1:0]     awburst;
  logic [`loc_wid-1:0]     awlock;
  logic [`cach_wid-1:0]    awcache;
  logic [`prot_wid-1:0]    awprot;
  logic [`qos_wid-1:0]     awqos;
  logic [`region_wid-1:0]  awregion;
  logic [`user_wid-1:0]    awuser;
  logic                    awvalid;
  logic                    awready;

  // Write Data Channel
  logic [`data_wid-1:0]    wdata;
  logic [`strb_wid-1:0]    wstrb;
  logic                    wlast;
  logic [`user_wid-1:0]    wuser;
  logic                    wvalid;
  logic                    wready;

  // Write Response Channel
  logic [`id_wid-1:0]      bid;
  logic [`rsp_wid-1:0]     bresp;
  logic [`user_wid-1:0]    buser;
  logic                    bvalid;
  logic                    bready;

  // Read Address Channel
  logic [`id_wid-1:0]      arid;
  logic [`adr_wid-1:0]     araddr;
  logic [`len_wid-1:0]     arlen;
  logic [`siz_wid-1:0]     arsize;
  logic [`bst_wid-1:0]     arburst;
  logic [`loc_wid-1:0]     arlock;
  logic [`cach_wid-1:0]    arcache;
  logic [`prot_wid-1:0]    arprot;
  logic [`qos_wid-1:0]     arqos;
  logic [`region_wid-1:0]  arregion;
  logic [`user_wid-1:0]    aruser;
  logic                    arvalid;
  logic                    arready;

  // Read Data Channel
  logic [`id_wid-1:0]      rid;
  logic [`data_wid-1:0]    rdata;
  logic [`rsp_wid-1:0]     rresp;
  logic                    rlast;
  logic [`user_wid-1:0]    ruser;
  logic                    rvalid;
  logic                    rready;

endinterface
