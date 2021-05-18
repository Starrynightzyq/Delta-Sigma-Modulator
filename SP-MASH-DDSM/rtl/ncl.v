`timescale  1ns / 1ps

// noise cancellation logic 
module ncl #(
    parameter OUT_REG = 1 // 输出加寄存器
)(
    input clk,             // 时钟输入
    input rst_n,           // 复位信号，低有效
    input y1_i,
    input y2_i,
    input y3_i,
    output [3:0] y_o
);
    
    wire signed [2:0] c1;
    wire signed [3:0] c2;
    wire signed [0:0] c0_reg;
    wire signed [2:0] c1_reg; 
    wire signed [3:0] c2_reg;


    // 将 3 级 efm 的输出求和
    assign c1 = y2_i + y3_i - c0_reg;
    assign c2 = y1_i + {c1[2], c1} - {c1_reg[2], c1_reg}; // 补全符号位

    // 延迟
    // 没有 reset，在刚上电的时候输出会不确定，但数据稳定输出后就没有影响了
    dff #(
        .WIDTH     ( 1 ),
        .WITH_RST  ( 0 ),
        .RST_VALUE ( 0 ))
    u0_dff (
        .clk                     ( clk    ),
        .rst_n                   ( rst_n  ),
        .D                       ( y3_i   ),

        .Q                       ( c0_reg ),
        .Qn                      (        )
    );
    dff #(
        .WIDTH     ( 3 ),
        .WITH_RST  ( 0 ),
        .RST_VALUE ( 0 ))
    u1_dff (
        .clk                     ( clk    ),
        .rst_n                   ( rst_n  ),
        .D                       ( c1     ),

        .Q                       ( c1_reg ),
        .Qn                      (        )
    );
    dff #(
        .WIDTH     ( 4 ),
        .WITH_RST  ( 0 ),
        .RST_VALUE ( 0 ))
    u2_dff (
        .clk                     ( clk    ),
        .rst_n                   ( rst_n  ),
        .D                       ( c2     ),

        .Q                       ( c2_reg ),
        .Qn                      (        )
    );

    // 输出
    generate
        if (OUT_REG) begin
            // 加寄存器后输出
            assign y_o = c2_reg;
        end else begin
            // 直接输出
            assign y_o = c2;
        end
    endgenerate

endmodule