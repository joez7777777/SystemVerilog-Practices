`timescale 1ps/1ps
module tb();
  reg clk, rst_n;
  wire clk_out;
  
  initial begin
  	#0 clk = 0;
    forever #1 clk = ~clk;
  end
  
  divide_by_odd_50dc #(
    .N (5)
  ) dut (
    .clk (clk),
    .rst_n (rst_n),
    .clk_out (clk_out)
  );
  
  initial begin
    #0 rst_n = 0;
    #1 rst_n = 1;
    #50 $finish;
  end
  
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars();
  end
  
endmodule