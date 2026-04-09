// Task: Building a Moorse FSM vending machine. The machine only accepts nickel, dime, and quarter.
module vending_machine_2 #(
    parameter STOCK  = 5,
    parameter PRICE_A     = 65,
    parameter PRICE_B     = 90,
    parameter PRICE_C     = 40,
    parameter MAX_CREDIT  = 125,
    parameter TIMEOUT_MAX = 20
) (
    input  logic        clk,
    input  logic        rst_n,

    input  logic [1:0]  sel,         // 00=A, 01=B, 10=C
    input  logic        cancel,

    input  logic        coin_en,
    input  logic [6:0]  coin_value,  // 5,10,25 only

    output logic [1:0]  dispense_item,
    output logic        dispense_en,

    output logic [1:0]  change_type, // 00=none,01=5,10=10,11=25
    output logic        change_en,

    output logic        overflow,
    output logic        out_of_stock
);
    localparam CREDIT_W = $clog2(MAX_CREDIT);
    localparam STOCK_W  = $clog2(STOCK);
    localparam TIME_W   = $clog2(TIMEOUT_MAX);

    localparam [1:0] IDLE = 2'b00, WAIT = 2'b01, DISPENSE = 2'b10, RETURN_CHANGE = 2'b11;

    logic [CREDIT_W-1:0] credit, next_credit;
    logic [CREDIT_W-1:0] change_remaining, next_change;

    logic [STOCK_W-1:0] stock_a, stock_b, stock_c;
    logic [STOCK_W-1:0] next_stock_a, next_stock_b, next_stock_c;

    logic [TIME_W-1:0] timeout_cnt, next_timeout;

    logic [1:0] state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state  <= IDLE;
            credit <= 0;
            change_remaining <= 0;

            stock_a <= STOCK;
            stock_b <= STOCK;
            stock_c <= STOCK;

            timeout_cnt <= 0;
        end
        else begin
            state <= next_state;
            credit <= next_credit;
            change_remaining <= next_change;

            stock_a <= next_stock_a;
            stock_b <= next_stock_b;
            stock_c <= next_stock_c;

            timeout_cnt <= next_timeout;
        end
    end

    always_comb begin
        // Defaults (prevent latches)
        next_state = state;

        next_credit = credit;
        next_change = change_remaining;

        next_stock_a = stock_a;
        next_stock_b = stock_b;
        next_stock_c = stock_c;

        next_timeout = timeout_cnt;

        dispense_en = 1'b0;
        dispense_item = 2'b00;

        change_en = 1'b0;
        change_type = 2'b00;

        overflow = 1'b0;
        out_of_stock = 1'b0;

        case (state)

            IDLE:
            begin
                next_timeout = 0;
                if (coin_en) begin
                    next_state  = WAIT;
                    next_credit = coin_value;
                end
            end

            WAIT:
            begin
                // Timeout handling
                if (coin_en)
                    next_timeout = 0;
                else
                    next_timeout = timeout_cnt + 1;

                if (timeout_cnt >= TIMEOUT_MAX && credit > 0) begin
                    next_change = credit;
                    next_state  = RETURN_CHANGE;
                end

                // Cancel handling
                if (cancel && credit > 0) begin
                    next_change = credit;
                    next_state  = RETURN_CHANGE;
                end

                // Coin acceptance
                if (coin_en) begin
                    if (credit <= MAX_CREDIT - coin_value)
                        next_credit = credit + coin_value;
                    else
                        overflow = 1'b1;
                end

                // Selection logic
                if (sel == 2'b00) begin
                    if (stock_a == 0)
                        out_of_stock = 1'b1;
                    else if (credit >= PRICE_A) begin
                        next_credit  = credit - PRICE_A;
                        next_stock_a = stock_a - 1;
                        next_change  = credit - PRICE_A;
                        dispense_item= 2'b00;
                        next_state   = DISPENSE;
                    end
                end

                else if (sel == 2'b01) begin
                    if (stock_b == 0)
                        out_of_stock = 1'b1;
                    else if (credit >= PRICE_B) begin
                        next_credit  = credit - PRICE_B;
                        next_stock_b = stock_b - 1;
                        next_change  = credit - PRICE_B;
                        dispense_item= 2'b01;
                        next_state   = DISPENSE;
                    end
                end

                else if (sel == 2'b10) begin
                    if (stock_c == 0)
                        out_of_stock = 1'b1;
                    else if (credit >= PRICE_C) begin
                        next_credit  = credit - PRICE_C;
                        next_stock_c = stock_c - 1;
                        next_change  = credit - PRICE_C;
                        dispense_item= 2'b10;
                        next_state   = DISPENSE;
                    end
                end
            end

            DISPENSE:
            begin
                dispense_en = 1'b1;

                if (change_remaining > 0)
                    next_state = RETURN_CHANGE;
                else
                    next_state = IDLE;
            end

            RETURN_CHANGE:
            begin
                change_en = 1'b1;

                if (change_remaining >= 25) begin
                    change_type = 2'b11;
                    next_change = change_remaining - 25;
                end
                else if (change_remaining >= 10) begin
                    change_type = 2'b10;
                    next_change = change_remaining - 10;
                end
                else if (change_remaining >= 5) begin
                    change_type = 2'b01;
                    next_change = change_remaining - 5;
                end
                else begin
                    next_change = 0;
                end

                if (next_change == 0) begin
                    next_credit  = 0;
                    next_timeout = 0;
                    next_state   = IDLE;
                end
            end
        endcase
    end

endmodule