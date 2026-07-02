`include "defines.sv"
//`include "../rtl/axi_fifo_design.v"
`include "interface/fifo_interface.sv"
`include "interface/axi4_interface.sv"
//`include "axi_fifo_packages.sv"
//`include "axi_fifo_assertions.sv"

import uvm_pkg::*;
import axi_fifo_pkg::*;

`timescale 1ns/1ps

module top;

  // Clock frequency in Hz
  parameter real CLK_FREQUENCY = `SET_CLK;

  // Half clock period in ns
  parameter real HALF_PERIOD = 1e9 / ( 2.0 * CLK_FREQUENCY );

  bit clk = 0;
  wire ACLK ;

  bit rstn;
  wire ARESETn;
  assign ARESETn = rstn;
 
  assign ACLK = clk;
  always #(HALF_PERIOD) clk = ~clk;

  // axi interface declaration 
  axi4_if#(
    .data_wid (`DATA_WID),
    .adr_wid  (`ADR_WID),
    .id_wid   (`ID_WID),
    .len_wid  (`LEN_WID),
    .siz_wid  (`SIZ_WID),
    .bst_wid  (`BST_WID),
    .loc_wid  (`LOC_WID),
    .cach_wid (`CACH_WID),
    .prot_wid (`PROT_WID),
    .strb_wid (`STRB_WID),
    .rsp_wid  (`RSP_WID)
  ) axi_vif ( ACLK ) ;

  // fifo_interface declaration
  fifo_interface#(
   .FIFO_DATA_WIDTH(`FIFO_DATA_WIDTH)
  ) fifo_vif ( clk );

  // dut instance 
  Top_Module_AXI4#(
    .data_wid (`DATA_WID),
    .adr_wid  (`ADR_WID),
    .id_wid   (`ID_WID),
    .len_wid  (`LEN_WID),
    .siz_wid  (`SIZ_WID),
    .bst_wid  (`BST_WID),
    .loc_wid  (`LOC_WID),
    .cach_wid (`CACH_WID),
    .prot_wid (`PROT_WID),
    .strb_wid (`STRB_WID),
    .rsp_wid  (`RSP_WID)
  ) DUT (

    //GLOBAL SIGNALS
    .clk(vif.clk),
    .rstn(vif.rstn),
    .ACLK(vif.ACLK),
    .ARESETn(vif.ARESETn),

    //FIFO INPUT
    .wr_en (vif.wr_en),
    .rd_en (vif.rd_en),
    .wr_data (vif.wr_data),

    //FIFO OUTPUT
    .rd_data (vif.rd_data),
    .full (vif.full),
    .empty (vif.empty),

    // AW INPUT
    .AWREADY_a (vif.awready),

    // W INPUT 
    .WREADY_a (vif.wready),

    // AR INPUT
    .ARREADY_a (vif.arready),

    // R INPUT
    .RID_a (vif.rid),
    .RDATA_a (vif.rdata),
    .RRESP_a (vif.rresp),
    .RLAST_a (vif.rlast),
    .RVALID_a (vif.rvalid),

    // B INPUT
    .BID_a (vif.bid),
    .BRESP_a (vif.bresp),
    .BVALID_a (vif.bvalid),

    // AW OUTPUT
    .AWID_a (vif.awid),
    .AWADDR_a (vif.awaddr),
    .AWLEN_a (vif.awlen),
    .AWSIZE_a (vif.awsize),
    .AWBUSRT_a (vif.awbusrt),
    .AWLOCK_a (vif.awlock),
    .AWCACHE_a (vif.awcache),
    .AWPROT_a (vif.awprot),
    .AWVALID_a (vif.awvalid),

    //AR OUTPUT
    .ARID_a (vif.arid),
    .ARADDR_a (vif.araddr),
    .ARLEN_a (vif.arlen),
    .ARSIZE_a (vif.arsize),
    .ARBUSRT_a (vif.arbusrt),
    .ARLOCK_a (vif.arlock),
    .ARCACHE_a (vif.arcache),
    .ARPROT_a (vif.arprot),
    .ARVALID_a (vif.arvalid),

    // W OUTPUT
    .WID_a (vif.wid),
    .WDATA_a (vif.wdata),
    .WSTRB_a (vif.wstrb),
    .WLAST_a (vif.wlast),
    .WVALID_a (vif.wvalid),

    // R OUTPUT
    .RREADY_a (vif.rready),

    // B OUTPUT
    .BREADY_a (vif.bready)

  );

  // assertion bind instance
  bind vif axi_fifo_assertions ASSERT(

    //GLOBAL SIGNALS
    .clk(vif.clk),
    .rstn(vif.rstn),
    .ACLK(vif.ACLK),
    .ARESETn(vif.ARESETn),

    //FIFO INPUT
    .wr_en (vif.wr_en),
    .rd_en (vif.rd_en),
    .wr_data (vif.wr_data),

    //FIFO OUTPUT
    .rd_data (vif.rd_data),
    .full (vif.full),
    .empty (vif.empty),

    // AW INPUT
    .AWREADY_a (vif.awready),

    // W INPUT 
    .WREADY_a (vif.wready),

    // AR INPUT
    .ARREADY_a (vif.arready),

    // R INPUT
    .RID_a (vif.rid),
    .RDATA_a (vif.rdata),
    .RRESP_a (vif.rresp),
    .RLAST_a (vif.rlast),
    .RVALID_a (vif.rvalid),

    // B INPUT
    .BID_a (vif.bid),
    .BRESP_a (vif.bresp),
    .BVALID_a (vif.bvalid),

    // AW OUTPUT
    .AWID_a (vif.awid),
    .AWADDR_a (vif.awaddr),
    .AWLEN_a (vif.awlen),
    .AWSIZE_a (vif.awsize),
    .AWBUSRT_a (vif.awbusrt),
    .AWLOCK_a (vif.awlock),
    .AWCACHE_a (vif.awcache),
    .AWPROT_a (vif.awprot),
    .AWVALID_a (vif.awvalid),

    //AR OUTPUT
    .ARID_a (vif.arid),
    .ARADDR_a (vif.araddr),
    .ARLEN_a (vif.arlen),
    .ARSIZE_a (vif.arsize),
    .ARBUSRT_a (vif.arbusrt),
    .ARLOCK_a (vif.arlock),
    .ARCACHE_a (vif.arcache),
    .ARPROT_a (vif.arprot),
    .ARVALID_a (vif.arvalid),

    // W OUTPUT
    .WID_a (vif.wid),
    .WDATA_a (vif.wdata),
    .WSTRB_a (vif.wstrb),
    .WLAST_a (vif.wlast),
    .WVALID_a (vif.wvalid),

    // R OUTPUT
    .RREADY_a (vif.rready),

    // B OUTPUT
    .BREADY_a (vif.bready)

  );

  initial begin 
    uvm_config_db#(virtual axi4_if)::set(null,"*","axi_vif",axi_vif);
    uvm_config_db#(virtual fifo_interface)::set(null,"*","fifo_vif",fifo_vif);
    $dumpfile("wave.vcd");
    $dumpvars;
  end

  initial begin 
    run_test("axi_fifo_base_test");
    //run_test("axi_fifo_regression_test");
    #1000 ; $finish;
  end

endmodule
