`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2025 11:08:14
// Design Name: 
// Module Name: UART_testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module UART_testbench;

  parameter CLK_TX_PERIOD = 20.0;        // 50 MHz ? 20 ns
  parameter CLK_RX_PERIOD = 20.202;      // 49.5 MHz ~20.202 ns
  parameter BAUD_RATE     = 115200;
  parameter BIT_PERIOD    = 1_000_000_000 / BAUD_RATE; // ~8680 ns

  // Testbench signals
  reg clk_tx = 0, clk_rx = 0;
  reg rst_tx = 1, rst_rx = 1;
  reg tx_start = 0;
  reg [7:0] tx_data_in = 0;
  wire tx_serial, tx_busy;
  wire rx_done;
  wire [7:0] rx_data_out;

  // Instantiate UART Transmitter
  UART_Tx tx_inst (
    .clk(clk_tx),
    .rst(rst_tx),
    .tx_st(tx_start),
    .tx_data(tx_data_in),
    .tx_busy(tx_busy),
    .tx_serial(tx_serial)
  );

  // Instantiate UART Receiver
  UART_Rx rx_inst (
    .clk(clk_rx),
    .rst(rst_rx),
    .rx_serial(tx_serial),
    .done(rx_done),
    .rx_data(rx_data_out)
  );

  // Clock generators
  always #(CLK_TX_PERIOD/2) clk_tx = ~clk_tx;
  always #(CLK_RX_PERIOD/2) clk_rx = ~clk_rx;

  // Task to send a byte over UART
  task send_byte(input [7:0] data);
    begin
      @(posedge clk_tx);
      while (tx_busy) @(posedge clk_tx);  // Wait until transmitter is ready
      tx_data_in = data;
      tx_start = 1;
      @(posedge clk_tx);
      tx_start = 0;
    end
  endtask

  // Monitor received bytes
  always @(posedge clk_rx) begin
    if (rx_done) begin
      $display("[%0t ns] RECEIVED BYTE: 0x%02h", $time, rx_data_out);
    end
  end

  initial begin
    $display("===== UART TX-RX Loopback Testbench =====");

    // Optional for waveform
    $dumpfile("uart_txrx_tb.vcd");
    $dumpvars(0, UART_testbench);

    // Reset both domains
    rst_tx = 1; rst_rx = 1;
    #100;
    rst_tx = 0; rst_rx = 0;

    // === Test Cases ===

    // 1) Single byte
    $display("[%0t ns] Sending byte 0xA5", $time);
    send_byte(8'hA5);

    // 2) Delay before next byte
    #(BIT_PERIOD * 10);
    $display("[%0t ns] Sending byte 0x5A", $time);
    send_byte(8'h5A);

    // 3) Back-to-back bytes
    #(BIT_PERIOD * 8);
    $display("[%0t ns] Sending byte 0xFF", $time);
    send_byte(8'hFF);

    #(BIT_PERIOD*8);
    $display("[%0t ns] Sending byte 0x00", $time);
    send_byte(8'h00);

    // 4) More stress
    #(BIT_PERIOD);
    $display("[%0t ns] Sending byte 0xC3", $time);
    send_byte(8'hC3);

    #(BIT_PERIOD);
    $display("[%0t ns] Sending byte 0x3C", $time);
    send_byte(8'h3C);

    // End
    #(BIT_PERIOD * 20);
    $display("[%0t ns] Testbench complete.", $time);
    $finish;
  end

endmodule