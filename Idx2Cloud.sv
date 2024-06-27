// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2022

//`include "common/RgbdVoConfigPk.sv"
//`include "./DW02_mult_2_stage.v"
//`include "./DW_div.v"
//`include "./DW_div_pipe.v"
//`include "./DataDelay.sv"

//6T
module Idx2Cloud
    import RgbdVoConfigPk::*;
#(
)(
    // input
     input                            i_clk
    ,input                            i_rst_n
    ,input                            i_valid
    ,input        [H_SIZE_BW-1:0]     i_idx_x   //H_SIZE_BW = 10;
    ,input        [V_SIZE_BW-1:0]     i_idx_y   //V_SIZE_BW = 10;
    ,input        [DATA_DEPTH_BW-1:0] i_depth   //DATA_DEPTH_BW = 16;
    // Register
    ,input        [FX_BW-1:0]         r_fx
    ,input        [FY_BW-1:0]         r_fy
    ,input        [CX_BW-1:0]         r_cx
    ,input        [CY_BW-1:0]         r_cy
    // Output
    ,output logic                     o_valid
    ,output logic [CLOUD_BW-1:0]      o_cloud_x //CLOUD_BW = 42;
    ,output logic [CLOUD_BW-1:0]      o_cloud_y
    ,output logic [CLOUD_BW-1:0]      o_cloud_z
);

    //=================================
    // Signal Declaration
    //=================================
    //d0
    logic [H_SIZE_BW+MUL:0]                 idx_x_sub_cx; //signed
    logic [V_SIZE_BW+MUL:0]                 idx_y_sub_cy; //signed

    //d1
    logic [H_SIZE_BW+MUL:0]                 idx_x_sub_cx_r; //signed
    logic [V_SIZE_BW+MUL:0]                 idx_y_sub_cy_r; //signed

    logic [DATA_DEPTH_BW-1:0]               depth_d1_r;

    //d2
    logic [DATA_DEPTH_BW+H_SIZE_BW+MUL:0]   px_mul;     //px_mul = (i_idx_x - r_cx) * i_depth
    logic [DATA_DEPTH_BW+V_SIZE_BW+MUL:0]   py_mul;     //py_mul = (i_idx_y - r_cy) * i_depth

    //d6
    logic [DATA_DEPTH_BW+H_SIZE_BW+MUL:0]   px_mul_div; //px_mul_div = (i_idx_x - r_cx) * i_depth / r_fx
    logic [DATA_DEPTH_BW+V_SIZE_BW+MUL:0]   py_mul_div; //py_mul_div = (i_idx_y - r_cy) * i_depth / r_fy

    logic [DATA_DEPTH_BW+H_SIZE_BW+MUL+MUL:0]   px_final;
    logic [DATA_DEPTH_BW+V_SIZE_BW+MUL+MUL:0]   py_final;
    logic [DATA_DEPTH_BW-1+MUL+MUL:0]           pz_final;
    logic [DATA_DEPTH_BW-1:0]                   depth_d6_r;
    logic                                       valid_d6_r;

    //=================================
    // Combinational Logic
    //=================================
    //d0
    assign idx_x_sub_cx = {i_idx_x,{MUL{1'b0}}} - r_cx; //idx_x_sub_cx = i_idx_x - r_cx
    assign idx_y_sub_cy = {i_idx_y,{MUL{1'b0}}} - r_cy; //idx_y_sub_cy = i_idx_y - r_cy

    //d1
    DataDelay
    #(
        .DATA_BW(DATA_DEPTH_BW)
       ,.STAGE(1)
    ) u_depth_d1 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_depth)
        // Output
        ,.o_data(depth_d1_r)
    );

    //d2
    //px_mul = (i_idx_x - r_cx) * i_depth
    DW02_mult_2_stage #(
         .A_width(H_SIZE_BW+MUL+1)
        ,.B_width(DATA_DEPTH_BW)
    ) u_px_mul (
         .A(idx_x_sub_cx_r) //d1
        ,.B(depth_d1_r) //d1
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(px_mul)   //d2
    );

    //py_mul = (i_idx_y - r_cy) * i_depth
    DW02_mult_2_stage #(
         .A_width(V_SIZE_BW+MUL+1)
        ,.B_width(DATA_DEPTH_BW)
    ) u_py_mul (
         .A(idx_y_sub_cy_r) //d1
        ,.B(depth_d1_r) //d1
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(py_mul)   //d2
    );

    //d6
    assign px_final = {px_mul_div,{MUL{1'b0}}};
    assign py_final = {py_mul_div,{MUL{1'b0}}};
    assign pz_final = {{MUL{1'b0}},depth_d6_r,{MUL{1'b0}}};

    assign o_cloud_x = px_final[CLOUD_BW-1:0];  //o_cloud_x = (i_idx_x - r_cx) * i_depth / r_fx
    assign o_cloud_y = py_final[CLOUD_BW-1:0];  //o_cloud_y = (i_idx_y - r_cy) * i_depth / r_fy
    assign o_cloud_z = pz_final[CLOUD_BW-1:0];  //o_cloud_z = i_depth
    assign o_valid = valid_d6_r;

    //px_mul_div = (i_idx_x - r_cx) * i_depth / r_fx
    DW_div_pipe #(
         .a_width(DATA_DEPTH_BW+H_SIZE_BW+MUL+1)
        ,.b_width(FX_BW)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(5)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_px_div (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a(px_mul) //d2
        ,.b(r_fx)
        ,.quotient(px_mul_div)  //d6
        ,.remainder()
        ,.divide_by_0()
    );

    //py_mul_div = (i_idx_y - r_cy) * i_depth / r_fy
    DW_div_pipe #(
         .a_width(DATA_DEPTH_BW+V_SIZE_BW+MUL+1)
        ,.b_width(FY_BW)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(5)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_py_div (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a(py_mul) //d2
        ,.b(r_fy)
        ,.quotient(py_mul_div)  //d6
        ,.remainder()
        ,.divide_by_0()
    );

    DataDelay
    #(
        .DATA_BW(DATA_DEPTH_BW)
       ,.STAGE(5)
    ) u_depth_d6 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(depth_d1_r)
        // Output
        ,.o_data(depth_d6_r)
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(6)
    ) u_valid_d6 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_valid)
        // Output
        ,.o_data(valid_d6_r)
    );

    //===================
    //    Sequential
    //===================
    //d1
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)      idx_x_sub_cx_r <= '0;
        else if (i_valid)  idx_x_sub_cx_r <= idx_x_sub_cx;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)      idx_y_sub_cy_r <= '0;
        else if (i_valid)  idx_y_sub_cy_r <= idx_y_sub_cy;
    end

endmodule
