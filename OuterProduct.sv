// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2022

`ifndef __OUTERPRODUCT_SV__
`define __OUTERPRODUCT_SV__

`include "common/RgbdVoConfigPk.sv"
//`include "./DW02_mult_2_stage.v"
//`include "./DataDelay.sv"

//

module OuterProduct
    import RgbdVoConfigPk::*;
#(
)(
    // input
     input                            i_clk
    ,input                            i_rst_n
    ,input                            i_valid
    ,input        [CLOUD_BW-1:0]      i_p0_x 
    ,input        [CLOUD_BW-1:0]      i_p0_y 
    ,input        [CLOUD_BW-1:0]      i_p0_z 
    ,input        [CLOUD_BW-1:0]      i_p1_x
    ,input        [CLOUD_BW-1:0]      i_p1_y
    ,input        [CLOUD_BW-1:0]      i_p1_z
    // Output
    ,output logic                     o_valid
    ,output logic [CLOUD_BW+CLOUD_BW-1:0]      o_normal_x
    ,output logic [CLOUD_BW+CLOUD_BW-1:0]      o_normal_y
    ,output logic [CLOUD_BW+CLOUD_BW-1:0]      o_normal_z
);

    //=================================
    // Signal Declaration
    //=================================

    logic [CLOUD_BW+CLOUD_BW-1:0]     p0y_mul_p1z, p0z_mul_p1y;
    logic [CLOUD_BW+CLOUD_BW-1:0]     p0z_mul_p1x, p0x_mul_p1z;
    logic [CLOUD_BW+CLOUD_BW-1:0]     p0x_mul_p1y, p0y_mul_p1x;
    logic [CLOUD_BW+CLOUD_BW-1:0]     normal_x_final;
    logic [CLOUD_BW+CLOUD_BW-1:0]     normal_y_final;
    logic [CLOUD_BW+CLOUD_BW-1:0]     normal_z_final;
    logic                             valid_d1;

    //=================================
    // Combinational Logic
    //=================================
    assign normal_x_final = $signed(p0y_mul_p1z - p0z_mul_p1y);
    assign normal_y_final = $signed(p0z_mul_p1x - p0x_mul_p1z);
    assign normal_z_final = $signed(p0x_mul_p1y - p0y_mul_p1x);
    assign o_normal_x = normal_x_final[CLOUD_BW+CLOUD_BW-1:0];
    assign o_normal_y = normal_y_final[CLOUD_BW+CLOUD_BW-1:0];
    assign o_normal_z = normal_z_final[CLOUD_BW+CLOUD_BW-1:0];
    assign o_valid = valid_d1;

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(CLOUD_BW)
    ) u_p0y_mul_p1z (
         .A($signed(i_p0_y))
        ,.B($signed(i_p1_z))
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(p0y_mul_p1z)
    );

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(CLOUD_BW)
    ) u_p0z_mul_p1y (
         .A($signed(i_p0_z))
        ,.B($signed(i_p1_y))
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(p0z_mul_p1y)
    );

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(CLOUD_BW)
    ) u_p0z_mul_p1x (
         .A($signed(i_p0_z))
        ,.B($signed(i_p1_x))
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(p0z_mul_p1x)
    );

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(CLOUD_BW)
    ) u_p0x_mul_p1z (
         .A($signed(i_p0_x))
        ,.B($signed(i_p1_z))
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(p0x_mul_p1z)
    );

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(CLOUD_BW)
    ) u_p0x_mul_p1y (
         .A($signed(i_p0_x))
        ,.B($signed(i_p1_y))
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(p0x_mul_p1y)
    );

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(CLOUD_BW)
    ) u_p0y_mul_p1x (
         .A($signed(i_p0_y))
        ,.B($signed(i_p1_x))
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(p0y_mul_p1x)
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(1)
    ) u_valid_d1 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_valid)
        // Output
        ,.o_data(valid_d1)
    );

    //===================
    //    Sequential
    //===================

endmodule

`endif // __OUTERPRODUCT_SV__
