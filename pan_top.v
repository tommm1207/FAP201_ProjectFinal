// pan_top.v – Verilog-2001
// angle[2:0]:
//   3'd1 = 45 deg  (25 buoc)
//   3'd2 = 90 deg  (50 buoc)
//   3'd3 = 135 deg (75 buoc)
//   3'd4 = 180 deg (100 buoc)
//   3'd5 = 225 deg (125 buoc)
//   3'd6 = 270 deg (150 buoc)
//   3'd7 = 360 deg (200 buoc)
module pan_top (
    input        clk,
    input        reset,
    input        btn,
    input  [2:0] angle,     // chon goc quay
    output [3:0] motor
);
    wire       step_clk;
    wire       en;
    wire       done;
    reg  [8:0] target;

    // Giai ma goc thanh so buoc (25 buoc = 45 do)
    always @(*) begin
        case (angle)
            3'd1:    target = 9'd25;
            3'd2:    target = 9'd50;
            3'd3:    target = 9'd75;
            3'd4:    target = 9'd100;
            3'd5:    target = 9'd125;
            3'd6:    target = 9'd150;
            3'd7:    target = 9'd200;
            default: target = 9'd25;
        endcase
    end

    clk_divider #(50) div (
        .clk     (clk),
        .reset   (reset),
        .step_clk(step_clk)
    );

    fsm_pan fsm (
        .clk  (step_clk),
        .reset(reset),
        .btn  (btn),
        .done (done),
        .en   (en)
    );

    step_counter counter (
        .clk   (step_clk),
        .reset (reset),
        .en    (en),
        .target(target),
        .done  (done)
    );

    stepper_driver driver (
        .clk   (step_clk),
        .reset (reset),
        .en    (en),
        .phases(motor)
    );
endmodule
