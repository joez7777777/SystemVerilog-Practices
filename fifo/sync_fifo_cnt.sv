`timescale 1ns/100ps
module sync_fifo_counter #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             wr_en,
    input  logic             rd_en,
    input  logic [WIDTH-1:0] wr_data,
    output logic [WIDTH-1:0] rd_data,
    output logic             full,
    output logic             empty
);
    localparam int PTR_DEPTH = $clog2(DEPTH);
    localparam int CNT_W     = $clog2(DEPTH+1);

    logic [CNT_W-1:0] counter;
    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_DEPTH-1:0] wr_ptr, rd_ptr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr   <= {PTR_DEPTH{1'b0}};
            rd_ptr   <= {PTR_DEPTH{1'b0}};
            counter  <= {CNT_W{1'b0}};
            rd_data  <= {WIDTH{1'b0}};
        end else begin
            // Write
            if (!full && wr_en) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr      <= wr_ptr + 1'b1;
            end
            
            // Read
            if (!empty && rd_en) begin
                rd_data <= mem[rd_ptr];
                rd_ptr  <= rd_ptr + 1'b1;
            end
            counter <= counter
                     + ((wr_en && !full)  ? 1'b1 : 1'b0)
                     - ((rd_en && !empty) ? 1'b1 : 1'b0);
        end
    end

    always @(*) begin
        empty = (counter == 0);
        full  = (counter == DEPTH);
    end

endmodule