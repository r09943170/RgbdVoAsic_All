// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023

//17T
module normalUnitization
    import RgbdVoConfigPk::*;
#(
)(
    // input
     input                            i_clk
    ,input                            i_rst_n
    ,input                            i_valid
    ,input        [CLOUD_BW+CLOUD_BW-MUL-1:0]      i_normal_x
    ,input        [CLOUD_BW+CLOUD_BW-MUL-1:0]      i_normal_y
    ,input        [CLOUD_BW+CLOUD_BW-MUL-1:0]      i_normal_z
    // Output
    ,output logic                     o_valid
    ,output logic [CLOUD_BW-1:0]      o_unit_normal_x
    ,output logic [CLOUD_BW-1:0]      o_unit_normal_y
    ,output logic [CLOUD_BW-1:0]      o_unit_normal_z
);

    //=================================
    // Signal Declaration
    //=================================
    //d1
    logic [CLOUD_BW+CLOUD_BW-MUL+CLOUD_BW+CLOUD_BW-MUL-1:0] n_x_s;
    logic [CLOUD_BW+CLOUD_BW-MUL+CLOUD_BW+CLOUD_BW-MUL-1:0] n_y_s;
    logic [CLOUD_BW+CLOUD_BW-MUL+CLOUD_BW+CLOUD_BW-MUL-1:0] n_z_s;
    logic [CLOUD_BW+CLOUD_BW-MUL+CLOUD_BW+CLOUD_BW-MUL+1:0] norm_s;

    //d10
    logic [CLOUD_BW+CLOUD_BW-MUL:0]                         norm_tmp;
    logic [CLOUD_BW+CLOUD_BW-MUL:0]                         norm;

    logic [CLOUD_BW+CLOUD_BW-MUL-1:0]                       n_x_d10;
    logic [CLOUD_BW+CLOUD_BW-MUL-1:0]                       n_y_d10;
    logic [CLOUD_BW+CLOUD_BW-MUL-1:0]                       n_z_d10;

    //d17
    logic [CLOUD_BW+CLOUD_BW-MUL+MUL-1:0]                   unit_normal_x;
    logic [CLOUD_BW+CLOUD_BW-MUL+MUL-1:0]                   unit_normal_y;
    logic [CLOUD_BW+CLOUD_BW-MUL+MUL-1:0]                   unit_normal_z;

    logic [CLOUD_BW+CLOUD_BW-MUL:0]                         norm_d7;
    
    logic                                                   valid_d17;
    //=================================
    // Combinational Logic
    //=================================
    //d1
    assign norm_s = n_x_s + n_y_s + n_z_s;

    //1T
    //n_x_s = i_normal_x * i_normal_x
    DW02_mult_2_stage #(
         .A_width(CLOUD_BW+CLOUD_BW-MUL)
        ,.B_width(CLOUD_BW+CLOUD_BW-MUL)
    ) u_n_x_s (
         .A($signed(i_normal_x))
        ,.B($signed(i_normal_x))
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(n_x_s)
    );

    //n_y_s = i_normal_y * i_normal_y
    DW02_mult_2_stage #(
         .A_width(CLOUD_BW+CLOUD_BW-MUL)
        ,.B_width(CLOUD_BW+CLOUD_BW-MUL)
    ) u_n_y_s (
         .A($signed(i_normal_y))
        ,.B($signed(i_normal_y))
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(n_y_s)
    );

    //n_z_s = i_normal_z * i_normal_z
    DW02_mult_2_stage #(
         .A_width(CLOUD_BW+CLOUD_BW-MUL)
        ,.B_width(CLOUD_BW+CLOUD_BW-MUL)
    ) u_n_z_s (
         .A($signed(i_normal_z))
        ,.B($signed(i_normal_z))
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(n_z_s)
    );
    
    //d10
    assign norm = (norm_tmp == 0) ? {(CLOUD_BW){1'b1}} : norm_tmp;

    //9T
    //norm = sqrt(norm_s)
    DW_sqrt_pipe #(
         .width(CLOUD_BW+CLOUD_BW-MUL+CLOUD_BW+CLOUD_BW-MUL+2)
        ,.tc_mode(1)
        ,.num_stages(10)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_sqrt (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a(norm_s) //d1
        ,.root(norm_tmp)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW+CLOUD_BW-MUL)
       ,.STAGE(10)
    ) u_n_x_d10 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_normal_x)
        // Output
        ,.o_data(n_x_d10)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW+CLOUD_BW-MUL)
       ,.STAGE(10)
    ) u_n_y_d10 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_normal_y)
        // Output
        ,.o_data(n_y_d10)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW+CLOUD_BW-MUL)
       ,.STAGE(10)
    ) u_n_z_d10 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_normal_z)
        // Output
        ,.o_data(n_z_d10)
    );

    //d17
    assign o_valid = valid_d17;
    assign o_unit_normal_x = (norm_d7 == {(CLOUD_BW){1'b1}}) ? '0 : unit_normal_x[CLOUD_BW-1:0];
    assign o_unit_normal_y = (norm_d7 == {(CLOUD_BW){1'b1}}) ? '0 : unit_normal_y[CLOUD_BW-1:0];
    assign o_unit_normal_z = (norm_d7 == {(CLOUD_BW){1'b1}}) ? '0 : unit_normal_z[CLOUD_BW-1:0];
    
    //7T
    //unit_normal_x = n_x_d3 / norm
    DW_div_pipe #(
         .a_width(CLOUD_BW+CLOUD_BW-MUL+MUL)
        ,.b_width(CLOUD_BW+CLOUD_BW-MUL+1)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(8)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_unit_normal_x (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a($signed({n_x_d10,{MUL{1'b0}}})) //d10
        ,.b(norm)   //d10
        ,.quotient(unit_normal_x)
        ,.remainder()
        ,.divide_by_0()
    );

    //unit_normal_y = n_y_d3 / norm
    DW_div_pipe #(
         .a_width(CLOUD_BW+CLOUD_BW-MUL+MUL)
        ,.b_width(CLOUD_BW+CLOUD_BW-MUL+1)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(8)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_unit_normal_y (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a($signed({n_y_d10,{MUL{1'b0}}})) //d10
        ,.b(norm)   //d10
        ,.quotient(unit_normal_y)
        ,.remainder()
        ,.divide_by_0()
    );

    //unit_normal_z = n_z_d3 / norm
    DW_div_pipe #(
         .a_width(CLOUD_BW+CLOUD_BW-MUL+MUL)
        ,.b_width(CLOUD_BW+CLOUD_BW-MUL+1)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(8)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_unit_normal_z (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a($signed({n_z_d10,{MUL{1'b0}}})) //d10
        ,.b(norm)   //d10
        ,.quotient(unit_normal_z)
        ,.remainder()
        ,.divide_by_0()
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW+CLOUD_BW-MUL+1)
       ,.STAGE(7)
    ) u_norm_d7 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(norm)
        // Output
        ,.o_data(norm_d7)
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(17)
    ) u_valid_d17 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_valid)
        // Output
        ,.o_data(valid_d17)
    );

    //===================
    //    Sequential
    //===================


endmodule

