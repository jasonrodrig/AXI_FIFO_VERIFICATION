`timescale 1ns/1ps

interface fifo_interface #(parameter FIFO_DATA_WIDTH = 128)
(
    input logic clk,
    input logic rstn
);

  //============================================================
  // CPU -> FIFO Write
  //============================================================
  logic                        wr_en;
  logic [FIFO_DATA_WIDTH-1:0]  wr_data;
  logic                        full;

  //============================================================
  // CPU <- FIFO Read
  //============================================================
  logic                        rd_en;
  logic [FIFO_DATA_WIDTH-1:0]  rd_data;
  logic                        empty;

  //============================================================
  // Driver Clocking Block
  //============================================================
  clocking cpu_driver_cb @(posedge clk);
    default input #1step output #0;

    output wr_en;
    output wr_data;
    output rd_en;

    input  full;
    input  empty;
    input  rd_data;
  endclocking

  //============================================================
  // Active Monitor Clocking Block
  //============================================================
  clocking cpu_active_mon_cb @(posedge clk);
    default input #1step output #0;

    input wr_en;
    input wr_data;
    input rd_en;

    input full;
    input empty;
    input rd_data;
  endclocking

  //============================================================
  // Passive Monitor Clocking Block
  //============================================================
  clocking cpu_passive_mon_cb @(posedge clk);
    default input #1step output #0;

    input wr_en;
    input wr_data;
    input rd_en;

    input full;
    input empty;
    input rd_data;
  endclocking

  //============================================================
  // Modports
  //============================================================
  modport CPU_DRIVER_MP
  (
      clocking cpu_driver_cb,
      input clk,
      input rstn
  );

  modport CPU_ACTIVE_MON_MP
  (
      clocking cpu_active_mon_cb,
      input clk,
      input rstn
  );

  modport CPU_PASSIVE_MON_MP
  (
      clocking cpu_passive_mon_cb,
      input clk,
      input rstn
  );

endinterface : fifo_interface
