module axi_fifo_assertion
  #(
    .data_wid ( `DATA_WID),
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
  )
  (
    // global signals
    clk, rstn, ACLK, ARESETn,
    // fifo signals
    wr_en, rd_en, wdata, rdata, full, empty,
    // AW channel
    AWREADY_a, AWID_a, AWADDR_a, AWSIZE_a, AWBUSRT_a, AWLEN_a, AWLOCK_a, AWCACHE_a, AWPROT_a, AWVALID_a,
    // W channel
    WREADY_a, WID_a, WDATA_a, WSTRB_a, WLAST_a, WVALID_a,
    // B channel
    BID_a, BVALID_a, BRESP_a,
    // AR channel
    ARREADY_a, ARID_a, ARADDR_a, ARSIZE_a, ARBUSRT_a, ARLEN_a, ARLOCK_a, ARCACHE_a, ARPROT_a, ARVALID_a,
    // R channel
    RID_a, RVALID_a, RRESP_a, RDATA_a,
  );

  input clk, rstn, ACLK, ARESETn;
  input wr_en, rd_en, full, empty;
  input [`DATA_WID-1 : 0] wdata, rdata;

  input AWVALID_a, AWREADY_a;
  input WVALID_a, WREADY_a;
  input BVALID_a, BRESP_a;
  input ARVALID_a, ARREADY_a;
  input RVALID_a, RREADY_a;

  input [`ADR_WID-1 : 0] AWADDR_a, ARADDR_a;

  input [`ID_WID-1 : 0] AWID_a, WID_a, BID_a, ARID_a, RID_a;
  
  input [`STRB_WID-1 : 0] WSTRB_a;
  input [`LEN_WID-1 : 0] AWLEN_a, ARLEN_a;
  input [`SIZ_WID-1 : 0] AWSIZE_a, ARSIZE_a;
  input [`BST_WID-1 : 0] AWBUSRT_a, ARBUSRT_a;
  input [`LOC_WID-1 : 0] AWLOCK_a, ARLOCK_a;
  input [`CACH_WID-1 : 0] AWCACHE_a, ARCACHE_a;
  input [`PROT_WID-1 : 0] AWPROT_a, ARPROT_a;
  input [`RSP_WID-1 : 0] BRESP_a, RRESP_a;

  // Write Address Channel
  property p_aw_channel_stable;
    @(posedge ACLK) disable iff(!ARESETn)
    (AWVALID_a && !AWREADY_a) |=> ($stable(AWADDR_a) && $stable(AWID_a) && $stable(AWLEN_a) && $stable(AWSIZE_a) && $stable(AWBUSRT_a) && $stable(AWLOCK_a) && $stable(AWCACHE_a) && $stable(AWPROT_a));
  endproperty
  asr_aw_channel_stable: assert property(p_aw_channel_stable);
  else $error("AW channel signals are changed before sampling");

  property p_aw_valid_ready_hsk;
    @(posedge ACLK) disable iff(!ARESETn)
    $rose(AWVALID_a) |-> AWVALID_a until_with AWREADY_a;
  endproperty
  asr_aw_valid_ready_hsk: assert property(p_aw_valid_ready_hsk);
  else $error("AW channel handshake error");

  property p_awburst;
    @(posedge ACLK) disable iff(!ARESETn)
    AWBUSRT_a inside {2'b00, 2'b10, 2'b10};
  endproperty
  asr_awburst: assert property(p_awburst);
  else $display("AWBUSRT_a value is 2'b11");

  property p_awlen_aligned;
    @(posedge ACLK) disable iff(!ARESETn)
    (AWBUSRT_a == 2'b10) |-> ($countones(AWLEN_a + 1)) == 1;
  endproperty
  asr_awlen_aligned: assert property(p_awlen_aligned);
  else $error("Unaligned AWLEN_a for WRAP type");

  property p_aligned_awaddr_for_wrap;
    @(posedge ACLK) disable iff(!ARESETn)
    (AWBUSRT_a == 2'b10) |-> ($countones(AWADDR_a) == 1);
  endproperty
  asr_aligned_awaddr_for_wrap: assert property(p_aligned_awaddr_for_wrap);
  else $error("AWADDR_a is not aligned for WRAP type");

  // Write Data Channel
  property p_w_channel_stable;
    @(posedge ACLK) disable iff(!ARESETn)
    (WVALID_a && !WREADY_a) |=> ($stable(WDATA_a) && $stable(WSTRB_a));
  endproperty
  asr_w_channel_stable: assert property(p_w_channel_stable);
  else $error("W channel signals are changed before sampling");

  property p_w_valid_ready_hsk;
    @(posedge ACLK) disable iff(!ARESETn)
    $rose(WVALID_a) |-> WVALID_a until_with WREADY_a;
  endproperty
  asr_w_valid_ready_hsk: assert property(p_w_valid_ready_hsk);
  else $error("W channel handshake error");

  // Write Response Channel
  property p_b_channel_stable;
    @(posedge ACLK) disable iff(!ARESETn)
    (BVALID_a && !BREADY_a) |=> ($stable(BRESP_a) && $stable(BID_a));
  endproperty
  asr_b_channel_stable: assert property(p_b_channel_stable);
  else $error("B channel signals are changed before sampling");

  property p_b_valid_ready_hsk;
    @(posedge ACLK) disable iff(!ARESETn)
    $rose(BVALID_a) |-> BVALID_a until_with BREADY_a;
  endproperty
  asr_b_valid_ready_hsk: assert property(p_b_valid_ready_hsk);
  else $error("B channel handshake error");


  // Read Address Channel
  property p_ar_channel_stable;
    @(posedge ACLK) disable iff(!ARESETn)
    (ARVALID_a && !ARREADY_a) |=> ($stable(ARADDR_a) && $stable(ARID_a) && $stable(ARLEN_a) && $stable(ARSIZE_a) && $stable(ARBUSRT_a) && $stable(ARLOCK_a) && $stable(ARCACHE_a) && $stable(ARPROT_a));
  endproperty
  asr_ar_channel_stable: assert property(p_ar_channel_stable);
  else $error("AR channel signals are changed before sampling");

  property p_ar_valid_ready_hsk;
    @(posedge ACLK) disable iff(!ARESETn)
    $rose(ARVALID_a) |-> ARVALID_a until_with ARREADY_a;
  endproperty
  asr_ar_valid_ready_hsk: assert property(p_ar_valid_ready_hsk);
  else $error("AR channel handshake error");

  property p_arburst;
    @(posedge ACLK) disable iff(!ARESETn)
    ARBUSRT_a inside {2'b00, 2'b10, 2'b10};
  endproperty
  asr_arburst: assert property(p_arburst);
  else $display("ARBUSRT_a value is 2'b11");

  property p_arlen_aligned;
    @(posedge ACLK) disable iff(!ARESETn)
    (ARBUSRT_a == 2'b10) |-> ($countones(ARLEN_a + 1)) == 1;
  endproperty
  asr_arlen_aligned: assert property(p_arlen_aligned);
  else $error("Unaligned ARLEN_a for WRAP burst type");

  property p_aligned_araddr_for_wrap;
    @(posedge ACLK) disable iff(!ARESETn)
    (ARBUSRT_a == 2'b10) |-> ($countones(ARADDR_a) == 1);
  endproperty
  asr_aligned_araddr_for_wrap: assert property(p_aligned_araddr_for_wrap);
  else $error("ARADDR_a is not aligned for WRAP type");

  // Read Data Channel
  property p_r_channel_stable;
    @(posedge ACLK) disable iff(!ARESETn)
    (RVALID_a && !RREADY_a) |=> ($stable(RDATA_a) && $stable(RRESP_a) && $stable(RID_a) && $stable(RLAST_a));
  endproperty
  asr_r_channel_stable: assert property(p_r_channel_stable);
  else $error("R channel signals are changed before sampling");

  property p_r_valid_ready_hsk;
    @(posedge ACLK) disable iff(!ARESETn)
    $rose(RVALID_a) |-> RVALID_a until_with RREADY_a;
  endproperty
  asr_r_valid_ready_hsk: assert property(p_r_valid_ready_hsk);
  else $error("R channel handshake error");


endmodule
 
