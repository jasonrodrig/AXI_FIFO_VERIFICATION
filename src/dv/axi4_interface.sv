`include "axi_defines.sv"

interface axi4_if(input logic aclk,
                  input logic aresetn);

  // Write Address Channel
  logic [`AXI_ID_WIDTH-1:0]      awid;
  logic [`AXI_ADDR_WIDTH-1:0]    awaddr;
  logic [`AXI_LEN_WIDTH-1:0]     awlen;
  logic [`AXI_SIZE_WIDTH-1:0]    awsize;
  logic [`AXI_BURST_WIDTH-1:0]   awburst;
  logic [`AXI_LOCK_WIDTH-1:0]    awlock;
  logic [`AXI_CACHE_WIDTH-1:0]   awcache;
  logic [`AXI_PROT_WIDTH-1:0]    awprot;
  logic [`AXI_QOS_WIDTH-1:0]     awqos;
  logic [`AXI_REGION_WIDTH-1:0]  awregion;
  logic [`AXI_USER_WIDTH-1:0]    awuser;
  logic                          awvalid;
  logic                          awready;

  // Write Data Channel
  logic [`AXI_DATA_WIDTH-1:0]    wdata;
  logic [`AXI_STRB_WIDTH-1:0]    wstrb;
  logic                          wlast;
  logic [`AXI_USER_WIDTH-1:0]    wuser;
  logic                          wvalid;
  logic                          wready;

  // Write Response Channel
  logic [`AXI_ID_WIDTH-1:0]      bid;
  logic [`AXI_RESP_WIDTH-1:0]    bresp;
  logic [`AXI_USER_WIDTH-1:0]    buser;
  logic                          bvalid;
  logic                          bready;

  // Read Address Channel
  logic [`AXI_ID_WIDTH-1:0]      arid;
  logic [`AXI_ADDR_WIDTH-1:0]    araddr;
  logic [`AXI_LEN_WIDTH-1:0]     arlen;
  logic [`AXI_SIZE_WIDTH-1:0]    arsize;
  logic [`AXI_BURST_WIDTH-1:0]   arburst;
  logic [`AXI_LOCK_WIDTH-1:0]    arlock;
  logic [`AXI_CACHE_WIDTH-1:0]   arcache;
  logic [`AXI_PROT_WIDTH-1:0]    arprot;
  logic [`AXI_QOS_WIDTH-1:0]     arqos;
  logic [`AXI_REGION_WIDTH-1:0]  arregion;
  logic [`AXI_USER_WIDTH-1:0]    aruser;
  logic                          arvalid;
  logic                          arready;

  // Read Data Channel
  logic [`AXI_ID_WIDTH-1:0]      rid;
  logic [`AXI_DATA_WIDTH-1:0]    rdata;
  logic [`AXI_RESP_WIDTH-1:0]    rresp;
  logic                          rlast;
  logic [`AXI_USER_WIDTH-1:0]    ruser;
  logic                          rvalid;
  logic                          rready;

endinterface
