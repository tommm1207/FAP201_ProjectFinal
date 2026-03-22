module clk_divider #(parameter DIV = 50)(
    input clk,
    input reset,
    output reg step_clk
);

    reg [15:0] cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt <= 0;
            step_clk <= 0;
        end else if (cnt == DIV-1) begin
            cnt <= 0;
            step_clk <= ~step_clk;
        end else begin
            cnt <= cnt + 1;
        end
    end
endmodule
