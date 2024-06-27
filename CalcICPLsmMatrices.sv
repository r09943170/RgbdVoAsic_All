// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023

module CalcICPLsmMatrices
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
    ,input        [H_SIZE_BW-1:0]     i_u1
    ,input        [V_SIZE_BW-1:0]     i_v1
    ,input        [DATA_DEPTH_BW-1:0] i_d1
    ,input        [CLOUD_BW-1:0]      i_n1_x
    ,input        [CLOUD_BW-1:0]      i_n1_y
    ,input        [CLOUD_BW-1:0]      i_n1_z
    ,input        [2*CLOUD_BW-1:0]    i_sigma_icp
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
    ,output logic [4*CLOUD_BW-1:0]    o_sigma_s_icp
    ,output logic [H_SIZE_BW+V_SIZE_BW-1:0] o_corresp_count
);

    //=================================
    // Signal Declaration
    //=================================
    //d0
    logic                     valid_work;
    logic [H_SIZE_BW+V_SIZE_BW-1:0] corresp_count;

    //d6
    logic                     valid_p0;
    logic [CLOUD_BW-1:0]      p0_x;
    logic [CLOUD_BW-1:0]      p0_y;
    logic [CLOUD_BW-1:0]      p0_z;

    logic                     valid_p1;
    logic [CLOUD_BW-1:0]      p1_x;
    logic [CLOUD_BW-1:0]      p1_y;
    logic [CLOUD_BW-1:0]      p1_z;

    //d9
    logic                     valid_tp0;
    logic [CLOUD_BW-1:0]      tp0_x;
    logic [CLOUD_BW-1:0]      tp0_y;
    logic [CLOUD_BW-1:0]      tp0_z;

    logic [CLOUD_BW-1:0]      p1_x_d3;
    logic [CLOUD_BW-1:0]      p1_y_d3;
    logic [CLOUD_BW-1:0]      p1_z_d3;

    logic [CLOUD_BW-1:0]      v_x_w;
    logic [CLOUD_BW-1:0]      v_y_w;
    logic [CLOUD_BW-1:0]      v_z_w;

    //d10
    logic                     valid_work_d10;

    logic [CLOUD_BW-1:0]      v_x_r;
    logic [CLOUD_BW-1:0]      v_y_r;
    logic [CLOUD_BW-1:0]      v_z_r;

    logic [CLOUD_BW-1:0]      tp0_x_d1;
    logic [CLOUD_BW-1:0]      tp0_y_d1;
    logic [CLOUD_BW-1:0]      tp0_z_d1;

    logic [CLOUD_BW-1:0]      n1_x_d10;
    logic [CLOUD_BW-1:0]      n1_y_d10;
    logic [CLOUD_BW-1:0]      n1_z_d10;

    //d11
    logic [2*CLOUD_BW-1:0]    v_x_mul_n1_x;
    logic [2*CLOUD_BW-1:0]    v_y_mul_n1_y;
    logic [2*CLOUD_BW-1:0]    v_z_mul_n1_z;

    logic [2*CLOUD_BW-1:0]    diffs_w;

    logic                     valid_Cross;
    logic [2*CLOUD_BW-1:0]    A0_pre;
    logic [2*CLOUD_BW-1:0]    A1_pre;
    logic [2*CLOUD_BW-1:0]    A2_pre;

    //d12
    logic                     valid_work_d12;

    logic [2*CLOUD_BW-1:0]    diffs_r;
    logic [2*CLOUD_BW-1:0]    diffs_abs;

    logic [2*CLOUD_BW-1:0]    sigma_d12;

    logic [2*CLOUD_BW-1:0]    w_w;

    //d13
    logic                     valid_work_d13;

    logic [4*CLOUD_BW-1:0]    diffs_squr;
    logic [4*CLOUD_BW-1:0]    sigma_next_squr_w;

    logic [CLOUD_BW-1:0]      n1_x_d13;
    logic [CLOUD_BW-1:0]      n1_y_d13;
    logic [CLOUD_BW-1:0]      n1_z_d13;

    logic [2*CLOUD_BW-1:0]    A0_pre_d2;
    logic [2*CLOUD_BW-1:0]    A1_pre_d2;
    logic [2*CLOUD_BW-1:0]    A2_pre_d2;

    logic [2*CLOUD_BW-1:0]    w_r;

    logic [2*CLOUD_BW-1:0]    diffs_r_d1;

    //d14
    logic [4*CLOUD_BW-1:0]    sigma_next_squr_r;

    //d21
    logic [CLOUD_BW+2*MUL-1:0]       A3_result;
    logic [CLOUD_BW+2*MUL-1:0]       A4_result;
    logic [CLOUD_BW+2*MUL-1:0]       A5_result;

    //d23
    logic                     frame_start_d22;
    logic                     frame_end_d22;
    logic                     valid_d22;
    logic                     corresps_valid_d22;

    logic [2*CLOUD_BW-MUL+2*MUL-1:0] A0_result;
    logic [2*CLOUD_BW-MUL+2*MUL-1:0] A1_result;
    logic [2*CLOUD_BW-MUL+2*MUL-1:0] A2_result;
    logic [2*CLOUD_BW+MUL-1:0]       diff_div_w;

    logic [ID_COE_BW-1:0]     A3_result_d2;
    logic [ID_COE_BW-1:0]     A4_result_d2;
    logic [ID_COE_BW-1:0]     A5_result_d2;


    //=================================
    // Combinational Logic
    //=================================
    //d0
    assign valid_work = i_valid && i_corresps_valid;

    //d6
    //6T
    //input u0,v0,d0; output p0_x, p0_y, p0_z
    Idx2Cloud u_idx2cloud_0 (
        // input
         .i_clk   ( i_clk )
        ,.i_rst_n ( i_rst_n )
        ,.i_valid ( valid_work )
        ,.i_idx_x ( i_u0 )
        ,.i_idx_y ( i_v0 )
        ,.i_depth ( i_d0 )
        // Register
        ,.r_fx     ( r_fx )
        ,.r_fy     ( r_fy )
        ,.r_cx     ( r_cx )
        ,.r_cy     ( r_cy )
        // Output
        ,.o_valid   (valid_p0)  //d6
        ,.o_cloud_x (p0_x)  //d6
        ,.o_cloud_y (p0_y)  //d6
        ,.o_cloud_z (p0_z)  //d6
    );

    //input u1,v1,d1; output p1_x, p1_y, p1_z
    Idx2Cloud u_idx2cloud_1 (
        // input
         .i_clk   ( i_clk )
        ,.i_rst_n ( i_rst_n )
        ,.i_valid ( valid_work )
        ,.i_idx_x ( i_u1 )
        ,.i_idx_y ( i_v1 )
        ,.i_depth ( i_d1 )
        // Register
        ,.r_fx     ( r_fx )
        ,.r_fy     ( r_fy )
        ,.r_cx     ( r_cx )
        ,.r_cy     ( r_cy )
        // Output
        ,.o_valid   (valid_p1)  //d6
        ,.o_cloud_x (p1_x)  //d6
        ,.o_cloud_y (p1_y)  //d6
        ,.o_cloud_z (p1_z)  //d6
    );

    //d9
    assign v_x_w = p1_x_d3 - tp0_x;
    assign v_y_w = p1_y_d3 - tp0_y;
    assign v_z_w = p1_z_d3 - tp0_z;

    //3T
    //input p0_x, p0_y, p0_z, Rt[12]; output tp0_x, tp0_y, tp0_z
    TransMat u_transmat(
        // input
         .i_clk      ( i_clk )
        ,.i_rst_n    ( i_rst_n)
        ,.i_valid    ( valid_p0 )
        ,.i_cloud_x  ( p0_x )
        ,.i_cloud_y  ( p0_y )
        ,.i_cloud_z  ( p0_z )
        ,.i_pose     ( i_pose )    //Rt[12] 3x4
        // Output
        ,.o_valid    ( valid_tp0 )
        ,.o_cloud_x  ( tp0_x )
        ,.o_cloud_y  ( tp0_y )
        ,.o_cloud_z  ( tp0_z )
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(3)
    ) u_p1_x_d3 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(p1_x)
        // Output
        ,.o_data(p1_x_d3)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(3)
    ) u_p1_y_d3 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(p1_y)
        // Output
        ,.o_data(p1_y_d3)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(3)
    ) u_p1_z_d3 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(p1_z)
        // Output
        ,.o_data(p1_z_d3)
    );

    //d10
    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(10)
    ) u_valid_work_d10 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(valid_work)
        // Output
        ,.o_data(valid_work_d10)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(1)
    ) u_tp0_x_d1 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tp0_x)
        // Output
        ,.o_data(tp0_x_d1)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(1)
    ) u_tp0_y_d1 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tp0_y)
        // Output
        ,.o_data(tp0_y_d1)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(1)
    ) u_tp0_z_d1 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(tp0_z)
        // Output
        ,.o_data(tp0_z_d1)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(10)
    ) u_n1_x_d10 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_n1_x)
        // Output
        ,.o_data(n1_x_d10)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(10)
    ) u_n1_y_d10 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_n1_y)
        // Output
        ,.o_data(n1_y_d10)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(10)
    ) u_n1_z_d10 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_n1_z)
        // Output
        ,.o_data(n1_z_d10)
    );

    //d11
    assign diffs_w = v_x_mul_n1_x + v_y_mul_n1_y + v_z_mul_n1_z;

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(CLOUD_BW)
    ) u_v_x_mul_n1_x (
         .A(v_x_r)  //d10
        ,.B(n1_x_d10)   //d10
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(v_x_mul_n1_x)
    );

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(CLOUD_BW)
    ) u_v_y_mul_n1_y (
         .A(v_y_r)
        ,.B(n1_y_d10)
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(v_y_mul_n1_y)
    );

    DW02_mult_2_stage #(
         .A_width(CLOUD_BW)
        ,.B_width(CLOUD_BW)
    ) u_v_z_mul_n1_z (
         .A(v_z_r)
        ,.B(n1_z_d10)
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(v_z_mul_n1_z)
    );

        //1T
    OuterProduct u_OuterProduct (
        // input
         .i_clk     ( i_clk )
        ,.i_rst_n   ( i_rst_n)
        ,.i_valid   ( valid_work_d10 )
        ,.i_p0_x    ( tp0_x_d1 )
        ,.i_p0_y    ( tp0_y_d1 )
        ,.i_p0_z    ( tp0_z_d1 )
        ,.i_p1_x    ( n1_x_d10 )
        ,.i_p1_y    ( n1_y_d10 )
        ,.i_p1_z    ( n1_z_d10 )
        // Output
        ,.o_valid     ( valid_Cross )
        ,.o_normal_x  ( A0_pre )
        ,.o_normal_y  ( A1_pre )
        ,.o_normal_z  ( A2_pre )
    );

    //d12
    assign w_w = sigma_d12 + diffs_abs;

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(2)
    ) u_valid_work_d12 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(valid_work_d10)
        // Output
        ,.o_data(valid_work_d12)
    );

    DataDelay
    #(
        .DATA_BW(2*CLOUD_BW)
       ,.STAGE(12)
    ) u_sigma_d12 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_sigma_icp)
        // Output
        ,.o_data(sigma_d12)
    );

    //d13
    assign sigma_next_squr_w = sigma_next_squr_r + diffs_squr;

    DW02_mult_2_stage #(
         .A_width(2*CLOUD_BW)
        ,.B_width(2*CLOUD_BW)
    ) u_diffs_squr (
         .A(diffs_r)    //d12
        ,.B(diffs_r)    //d12
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(diffs_squr)   //d13
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(1)
    ) u_valid_work_d13 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(valid_work_d12)
        // Output
        ,.o_data(valid_work_d13)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(3)
    ) u_n1_x_d13 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(n1_x_d10)
        // Output
        ,.o_data(n1_x_d13)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(3)
    ) u_n1_y_d13 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(n1_y_d10)
        // Output
        ,.o_data(n1_y_d13)
    );

    DataDelay
    #(
        .DATA_BW(CLOUD_BW)
       ,.STAGE(3)
    ) u_n1_z_d13 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(n1_z_d10)
        // Output
        ,.o_data(n1_z_d13)
    );

    DataDelay
    #(
        .DATA_BW(2*CLOUD_BW)
       ,.STAGE(2)
    ) u_A0_pre_d2 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(A0_pre)    //d11
        // Output
        ,.o_data(A0_pre_d2) //d13
    );

    DataDelay
    #(
        .DATA_BW(2*CLOUD_BW)
       ,.STAGE(2)
    ) u_A1_pre_d2 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(A1_pre)    //d11
        // Output
        ,.o_data(A1_pre_d2) //d13
    );

    DataDelay
    #(
        .DATA_BW(2*CLOUD_BW)
       ,.STAGE(2)
    ) u_A2_pre_d2 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(A2_pre)    //d11
        // Output
        ,.o_data(A2_pre_d2) //d13
    );

    DataDelay
    #(
        .DATA_BW(2*CLOUD_BW)
       ,.STAGE(1)
    ) u_diffs_r_d1 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(diffs_r)   //d12
        // Output
        ,.o_data(diffs_r_d1)    //d13
    );

    //d20
    DW_div_pipe #(
         .a_width(CLOUD_BW+2*MUL)   //90 bits
        ,.b_width(2*CLOUD_BW)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(8)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_A3 (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a({n1_x_d13,{(2*MUL){1'b0}}}) //d13
        ,.b(w_r)    //d13
        ,.quotient(A3_result)   //d20
        ,.remainder()
        ,.divide_by_0()
    );

    DW_div_pipe #(
         .a_width(CLOUD_BW+2*MUL)   //90 bits
        ,.b_width(2*CLOUD_BW)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(8)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_A4 (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a({n1_y_d13,{(2*MUL){1'b0}}}) //d13
        ,.b(w_r)    //d13
        ,.quotient(A4_result)   //d20
        ,.remainder()
        ,.divide_by_0()
    );

    DW_div_pipe #(
         .a_width(CLOUD_BW+2*MUL)   //90 bits
        ,.b_width(2*CLOUD_BW)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(8)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_A5 (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a({n1_z_d13,{(2*MUL){1'b0}}}) //d13
        ,.b(w_r)    //d13
        ,.quotient(A5_result)   //d20
        ,.remainder()
        ,.divide_by_0()
    );

    //d22
    assign o_frame_start    = frame_start_d22;
    assign o_frame_end      = frame_end_d22;
    assign o_valid          = valid_d22;
    assign o_corresps_valid = corresps_valid_d22;
    assign o_A0 = A0_result[ID_COE_BW-1:0];
    assign o_A1 = A1_result[ID_COE_BW-1:0];
    assign o_A2 = A2_result[ID_COE_BW-1:0];
    assign o_A3 = A3_result_d2;
    assign o_A4 = A4_result_d2;
    assign o_A5 = A5_result_d2;
    assign o_diff_div_w = diff_div_w[ID_COE_BW-1:0];
    assign o_corresp_count = corresp_count;
    assign o_sigma_s_icp = sigma_next_squr_r;

    DW_div_pipe #(
         .a_width(2*CLOUD_BW-MUL+2*MUL) //108 bits
        ,.b_width(2*CLOUD_BW)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(10)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_A0 (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a({A0_pre_d2,{MUL{1'b0}}})    //d13
        ,.b(w_r)    //d13
        ,.quotient(A0_result)   //d22
        ,.remainder()
        ,.divide_by_0()
    );

    DW_div_pipe #(
         .a_width(2*CLOUD_BW-MUL+2*MUL) //108 bits
        ,.b_width(2*CLOUD_BW)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(10)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_A1 (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a({A1_pre_d2,{MUL{1'b0}}})    //d13
        ,.b(w_r)    //d13
        ,.quotient(A1_result)   //d22
        ,.remainder()
        ,.divide_by_0()
    );

    DW_div_pipe #(
         .a_width(2*CLOUD_BW-MUL+2*MUL) //108 bits
        ,.b_width(2*CLOUD_BW)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(10)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_A2 (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a({A2_pre_d2,{MUL{1'b0}}})    //d13
        ,.b(w_r)    //d13
        ,.quotient(A2_result)   //d22
        ,.remainder()
        ,.divide_by_0()
    );

    DW_div_pipe #(
         .a_width(2*CLOUD_BW+MUL)   //108 bits
        ,.b_width(2*CLOUD_BW)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(10)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_diff_div_w (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a({diffs_r_d1,{MUL{1'b0}}})   //d13
        ,.b(w_r)    //d13
        ,.quotient(diff_div_w)  //d22
        ,.remainder()
        ,.divide_by_0()
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(22)
    ) u_frame_start_d22 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_frame_start)
        // Output
        ,.o_data(frame_start_d22)
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(22)
    ) u_frame_end_d22 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_frame_end)
        // Output
        ,.o_data(frame_end_d22)
    );
    
    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(22)
    ) u_valid_d22 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_valid)
        // Output
        ,.o_data(valid_d22)
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(22)
    ) u_corresps_valid_d22 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_corresps_valid)
        // Output
        ,.o_data(corresps_valid_d22)
    );

    DataDelay
    #(
        .DATA_BW(ID_COE_BW)
       ,.STAGE(2)
    ) u_A3_result_d2 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(A3_result[ID_COE_BW-1:0])  //d20
        // Output
        ,.o_data(A3_result_d2)  //d22
    );

    DataDelay
    #(
        .DATA_BW(ID_COE_BW)
       ,.STAGE(2)
    ) u_A4_result_d2 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(A4_result[ID_COE_BW-1:0])  //d20
        // Output
        ,.o_data(A4_result_d2)  //d22
    );

    DataDelay
    #(
        .DATA_BW(ID_COE_BW)
       ,.STAGE(2)
    ) u_A5_result_d2 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(A5_result[ID_COE_BW-1:0])  //d20
        // Output
        ,.o_data(A5_result_d2)  //d22
    );

    //===================
    //    Sequential
    //===================
    //d0
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) corresp_count <= 0;
        else if (i_update_done) corresp_count <= 0;
        else if (valid_work) corresp_count <= corresp_count + 1;
        else corresp_count <= corresp_count;
    end

    //d10
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) v_x_r <= 0;
        else if (i_update_done) v_x_r <= 0;
        else v_x_r <= v_x_w;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) v_y_r <= 0;
        else if (i_update_done) v_y_r <= 0;
        else v_y_r <= v_y_w;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) v_z_r <= 0;
        else if (i_update_done) v_z_r <= 0;
        else v_z_r <= v_z_w;
    end

    //d12
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) diffs_r <= 0;
        else if (i_update_done) diffs_r <= 0;
        else diffs_r <= diffs_w;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) diffs_abs <= 0;
        else if (i_update_done) diffs_abs <= 0;
        else if (diffs_w[2*CLOUD_BW-1] == 0) diffs_abs <= diffs_w;
        else diffs_abs <= -diffs_w;
    end

    //d13
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) w_r <= 1;
        else if (i_update_done) w_r <= 1;
        else if (valid_work_d12) w_r <= (w_w == 0) ? 1 : w_w;
        else w_r <= w_r;
    end

    //d14
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) sigma_next_squr_r <= 0;
        else if (i_update_done) sigma_next_squr_r <= 0;
        else if (valid_work_d13) sigma_next_squr_r <= sigma_next_squr_w;
        else sigma_next_squr_r <= sigma_next_squr_r;
    end

endmodule