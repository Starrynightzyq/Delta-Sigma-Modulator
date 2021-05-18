`timescale  1ns / 1ps

module sp_efm #(
    parameter WIDTH = 9,  // 小数分频的位宽
    parameter OUT_REG = 0 // 输出加寄存器
) (
    input clk,             // 时钟输入
    input rst_n,           // 复位信号，低有效

    input [WIDTH-1:0] x_i, // 一阶的误差反馈调制器（EFM）的输入
    input y_i,
    output y_o,            // 量化输出
    output [WIDTH-1:0] e_o // 误差输出，作为下一级 EFM 的输入
);

    wire [WIDTH:0] sum;
    reg [WIDTH:0] sum_r;

    // 实现一阶的误差反馈调制器的功能
    assign sum = x_i + y_i + sum_r[WIDTH-1:0];

    // 对求和结果延迟一个时钟周期
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_r <= 'b0;
        end else begin
            sum_r <= sum;
        end
    end

    // // 原始输出
    // assign e_o = sum[WIDTH-1:0];
    // assign y_o = sum[WIDTH];
    // // 优化输出
    // // 由于在 y 的输出上插入寄存器不会影响 Sigma-Delta 的传输函数，即不会影响 Sigma-Delta 的特性，因此将 y 用寄存器打一拍再输出，可以减少逻辑路径的长度，提高电路的频率
    // // assign y_o = sum_r[WIDTH];

    // 输出
    generate
        if (OUT_REG) begin
            // 加寄存器后输出
            assign e_o = sum_r[WIDTH-1:0];
            assign y_o = sum_r[WIDTH];
        end else begin
            // 直接输出
            assign e_o = sum[WIDTH-1:0];
            assign y_o = sum[WIDTH];
        end
    endgenerate

endmodule