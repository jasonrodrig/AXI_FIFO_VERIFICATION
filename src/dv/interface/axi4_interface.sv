`ifndef AXI4_IF_INCLUDED_
`define AXI4_IF_INCLUDED_

// Import axi4_globals_pkg
import axi4_globals_pkg::*;

interface axi4_if #(
  parameter int ID_WID    = `ID_WID,
  parameter int ADR_WID   = `ADR_WID,
  parameter int DATA_WID  = `DATA_WID,
  parameter int STRB_WID  = `STRB_WID,
  parameter int LEN_WID   = `LEN_WID,
  parameter int SIZ_WID   = `SIZ_WID,
  parameter int BST_WID   = `BST_WID,
  parameter int LOC_WID   = `LOC_WID,
  parameter int CACH_WID  = `CACH_WID,
  parameter int PROT_WID  = `PROT_WID,
  parameter int RSP_WID   = `RSP_WID
) ( input bit ACLK );

  //==================================================
  // Write Address Channel
  //==================================================

  logic [ID_WID-1:0]    awid;
  logic [ADR_WID-1:0]   awaddr;
  logic [LEN_WID-1:0]   awlen;
  logic [SIZ_WID-1:0]   awsize;
  logic [BST_WID-1:0]   awburst;
  logic [LOC_WID-1:0]   awlock;
  logic [CACH_WID-1:0]  awcache;
  logic [PROT_WID-1:0]  awprot;
  logic [3:0]           awqos;
  logic [3:0]           awregion;
  logic                 awuser;
  logic                 awvalid;
  logic                 awready;

  //==================================================
  // Write Data Channel
  //==================================================

  logic [DATA_WID-1:0]  wdata;
  logic [STRB_WID-1:0]  wstrb;
  logic                 wlast;
  logic [3:0]           wuser;
  logic                 wvalid;
  logic                 wready;

  //==================================================
  // Write Response Channel
  //==================================================

  logic [ID_WID-1:0]    bid;
  logic [RSP_WID-1:0]   bresp;
  logic [3:0]           buser;
  logic                 bvalid;
  logic                 bready;

  //==================================================
  // Read Address Channel
  //==================================================

  logic [ID_WID-1:0]    arid;
  logic [ADR_WID-1:0]   araddr;
  logic [LEN_WID-1:0]   arlen;
  logic [SIZ_WID-1:0]   arsize;
  logic [BST_WID-1:0]   arburst;
  logic [LOC_WID-1:0]   arlock;
  logic [CACH_WID-1:0]  arcache;
  logic [PROT_WID-1:0]  arprot;
  logic [3:0]           arqos;
  logic [3:0]           arregion;
  logic [3:0]           aruser;
  logic                 arvalid;
  logic                 arready;

  //==================================================
  // Read Data Channel
  //==================================================

  logic [ID_WID-1:0]    rid;
  logic [DATA_WID-1:0]  rdata;
  logic [RSP_WID-1:0]   rresp;
  logic                 rlast;
  logic [3:0]           ruser;
  logic                 rvalid;
  logic                 rready;

endinterface : axi4_if

`endif
