// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023

module CalcRgbdLsmMatrices
    import RgbdVoConfigPk::*;
#(
)(  
    //input
     input                            i_clk
    ,input                            i_rst_n
    ,input                            i_frame_start
    ,input                            i_frame_end
    ,input                            i_valid
    ,input                            i_corresps_valid
    ,input        [H_SIZE_BW-1:0]     i_u0
    ,input        [V_SIZE_BW-1:0]     i_v0
    ,input        [DATA_DEPTH_BW-1:0] i_d0
    ,input        [DATA_RGB_BW-1:0]   i_Rgb_0
    ,input        [DATA_RGB_BW-1:0]   i_Rgb_1
    ,input        [DATA_RGB_BW:0]     dI_dx_1
    ,input        [DATA_RGB_BW:0]     dI_dy_1
    ,input        [DATA_RGB_BW:0]     i_sigma_rgb
    ,input                            i_update_done
    ,input        [POSE_BW-1:0]       i_pose [12]
    // Register
    ,input        [FX_BW-1:0]         r_fx  //FX_BW = 10+24+1(+24 for MUL; +1 for sign)
    ,input        [FY_BW-1:0]         r_fy  //FY_BW = FX_BW
    ,input        [CX_BW-1:0]         r_cx  //CX_BW = FX_BW
    ,input        [CY_BW-1:0]         r_cy  //CY_BW = FX_BW
    //output
    ,output logic                     o_frame_start
    ,output logic                     o_frame_end
    ,output logic                     o_valid
    ,output logic                     o_corresps_valid
    ,output logic [ID_COE_BW-1:0]     o_A0
    ,output logic [ID_COE_BW-1:0]     o_A1
    ,output logic [ID_COE_BW-1:0]     o_A2
    ,output logic [ID_COE_BW-1:0]     o_A3
    ,output logic [ID_COE_BW-1:0]     o_A4
    ,output logic [ID_COE_BW-1:0]     o_A5
    ,output logic [ID_COE_BW-1:0]     o_diff_div_w
    ,output logic [H_SIZE_BW+V_SIZE_BW+2*DATA_RGB_BW+1:0] o_sigma_s_rgbd
    ,output logic [H_SIZE_BW+V_SIZE_BW-1:0] o_corresp_count
);

    //=================================
    // Signal Declaration
    //=================================
    //d0
    logic                     valid_work;
    logic [H_SIZE_BW+V_SIZE_BW-1:0] corresp_count;
    logic [DATA_RGB_BW:0]     diff_w;

    //d1
    logic [DATA_RGB_BW:0]     diff_r;

    logic [DATA_RGB_BW:0]     diff_abs_w;

    //d2
    logic [DATA_RGB_BW:0]     w_w;
    logic [H_SIZE_BW+V_SIZE_BW+2*DATA_RGB_BW+1:0]     sum_of_diff_squr_w;

    logic [2*DATA_RGB_BW+1:0] diff_squr;

    logic                     valid_work_d2;

    logic [DATA_RGB_BW:0]     diff_abs_r;

    //d3
    logic [DATA_RGB_BW:0]     w_r;
    logic [H_SIZE_BW+V_SIZE_BW+2*DATA_RGB_BW+1:0]     sum_of_diff_squr_r;

    //d6
    logic                     valid_p0;
    logic [CLOUD_BW-1:0]      p0_x;
    logic [CLOUD_BW-1:0]      p0_y;
    logic [CLOUD_BW-1:0]      p0_z;

    //d9
    logic [DATA_RGB_BW:0]     w_d9;

    logic [DATA_RGB_BW:0]     w_diff_div_w;

    logic [DATA_RGB_BW:0]     dI_dx_1_d9;
    logic [DATA_RGB_BW:0]     dI_dy_1_d9;

    logic [DATA_RGB_BW:0]     diff_d9;

    logic                     valid_tp0;
    logic [CLOUD_BW-1:0]      tp0_x;
    logic [CLOUD_BW-1:0]      tp0_y;
    logic [CLOUD_BW-1:0]      tp0_z;

    //d10
    logic [FX_BW+DATA_RGB_BW:0] tmp_v0_tmp;
    logic [FY_BW+DATA_RGB_BW:0] tmp_v1_tmp;
    logic [CLOUD_BW+DATA_RGB_BW:0] zw;

    logic [CLOUD_BW+DATA_RGB_BW:0] zw_tmp_v0_div;
    logic [CLOUD_BW+DATA_RGB_BW:0] zw_tmp_v1_div;

    //d12
    logic [DATA_RGB_BW+MUL:0] diff_div_w;

    //d16
    logic [FX_BW+DATA_RGB_BW+1+MUL-3-1:0] tmp_v0_div;
    logic [FY_BW+DATA_RGB_BW+1+MUL-3-1:0] tmp_v1_div;
    logic [MUL-1:0] tmp_v0;
    logic [MUL-1:0] tmp_v1;

    logic [CLOUD_BW-1:0]      tp0_x_d16;
    logic [CLOUD_BW-1:0]      tp0_y_d16;

    //d17
    logic [CLOUD_BW+MUL-1:0]  tmp_v2_1;
    logic [CLOUD_BW+MUL-1:0]  tmp_v2_2;

    logic [CLOUD_BW+MUL-1:0]  tmp_v2_tmp_w;

    //d18
    logic [CLOUD_BW+MUL-1:0]  tmp_v2_tmp_r;
    logic [CLOUD_BW-1:0]      tp0_z_d18;

    //d24
    logic [CLOUD_BW+MUL-1:0]  tmp_v2_tmp;
    logic [MUL-1:0]           tmp_v2;

    logic [CLOUD_BW-1:0]      tp0_z_d24;
    logic [CLOUD_BW-1:0]      tp0_x_d24;
    logic [CLOUD_BW-1:0]      tp0_y_d24;
    logic [MUL-1:0]           tmp_v0_d24;
    logic [MUL-1:0]           tmp_v1_d24;

    //d25
    logic [CLOUD_BW+MUL-1:0]   A0_1;
    logic [CLOUD_BW+MUL-1:0]   A0_2;
    logic [CLOUD_BW+MUL-1:0]   A1_1;
    logic [CLOUD_BW+MUL-1:0]   A1_2;
    logic [CLOUD_BW+MUL-1:0]   A2_1;
    logic [CLOUD_BW+MUL-1:0]   A2_2;

    logic [MUL-1:0]            tmp_v0_d25;
    logic [MUL-1:0]            tmp_v1_d25;
    logic [MUL-1:0]            tmp_v2_d25;

    logic [CLOUD_BW+MUL-1:0]   A0_w;
    logic [CLOUD_BW+MUL-1:0]   A1_w;
    logic [CLOUD_BW+MUL-1:0]   A2_w;
    logic [MUL-1:0]            A3_w;
    logic [MUL-1:0]            A4_w;
    logic [MUL-1:0]            A5_w;

    //d26
    logic                     frame_start_d26;
    logic                     frame_end_d26;
    logic                     valid_d26;
    logic                     corresps_valid_d26;
    logic [ID_COE_BW-1:0]     A0_r;
    logic [ID_COE_BW-1:0]     A1_r;
    logic [ID_COE_BW-1:0]     A2_r;
    logic [ID_COE_BW-1:0]     A3_r;
    logic [ID_COE_BW-1:0]     A4_r;
    logic [ID_COE_BW-1:0]     A5_r;
    logic [DATA_RGB_BW+MUL:0] diff_div_w_d26;
    

    //=================================
    // Combinational Logic
    //=================================
    //d0
    assign valid_work = i_valid && i_corresps_valid;
    assign diff_w = i_Rgb_0 - i_Rgb_1;

    //d1
    assign diff_abs_w = (diff_r[DATA_RGB_BW]) ? -diff_r : diff_r;

    //d2
    assign w_w = i_sigma_rgb + diff_abs_r;
    assign sum_of_diff_squr_w = (valid_work_d2) ? (sum_of_diff_squr_r + diff_squr) : (sum_of_diff_squr_r);

    DW02_mult_2_stage #(
         .A_width(DATA_RGB_BW+1)
        ,.B_width(DATA_RGB_BW+1)
    ) u_diff_squr (
         .A(diff_r)    //d1
        ,.B(diff_r)    //d1
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(diff_squr)    //d2
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(2)
    ) u_valid_work_d2 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(valid_work)    //d0
        // Output
        ,.o_data(valid_work_d2) //d2
    );

    //d6
    //6T
    //input u0,v0,d0; output p0_x, p0_y, p0_z
    Idx2Cloud u_idx2cloud_0 (
        // input
         .i_clk   ( i_clk )
        ,.i_rst_n ( i_rst_n )
        ,.i_valid ( valid_work )    //d0
        ,.i_idx_x ( i_u0 )  //d0
        ,.i_idx_y ( i_v0 )  //d0
        ,.i_depth ( i_d0 )  //d0
        // Register
        ,.r_fx     ( r_fx )
        ,.r_fy     ( r_fy )
        ,.r_cx     ( r_cx )
        ,.r_cy     ( r_cy )
        // Output
        ,.o_valid   (valid_p0)
        ,.o_cloud_x (p0_x)  //d6
        ,.o_cloud_y (p0_y)  //d6
        ,.o_cloud_z (p0_z)  //d6
    );

    //d9
    assign w_diff_div_w = (w_d9 == 0) ? 1 : w_d9;

    //3T
    //input p0_x, p0_y, p0_z, Rt[12]; output tp0_x, tp0_y, tp0_z
    TransMat u_transmat(
        // input
         .i_clk      ( i_clk )
        ,.i_rst_n    ( i_rst_n)
        ,.i_valid    ( valid_p0 )   //d6
        ,.i_cloud_x  ( p0_x )   //d6
        ,.i_cloud_y  ( p0_y )   //d6
        ,.i_cloud_z  ( p0_z )   //d6
        ,.i_pose     ( i_pose )    //Rt[12] 3x4
        // Output
        ,.o_valid    ( valid_tp0 )
        ,.o_cloud_x  ( tp0_x )  //d9
        ,.o_cloud_y  ( tp0_y )  //d9
        ,.o_cloud_z  ( tp0_z )  //d9
    );

    DataDelay
    #(
        .DATA_BW(DATA_RGB_BW+1)
       ,.STAGE(9)
    ) u_dI_dx_1_d9 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(dI_dx_1)   //d0
        // Output
        ,.o_data(dI_dx_1_d9)    //d9
    );

    DataDelay
    #(
        .DATA_BW(DATA_RGB_BW+1)
       ,.STAGE(9)
    ) u_dI_dy_1_d9 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(dI_dy_1)   //d0
        // Output
        ,.o_data(dI_dy_1_d9)    //d9
    );

    DataDelay
    #(
        .DATA_BW(DATA_RGB_BW+1)
       ,.STAGE(6)
    ) u_w_d9 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(w_r)   //d3
        // Output
        ,.o_data(w_d9)  //d9
    );

    DataDelay
    #(
        .DATA_BW(DATA_RGB_BW+1)
       ,.STAGE(8)
    ) u_diff_d9 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(diff_r)    //d1
        // Output
        ,.o_data(diff_d9)   //d9
    );

    //d10
    assign zw_tmp_v0_div = (zw == 0) ? 1 : zw;
    assign zw_tmp_v1_div = (zw == 0) ? 1 : zw;

    DW02_mult_2_stage #(
         .A_width(DATA_RGB_BW+1)
        ,.B_width(FX_BW)
    ) u_tmp_v0_tmp (
         .A(dI_dx_1_d9) //d9
        ,.B(r_fx)
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(tmp_v0_tmp)   //d10
    );

    DW02_mult_2_stage #(
         .A_width(DATA_RGB_BW+1)
        ,.B_width(FY_BW)
    ) u_tmp_v1_tmp (
         .A(dI_dy_1_d9) //d9
        ,.B(r_fy)
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(tmp_v1_tmp)   //d10
    );

    DW02_mult_2_stage #(
         .A_width(DATA_RGB_BW+1)
        ,.B_width(CLOUD_BW)
    ) u_zw (
         .A(w_d9)    //d9
        ,.B(tp0_z)  //d9
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(zw)   //d10
    );

    //d12
    DW_div_pipe #(
         .a_width(DATA_RGB_BW+1+MUL)    //33 bits
        ,.b_width(DATA_RGB_BW+1)    //9 bits
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(4)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_diff_div_w (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a({{diff_d9},{MUL{1'b0}}})   //d9
        ,.b(w_diff_div_w)   //d9
        ,.quotient(diff_div_w)  //d12
        ,.remainder()
        ,.divide_by_0()
    );

    //d16
    assign tmp_v0 = tmp_v0_div[MUL-1:0];
    assign tmp_v1 = tmp_v1_div[MUL-1:0];

    DW_div_pipe #(
         .a_width(FX_BW+DATA_RGB_BW+1+MUL-3)    //65 bits
        ,.b_width(CLOUD_BW+DATA_RGB_BW+1)   //51 bits
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(7)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_tmp_v0 (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a({tmp_v0_tmp,{(MUL-3){1'b0}}})   //d10
        ,.b(zw_tmp_v0_div)  //d10
        ,.quotient(tmp_v0_div)  //d16
        ,.remainder()
        ,.divide_by_0()
    );

    DW_div_pipe #(
         .a_width(FY_BW+DATA_RGB_BW+1+MUL-3)    //65 bits
        ,.b_width(CLOUD_BW+DATA_RGB_BW+1)   //51 bits
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(7)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_tmp_v1 (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a({tmp_v1_tmp,{(MUL-3){1'b0}}})   //d10
        ,.b(zw_tmp_v1_div)  //d10
        ,.quotient(tmp_v1_div)  //d16
        ,.remainder()
        ,.divide_by_0()
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(7)
    ) u_tp0_x_d16 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tp0_x) //d9
        // Output
        ,.o_data(tp0_x_d16)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(7)
    ) u_tp0_y_d16 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tp0_y) //d9
        // Output
        ,.o_data(tp0_y_d16)
    );

    //d17
    assign tmp_v2_tmp_w = 0 - tmp_v2_1 - tmp_v2_2;

    DW02_mult_2_stage #(
         .A_width(MUL)
        ,.B_width(CLOUD_BW)
    ) u_tmp_v2_1 (
         .A(tmp_v0) //d16
        ,.B(tp0_x_d16)  //d16
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(tmp_v2_1) //d17
    );

    DW02_mult_2_stage #(
         .A_width(MUL)
        ,.B_width(CLOUD_BW)
    ) u_tmp_v2_2 (
         .A(tmp_v1) //d16
        ,.B(tp0_y_d16)  //d16
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(tmp_v2_2) //d17
    );

    //d18
    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(9)
    ) u_tp0_z_d18 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tp0_z) //d9
        // Output
        ,.o_data(tp0_z_d18) //d18
    );

    //d24
    assign tmp_v2 = tmp_v2_tmp[MUL-1:0];

    DW_div_pipe #(
         .a_width(CLOUD_BW+MUL) //66 bits
        ,.b_width(CLOUD_BW) //42 bits
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(7)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_tmp_v2_tmp (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a(tmp_v2_tmp_r)   //d18
        ,.b(tp0_z_d18)  //d18
        ,.quotient(tmp_v2_tmp)  //d24
        ,.remainder()
        ,.divide_by_0()
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(6)
    ) u_tp0_z_d24 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tp0_z_d18)
        // Output
        ,.o_data(tp0_z_d24)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(8)
    ) u_tp0_x_d24 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tp0_x_d16)
        // Output
        ,.o_data(tp0_x_d24)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(8)
    ) u_tp0_y_d24 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tp0_y_d16)
        // Output
        ,.o_data(tp0_y_d24)
    );

    DataDelay
    #(
        .DATA_BW(MUL)
       ,.STAGE(8)
    ) u_tmp_v0_d24 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tmp_v0)    //d16
        // Output
        ,.o_data(tmp_v0_d24)
    );

    DataDelay
    #(
        .DATA_BW(MUL)
       ,.STAGE(8)
    ) u_tmp_v1_d24 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tmp_v1)    //d16
        // Output
        ,.o_data(tmp_v1_d24)
    );

    //d25
    assign A0_w = A0_1 - A0_2;
    assign A1_w = A1_1 - A1_2;
    assign A2_w = A2_1 - A2_2;
    assign A3_w = tmp_v0_d25;
    assign A4_w = tmp_v1_d25;
    assign A5_w = tmp_v2_d25;

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(MUL)
    ) u_A0_1 (
         .A(tp0_y_d24)
        ,.B(tmp_v2) //d24
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(A0_1) //d25
    );
    
    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(MUL)
    ) u_A0_2 (
         .A(tp0_z_d24)
        ,.B(tmp_v1_d24)
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(A0_2) //d25
    );

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(MUL)
    ) u_A1_1 (
         .A(tp0_z_d24)
        ,.B(tmp_v0_d24)
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(A1_1) //d25
    );

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(MUL)
    ) u_A1_2 (
         .A(tp0_x_d24)
        ,.B(tmp_v2) //d24
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(A1_2) //d25
    );

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(MUL)
    ) u_A2_1 (
         .A(tp0_x_d24)
        ,.B(tmp_v1_d24)
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(A2_1) //d25
    );

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(MUL)
    ) u_A2_2 (
         .A(tp0_y_d24)
        ,.B(tmp_v0_d24)
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(A2_2) //d25
    );

    DataDelay
    #(
        .DATA_BW(MUL)
       ,.STAGE(1)
    ) u_tmp_v0_d25 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tmp_v0_d24)
        // Output
        ,.o_data(tmp_v0_d25)
    );

    DataDelay
    #(
        .DATA_BW(MUL)
       ,.STAGE(1)
    ) u_tmp_v1_d25 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tmp_v1_d24)
        // Output
        ,.o_data(tmp_v1_d25)
    );

    DataDelay
    #(
        .DATA_BW(MUL)
       ,.STAGE(1)
    ) u_tmp_v2_d25 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tmp_v2)    //d24
        // Output
        ,.o_data(tmp_v2_d25)
    );

    //d26
    assign o_frame_start = frame_start_d26;
    assign o_frame_end = frame_end_d26;
    assign o_valid = valid_d26;
    assign o_corresps_valid = corresps_valid_d26;
    assign o_A0 = A0_r;
    assign o_A1 = A1_r;
    assign o_A2 = A2_r;
    assign o_A3 = A3_r;
    assign o_A4 = A4_r;
    assign o_A5 = A5_r;
    assign o_diff_div_w = {{(ID_COE_BW-DATA_RGB_BW-1-MUL){diff_div_w_d26[DATA_RGB_BW+MUL]}},{diff_div_w_d26}};
    assign o_sigma_s_rgbd = sum_of_diff_squr_r;
    assign o_corresp_count = corresp_count;

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(26)
    ) u_frame_start_d26 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_frame_start)
        // Output
        ,.o_data(frame_start_d26)
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(26)
    ) u_frame_end_d26 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_frame_end)
        // Output
        ,.o_data(frame_end_d26)
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(26)
    ) u_valid_d26 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_valid)
        // Output
        ,.o_data(valid_d26)
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(26)
    ) u_corresps_valid_d26 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_corresps_valid)
        // Output
        ,.o_data(corresps_valid_d26)
    );

    DataDelay
    #(
        .DATA_BW(DATA_RGB_BW+MUL+1)
       ,.STAGE(14)
    ) u_diff_div_w_d26 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(diff_div_w)    //d12
        // Output
        ,.o_data(diff_div_w_d26)
    );

    //===================
    //    Sequential
    //===================
    //d1
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) corresp_count <= 0;
        else if (i_update_done) corresp_count <= 0;
        else if (valid_work) corresp_count <= corresp_count + 1;
        else corresp_count <= corresp_count;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) diff_r <= 0;
        else if (i_update_done) diff_r <= 0;
        else diff_r <= diff_w;
    end

    //d2
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) diff_abs_r <= 0;
        else if (i_update_done) diff_abs_r <= 0;
        else diff_abs_r <= diff_abs_w;
    end

    //d3
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) sum_of_diff_squr_r <= 0;
        else if (i_update_done) sum_of_diff_squr_r <= 0;
        else sum_of_diff_squr_r <= sum_of_diff_squr_w;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) w_r <= 0;
        else if (i_update_done) w_r <= 0;
        else w_r <= w_w;
    end

    //d18
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) tmp_v2_tmp_r <= 0;
        else if (i_update_done) tmp_v2_tmp_r <= 0;
        else tmp_v2_tmp_r <= tmp_v2_tmp_w;
    end

    //d26
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) A0_r <= 0;
        else if (i_update_done) A0_r <= 0;
        else A0_r <= A0_w[ID_COE_BW+MUL-1:MUL];
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) A1_r <= 0;
        else if (i_update_done) A1_r <= 0;
        else A1_r <= A1_w[ID_COE_BW+MUL-1:MUL];
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) A2_r <= 0;
        else if (i_update_done) A2_r <= 0;
        else A2_r <= A2_w[ID_COE_BW+MUL-1:MUL];
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) A3_r <= 0;
        else if (i_update_done) A3_r <= 0;
        // else A3_r <= {{(ID_COE_BW-MUL){A3_w[MUL-1]}},{A3_w}};
        else A3_r <= $signed(A3_w);
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) A4_r <= 0;
        else if (i_update_done) A4_r <= 0;
        // else A4_r <= {{(ID_COE_BW-MUL){A4_w[MUL-1]}},{A4_w}};
        else A4_r <= $signed(A4_w);
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) A5_r <= 0;
        else if (i_update_done) A5_r <= 0;
        // else A5_r <= {{(ID_COE_BW-MUL){A5_w[MUL-1]}},{A5_w}};
        else A5_r <= $signed(A5_w);
    end

endmodule