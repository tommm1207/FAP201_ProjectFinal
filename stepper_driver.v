module stepper_driver (
    input clk,
    input reset,
    input en,
    output reg [3:0] phases
);

    reg [2:0] seq;

    always @(posedge clk or posedge reset) begin
        if (reset)
            seq <= 0;
        else if (en)
            seq <= seq + 1;
    end

    always @(*) begin
        case (seq)
            0: phases = 4'b1000;
            1: phases = 4'b1100;
            2: phases = 4'b0100;
            3: phases = 4'b0110;
            4: phases = 4'b0010;
            5: phases = 4'b0011;
            6: phases = 4'b0001;
            7: phases = 4'b1001;
            default: phases = 4'b1000;
        endcase
    end
endmodule
