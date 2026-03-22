// fsm_pan.v – Verilog-2001
// Them trang thai WAIT (delay 8 step_clk) truoc khi cho lenh tiep
module fsm_pan (
    input        clk,
    input        reset,
    input        btn,
    input        done,
    output reg   en
);
    reg  [1:0] state;
    reg  [3:0] wait_cnt;   // dem 8 chu ky cho delay

    localparam IDLE = 2'd0,
               RUN  = 2'd1,
               DONE = 2'd2,
               WAIT = 2'd3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state    <= IDLE;
            wait_cnt <= 0;
        end else begin
            case (state)
                IDLE: if (btn)  state <= RUN;
                RUN:  if (done) state <= DONE;
                DONE: begin
                    state    <= WAIT;
                    wait_cnt <= 0;
                end
                WAIT: begin
                    if (wait_cnt == 4'd7) begin
                        state    <= IDLE;
                        wait_cnt <= 0;
                    end else
                        wait_cnt <= wait_cnt + 1;
                end
                default: state <= IDLE;
            endcase
        end
    end

    always @(*) begin
        en = (state == RUN);
    end
endmodule
