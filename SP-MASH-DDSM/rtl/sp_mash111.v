`timescale  1ns / 1ps

module sp_mash111 #(
    parameter WIDTH = 9,  // 小数分频的位宽
    parameter OUT_REG = 1 // 输出加寄存器
) (
    input clk,             // 时钟输入
    input rst_n,           // 复位信号，低有效

    input [WIDTH-1:0] x_i, // Sigma-Delta 调制器的输入，即分频中小数的输入
    output [3:0] y_o,      // 量化输出
    output [WIDTH-1:0] e_o // 最后一级 EFM 的误差输出，实际上用不到，不用管
);

    // efm inputs or outputs
    wire [WIDTH-1:0] x_i_1;
    wire [WIDTH-1:0] e_o_1;
    wire y_o_1;
    wire [WIDTH-1:0] x_i_2;
    wire [WIDTH-1:0] e_o_2;
    wire y_o_2;
    wire [WIDTH-1:0] x_i_3;
    wire [WIDTH-1:0] e_o_3;
    wire y_o_3;

    // ncl Inputs
    wire y1_i;
    wire y2_i;
    wire y3_i;

    // // 前一级 efm 的误差输出作为后一级 efm 的输入
    assign x_i_1 = x_i;
    assign x_i_2 = {e_o_1, 4'b0};
    assign x_i_3 = e_o_2;

    // e 输出
    assign e_o = e_o_3;

    // 三级 efm 级联
    sp_efm #(
        .WIDTH ( 5 ),
        .OUT_REG ( OUT_REG  ))
    u_sp_efm_1 (
        .clk                     ( clk     ),
        .rst_n                   ( rst_n   ),
        .x_i                     ( x_i_1   ),
        .y_i                     ( 1'b0    ),

        .y_o                     ( y_o_1   ),
        .e_o                     ( e_o_1   )
    );

    sp_efm #(
        .WIDTH ( WIDTH ),
        .OUT_REG( OUT_REG ))
    u_sp_efm_2 (
        .clk                     ( clk     ),
        .rst_n                   ( rst_n   ),
        .x_i                     ( x_i_2   ),
        .y_i                     ( y_o_1   ),

        .y_o                     ( y_o_2   ),
        .e_o                     ( e_o_2   )
    );

    sp_efm #(
        .WIDTH ( WIDTH ),
        .OUT_REG( OUT_REG ))
    u_sp_efm_3 (
        .clk                     ( clk     ),
        .rst_n                   ( rst_n   ),
        .x_i                     ( x_i_3   ),
        .y_i                     ( y_o_2   ),

        .y_o                     ( y_o_3   ),
        .e_o                     ( e_o_3   )
    );

    // noise cancellation logic 
    ncl #(
        .OUT_REG ( 1 ))
    u_ncl (
        .clk                     ( clk     ),
        .rst_n                   ( rst_n   ),
        .y1_i                    ( y1_i    ),
        .y2_i                    ( y2_i    ),
        .y3_i                    ( y3_i    ),

        .y_o                     ( y_o     )
    );

    // efm 级间加寄存器
    generate
        if (OUT_REG) begin
            wire y1_reg_0;
            wire y1_reg_1;
            wire y2_reg_0;
            dff #(
                .WIDTH     ( 1 ),
                .WITH_RST  ( 0 ),
                .RST_VALUE ( 0 ))
            u0_dff (
                .clk                     ( clk    ),
                .rst_n                   ( rst_n  ),
                .D                       ( y_o_1   ),

                .Q                       ( y1_reg_0 )
            );
            dff #(
                .WIDTH     ( 1 ),
                .WITH_RST  ( 0 ),
                .RST_VALUE ( 0 ))
            u1_dff (
                .clk                     ( clk    ),
                .rst_n                   ( rst_n  ),
                .D                       ( y1_reg_0   ),

                .Q                       ( y1_reg_1 )
            );
            dff #(
                .WIDTH     ( 1 ),
                .WITH_RST  ( 0 ),
                .RST_VALUE ( 0 ))
            u2_dff (
                .clk                     ( clk    ),
                .rst_n                   ( rst_n  ),
                .D                       ( y_o_2   ),

                .Q                       ( y2_reg_0 )
            );
            assign y1_i = y1_reg_1;
            assign y2_i = y2_reg_0;
            assign y3_i = y_o_3;
        end else begin
            assign y1_i = y_o_1;
            assign y2_i = y_o_2;
            assign y3_i = y_o_3;
        end
    endgenerate
    
endmodule