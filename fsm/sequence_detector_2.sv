// Task: detect 101101 and 101001
module seq_detector_2 (
    input logic clk,
    input logic rst_n,
    input logic in,
    output logic detected
);
    localparam S0 = 4'd0, S1 = 4'd1, S2 = 4'd2, S3 = 4'd3, S4 = 4'd4, S5 = 4'd5, S6 = 4'd6, S7 = 4'd7, S8 = 4'd8, S9 = 4'd9;
    logic [3:0] state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            state <= S0;
        else 
            state <= next_state;
    end

    always @(*) begin
        next_state = state; // Use to prevent infer latch where next_state is never assigned
        case(state) 
            // Nothing
            S0: if (in == 1'b1) next_state = S1;
            
            // 1
            S1: if (in == 1'b0) next_state = S2;    // Stay even if in == 1, because it just means we start over at S1
            
            // 10
            S2: begin
                if (in == 1'b1) next_state = S3;
                else next_state = S0;
            end
            
            // 101
            S3: begin
                if (in == 1) next_state = S4;
                else if (in == 0) next_state = S7;
            end
            
            // 1011
            S4: begin
                if (in == 0) next_state = S5;
                else if (in == 1) next_state = S1;
            end
            
            // 10110
            S5: begin
                if (in == 1) next_state = S6;
                else if (in == 0) next_state = S0;
            end
            
            // 101101
            S6: begin
                if (in == 1) next_state = S4;
                else if (in == 0) next_state = S7;
            end
            
            // 1010
            S7: begin
                if (in == 0) next_state = S8;
                else if (in == 1) next_state = S3;
            end
            
            // 10100
            S8: begin
                if (in == 1) next_state = S9;
                else if (in == 0) next_state = S0;
            end
            
            // 101001
            S9: begin
                if (in == 1) next_state = S1;
                else if (in == 0) next_state = S2;
            end
            default: next_state <= S0;
        endcase
    end

    assign detected = ((state == S9) || (state == S6));

endmodule
