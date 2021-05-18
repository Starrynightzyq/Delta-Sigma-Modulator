`timescale  1ns / 1ps

// 异步复位（低电平）的 D 触发器
module dff #(
    parameter WIDTH = 1,
    parameter WITH_RST = 0,
    parameter RST_VALUE = 0
) (
    input clk,
    input rst_n,

    input [WIDTH-1:0] D,
    output reg [WIDTH-1:0] Q=0,
    output [WIDTH-1:0] Qn
);

    generate
        if (WITH_RST) begin 
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    Q <= {WIDTH{RST_VALUE[0]}};
                end else begin
                    Q <= D;
                end
            end
        end else begin
            always @(posedge clk) begin
                Q <= D;
            end
        end
    endgenerate

    assign Qn = ~Q;
    
endmodule