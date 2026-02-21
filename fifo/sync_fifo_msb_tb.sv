`timescale 1ns/100ps
module tb();
    reg clk, rst_n, wr_en, rd_en;
    reg [7:0] wr_data;
    wire [7:0] rd_data;
    wire full, empty;
  
    initial begin
        #10 clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    sync_fifo_msb #(
        .WIDTH	(8),
        .DEPTH	(16)
    ) dut (
        .clk	(clk),
        .rst_n	(rst_n),
        .wr_en	(wr_en),
        .rd_en	(rd_en),
        .wr_data (wr_data),
        .rd_data (rd_data),
        .full	(full),
        .empty	(empty)
    );
    
    initial begin
        #0 begin
              rst_n = 1'b0;
              wr_en = 1'b0;
              rd_en = 1'b0;
              wr_data = 16'b0;
        end
        #10 begin
            rst_n = 1'b1;
        end
        for (reg i=0; i<16; i++) begin
            @(posedge clk) begin 
                wr_en = 1;
                wr_data = i;
            end
        end
        @(posedge clk) wr_en = 0;

        #40 $finish;
    end
    
    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars();
    end
  
endmodule