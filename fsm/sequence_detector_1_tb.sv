`timescale 1ps/1ps
module seq_detector_1_tb();

     reg in, clk, rst_n;
     wire out;

     initial begin
          #1 clk = 1'b0;
          forever #5 clk = ~clk; 
     end

     sequence_detector_1 dut (
          .in  (in),
          .clk (clk),
          .rst_n (rst_n),
          .out (out)
     );

     initial begin
          #0   in = 1'b0;
          @(posedge clk)  
               in = 1'b1;
          @(posedge clk)
               in = 1'b0;
          @(posedge clk)
               in = 1'b0;
          @(posedge clk)
               in = 1'b1;
          @(posedge clk)
               in = 1'b0;
          @(posedge clk)
               in = 1'b0;
          @(posedge clk)
               in = 1'b1;
          @(posedge clk)
               in = 1'b0;
          #120 $finish;
     end

     initial begin
          $dumpfile("seq_1001_detector.vcd");
          $dumpvars();
     end

endmodule
