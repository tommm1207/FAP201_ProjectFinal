// ============================================================
//  tb_pan.v – Verilog-2001, tuong thich ModelSim ASE 2020.1
//
//  TIMING:
//    clk      = 10 ns (100 MHz)
//    DIV=50   -> step_clk toggle sau 500 ns -> chu ky 1000 ns
//    FSM + counter chay tren step_clk
//    1 vong quay 45 do (25 step_clk) = 25 us
//    1 vong quay 360 do (200 step_clk) = 200 us
//
//  GIU BTN CAO:  200 chu ky clk = 2 us ~ 2 step_clk (dam bao FSM doc duoc)
//  CHO EN LEN:   toi da 2000 chu ky clk = 20 us
//  CHO EN XUONG: toi da 25000 chu ky clk = 250 us (du cho 360 do)
// ============================================================
`timescale 1ns/1ps

module tb_pan;

    reg        clk;
    reg        reset;
    reg        btn;
    reg  [2:0] angle;
    wire [3:0] motor;

    localparam CLK_HALF      = 5;
    localparam BTN_HOLD      = 200;
    localparam WAIT_EN_MAX   = 2000;
    localparam WAIT_DONE_MAX = 25000;

    integer pass_cnt;
    integer tc;

    pan_top uut (
        .clk  (clk),
        .reset(reset),
        .btn  (btn),
        .angle(angle),
        .motor(motor)
    );

    initial clk = 0;
    always #CLK_HALF clk = ~clk;

    // --- Task: reset ---
    task do_reset;
    begin
        reset = 1;
        btn   = 0;
        repeat(10) @(posedge clk);
        reset = 0;
        @(posedge clk);
    end
    endtask

    // --- Task: nhan btn (giu BTN_HOLD chu ky dam bao FSM doc duoc) ---
    task press_btn;
    begin
        @(posedge clk);
        btn = 1;
        repeat(BTN_HOLD) @(posedge clk);
        btn = 0;
        @(posedge clk);
    end
    endtask

    // --- Task: cho en len roi cho en xuong ---
    task wait_run_done;
    integer i;
    begin
        i = 0;
        while (uut.en !== 1'b1 && i < WAIT_EN_MAX) begin
            @(posedge clk); i = i + 1;
        end
        if (uut.en !== 1'b1)
            $display("[WARN] TC%0d: en khong len HIGH (timeout)", tc);
        i = 0;
        while (uut.en !== 1'b0 && i < WAIT_DONE_MAX) begin
            @(posedge clk); i = i + 1;
        end
        if (uut.en !== 1'b0)
            $display("[WARN] TC%0d: en khong xuong (timeout)", tc);
        // Cho them 8 step_clk (delay WAIT state trong FSM)
        repeat(800) @(posedge clk);
    end
    endtask

    // ==========================================================
    //  MAIN
    // ==========================================================
    initial begin
        pass_cnt = 0;
        $display("====================================================");
        $display("  MO PHONG: Multi-angle Stepper Pan Controller");
        $display("  25 buoc = 45 do | 50 buoc = 90 do");
        $display("  100 buoc = 180 do | 200 buoc = 360 do");
        $display("====================================================");

        // ------------------------------------------------------
        // TC1: Reset – motor=1000, en=0
        // ------------------------------------------------------
        tc = 1;
        $display("\n--- TC%0d: Reset co ban ---", tc);
        angle = 3'd2;
        do_reset;
        repeat(10) @(posedge clk);
        if (motor === 4'b1000 && uut.en === 1'b0) begin
            $display("[PASS] TC%0d: motor=%b en=%b", tc, motor, uut.en);
            pass_cnt = pass_cnt + 1;
        end else
            $display("[FAIL] TC%0d: motor=%b en=%b", tc, motor, uut.en);

        // ------------------------------------------------------
        // TC2: Quay 45 do (angle=1, target=25)
        // ------------------------------------------------------
        tc = 2;
        $display("\n--- TC%0d: Quay 45 do (angle=001) ---", tc);
        angle = 3'd1;
        do_reset;
        press_btn;
        wait_run_done;
        if (uut.en === 1'b0) begin
            $display("[PASS] TC%0d: Quay 45 do xong. motor=%b", tc, motor);
            pass_cnt = pass_cnt + 1;
        end else
            $display("[FAIL] TC%0d: en=%b", tc, uut.en);

        // ------------------------------------------------------
        // TC3: Quay 90 do (angle=2, target=50)
        // ------------------------------------------------------
        tc = 3;
        $display("\n--- TC%0d: Quay 90 do (angle=010) ---", tc);
        angle = 3'd2;
        do_reset;
        press_btn;
        wait_run_done;
        if (uut.en === 1'b0) begin
            $display("[PASS] TC%0d: Quay 90 do xong. motor=%b", tc, motor);
            pass_cnt = pass_cnt + 1;
        end else
            $display("[FAIL] TC%0d: en=%b", tc, uut.en);

        // ------------------------------------------------------
        // TC4: Quay 180 do (angle=4, target=100)
        // ------------------------------------------------------
        tc = 4;
        $display("\n--- TC%0d: Quay 180 do (angle=100) ---", tc);
        angle = 3'd4;
        do_reset;
        press_btn;
        wait_run_done;
        if (uut.en === 1'b0) begin
            $display("[PASS] TC%0d: Quay 180 do xong. motor=%b", tc, motor);
            pass_cnt = pass_cnt + 1;
        end else
            $display("[FAIL] TC%0d: en=%b", tc, uut.en);

        // ------------------------------------------------------
        // TC5: Quay 360 do (angle=7, target=200)
        // ------------------------------------------------------
        tc = 5;
        $display("\n--- TC%0d: Quay 360 do (angle=111) ---", tc);
        angle = 3'd7;
        do_reset;
        press_btn;
        wait_run_done;
        if (uut.en === 1'b0) begin
            $display("[PASS] TC%0d: Quay 360 do xong. motor=%b", tc, motor);
            pass_cnt = pass_cnt + 1;
        end else
            $display("[FAIL] TC%0d: en=%b", tc, uut.en);

        // ------------------------------------------------------
        // TC6: Quay 0->45 roi doi delay, tiep 45->90
        //       2 lan nhan btn lien tiep, moi lan 45 do
        // ------------------------------------------------------
        tc = 6;
        $display("\n--- TC%0d: 0->45 roi doi WAIT delay, tiep 45->90 ---", tc);
        angle = 3'd1;
        do_reset;
        press_btn;
        wait_run_done;   // bao gom 8 step_clk WAIT delay
        press_btn;
        wait_run_done;
        if (uut.en === 1'b0) begin
            $display("[PASS] TC%0d: 2x45 do thanh cong, co delay giua. motor=%b",
                     tc, motor);
            pass_cnt = pass_cnt + 1;
        end else
            $display("[FAIL] TC%0d: en=%b", tc, uut.en);

        // ------------------------------------------------------
        // TC7: Thay doi angle giua 2 lan quay (45 roi 180)
        // ------------------------------------------------------
        tc = 7;
        $display("\n--- TC%0d: Lan 1: 45 do, lan 2: 180 do ---", tc);
        angle = 3'd1;
        do_reset;
        press_btn;
        wait_run_done;
        angle = 3'd4;
        press_btn;
        wait_run_done;
        if (uut.en === 1'b0) begin
            $display("[PASS] TC%0d: Doi angle giua 2 lan OK. motor=%b",
                     tc, motor);
            pass_cnt = pass_cnt + 1;
        end else
            $display("[FAIL] TC%0d: en=%b", tc, uut.en);

        // ------------------------------------------------------
        // TC8: Reset giua chung
        // ------------------------------------------------------
        tc = 8;
        $display("\n--- TC%0d: Reset giua chung khi dang quay 180 do ---", tc);
        angle = 3'd4;
        do_reset;
        press_btn;
        begin : wait_en8
            integer j;
            j = 0;
            while (uut.en !== 1'b1 && j < WAIT_EN_MAX) begin
                @(posedge clk); j = j + 1;
            end
        end
        repeat(3000) @(posedge clk);  // doi ~30 us (nua chung)
        reset = 1;
        repeat(6) @(posedge clk);
        reset = 0;
        repeat(10) @(posedge clk);
        if (uut.en === 1'b0 && motor === 4'b1000) begin
            $display("[PASS] TC%0d: Reset giua chung OK. motor=%b en=%b",
                     tc, motor, uut.en);
            pass_cnt = pass_cnt + 1;
        end else
            $display("[FAIL] TC%0d: motor=%b en=%b", tc, motor, uut.en);

        // ------------------------------------------------------
        // Tong ket
        // ------------------------------------------------------
        repeat(200) @(posedge clk);
        $display("\n====================================================");
        $display("  KET QUA: %0d / 8 test case PASS", pass_cnt);
        $display("====================================================\n");
    end

    initial begin
        $dumpfile("tb_pan.vcd");
        $dumpvars(0, tb_pan);
    end

endmodule
