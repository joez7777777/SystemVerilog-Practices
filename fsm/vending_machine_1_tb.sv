// `timescale 1ns/100ps
module vending_machine_1_tb();

    reg clk, rst_n, nickel, dime, quarter;
    wire dispense, change;

    initial begin
        #1 clk = 1'b0;
        forever #5 clk = ~clk; // 10ns period
    end
  
    vending_machine_1 dut (
        .*
    );

    initial begin
        #0   begin
            rst_n = 1'b0;
            nickel = 1'b0;
            dime = 1'b0;
            quarter = 1'b0;
        end
        #10	 rst_n = 1'b1;
        @(posedge clk)
            nickel = 1'b1;
        @(posedge clk) begin
            nickel = 1'b0;
            dime = 1'b1;
        end
        @(posedge clk)
        @(posedge clk)
            dime = 1'b0;
        @(posedge clk) begin
            dime = 1'b0;
            quarter = 1'b1;
        end
        @(posedge clk) quarter = 1'b0;
        #100 $finish;
    end

    initial begin
        $dumpfile("vending_machine_wave");
        $dumpvars();
    end

endmodule
