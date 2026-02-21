module sync_fifo_msb #(
    parameter WIDTH=8,
    parameter DEPTH=16
)  (
    input logic 	            clk,
    input logic 	            rst_n,
    input logic	              wr_en,
    input logic               rd_en,
    input logic  [WIDTH-1:0]  wr_data,
    output logic [WIDTH-1:0]  rd_data,
    output logic              full,
    output logic              empty
);
    localparam PTR_WIDTH = $clog2(DEPTH);
    logic [WIDTH-1:0] mem [DEPTH-1:0];
    logic [PTR_WIDTH:0] rd_ptr, wr_ptr;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= {(PTR_WIDTH+1)}{1'b0};
            wr_ptr <= {(PTR_WIDTH+1)}{1'b0};
        end
    else begin
        if (wr_en && !full) begin
            mem[wr_ptr[PTR_WIDTH-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1'b1;
        end
        if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr[PTR_WIDTH-1:0]];
            rd_ptr <= rd_ptr + 1'b1;
        end
      end
    end
    
    always @(*) begin
        empty = (wr_ptr == rd_ptr);
        full = ((wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0])) && (wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]);
    end

endmodule

