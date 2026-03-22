// step_counter.v – Verilog-2001
// Dem den target (truyen vao tu ben ngoai)
module step_counter (
    input            clk,
    input            reset,
    input            en,
    input      [8:0] target,   // so buoc can quay (toi da 511)
    output reg       done
);
    reg [8:0] count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            done  <= 0;
        end else if (en) begin
            if (count < target) begin
                count <= count + 1;
                done  <= 0;
            end else begin
                done <= 1;
            end
        end else begin
            count <= 0;
            done  <= 0;
        end
    end
endmodule
