// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023

//22T
module IndirectCalc
    import RgbdVoConfigPk::*;
#(
)(
    // input
     input                            i_clk
    ,input                            i_rst_n
    ,input                            i_frame_start
    ,input                            i_frame_end
    ,input                            i_valid
    ,input        [H_SIZE_BW-1:0]     i_idx0_x
    ,input        [V_SIZE_BW-1:0]     i_idx0_y
    ,input        [DATA_DEPTH_BW-1:0] i_depth0
    ,input        [H_SIZE_BW-1:0]     i_idx1_x
    ,input        [V_SIZE_BW-1:0]     i_idx1_y
    ,input        [POSE_BW-1:0]       i_pose [12]
    // Register
    ,input        [FX_BW-1:0]         r_fx
    ,input        [FY_BW-1:0]         r_fy
    ,input        [CX_BW-1:0]         r_cx
    ,input        [CY_BW-1:0]         r_cy
    // Output
    ,output logic                     o_frame_start
    ,output logic                     o_frame_end
    ,output logic                     o_valid
    ,output logic [ID_COE_BW-1:0]     o_Ax_0
    ,output logic [ID_COE_BW-1:0]     o_Ax_1
    ,output logic [ID_COE_BW-1:0]     o_Ax_2
    ,output logic [ID_COE_BW-1:0]     o_Ax_3
    ,output logic [ID_COE_BW-1:0]     o_Ax_4
    ,output logic [ID_COE_BW-1:0]     o_Ax_5
    ,output logic [ID_COE_BW-1:0]     o_Ay_0
    ,output logic [ID_COE_BW-1:0]     o_Ay_1
    ,output logic [ID_COE_BW-1:0]     o_Ay_2
    ,output logic [ID_COE_BW-1:0]     o_Ay_3
    ,output logic [ID_COE_BW-1:0]     o_Ay_4
    ,output logic [ID_COE_BW-1:0]     o_Ay_5
    ,output logic [ID_COE_BW-1:0]     o_diffs_x
    ,output logic [ID_COE_BW-1:0]     o_diffs_y
);

    //=================================
    // Signal Declaration
    //=================================
    //d6
    logic                     cloud_valid;
    logic [CLOUD_BW-1:0]      cloud_x;
    logic [CLOUD_BW-1:0]      cloud_y;
    logic [CLOUD_BW-1:0]      cloud_z;

    //d9
    logic                     trans_valid;
    logic [CLOUD_BW-1:0]      trans_x;
    logic [CLOUD_BW-1:0]      trans_y;
    logic [CLOUD_BW-1:0]      trans_z;

    //d17
    logic                     proj_valid;
    logic [H_SIZE_BW-1:0]     proj_x;
    logic [V_SIZE_BW-1:0]     proj_y;
    logic [H_SIZE_BW-1:0]     idx1_x_dly;
    logic [V_SIZE_BW-1:0]     idx1_y_dly;

    //d18
    logic [H_SIZE_BW:0]       diffs_x_r;
    logic [V_SIZE_BW:0]       diffs_y_r;

    //d22
    logic [H_SIZE_BW:0]       diffs_x_r_d4;
    logic [V_SIZE_BW:0]       diffs_y_r_d4;

    //=================================
    // Combinational Logic
    //=================================
    //d6
    //6T
    Idx2Cloud u_idx2cloud (
        // input
         .i_clk   ( i_clk )
        ,.i_rst_n ( i_rst_n )
        ,.i_valid ( i_valid )
        ,.i_idx_x ( i_idx0_x )
        ,.i_idx_y ( i_idx0_y )
        ,.i_depth ( i_depth0 )
        // Register
        ,.r_fx     ( r_fx )
        ,.r_fy     ( r_fy )
        ,.r_cx     ( r_cx )
        ,.r_cy     ( r_cy )
        // Output
        ,.o_valid   (cloud_valid)
        ,.o_cloud_x (cloud_x)
        ,.o_cloud_y (cloud_y)
        ,.o_cloud_z (cloud_z)
    );

    //d9
    //3T
    // [P'] = [R|t][P]  --  p.166(7.37)
    TransMat u_transmat(
        // input
         .i_clk      ( i_clk )
        ,.i_rst_n    ( i_rst_n)
        ,.i_valid    ( cloud_valid )
        ,.i_cloud_x  ( cloud_x )
        ,.i_cloud_y  ( cloud_y )
        ,.i_cloud_z  ( cloud_z )
        ,.i_pose     ( i_pose  )
        // Output
        ,.o_valid    ( trans_valid )
        ,.o_cloud_x  ( trans_x )
        ,.o_cloud_y  ( trans_y )
        ,.o_cloud_z  ( trans_z )
    );

    //d17
    //8T
    //[su] = [K][P']  --  p.166(7.38)(7.39)(7.40)
    Proj u_proj (
        // input
         .i_clk      ( i_clk )
        ,.i_rst_n    ( i_rst_n )
        ,.i_valid   ( trans_valid )
        ,.i_cloud_x ( trans_x )
        ,.i_cloud_y ( trans_y )
        ,.i_cloud_z ( trans_z )
        // Register
        ,.r_fx      ( r_fx )
        ,.r_fy      ( r_fy )
        ,.r_cx      ( r_cx )
        ,.r_cy      ( r_cy )
        // Output
        ,.o_valid   ( proj_valid ) 
        ,.o_idx_x   ( proj_x )
        ,.o_idx_y   ( proj_y )
    );

    DataDelay
    #(
        .DATA_BW(H_SIZE_BW)
       ,.STAGE(17)
    ) u_idx1_x_delay (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_idx1_x)
        // Output
        ,.o_data(idx1_x_dly)
    );

    DataDelay
    #(
        .DATA_BW(V_SIZE_BW)
       ,.STAGE(17)
    ) u_idx1_y_delay (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_idx1_y)
        // Output
        ,.o_data(idx1_y_dly)
    );

    //d22
    assign o_diffs_x = {{(ID_COE_BW-H_SIZE_BW-1-MUL){diffs_x_r_d4[H_SIZE_BW-1]}},diffs_x_r_d4,{MUL{1'b0}}};
    assign o_diffs_y = {{(ID_COE_BW-V_SIZE_BW-1-MUL){diffs_y_r_d4[V_SIZE_BW-1]}},diffs_y_r_d4,{MUL{1'b0}}};

    //13T
    //p.167(7.45)
    IndirectCoe u_indirect_coe(
        // input
         .i_clk      ( i_clk )
        ,.i_rst_n    ( i_rst_n )
        ,.i_valid    ( trans_valid )
        ,.i_cloud_x  ( trans_x )
        ,.i_cloud_y  ( trans_y )
        ,.i_cloud_z  ( trans_z )
        // Register
        ,.r_fx     ( r_fx )
        ,.r_fy     ( r_fy )
        ,.r_cx     ( r_cx )
        ,.r_cy     ( r_cy )
        // Output
        ,.o_valid  ( o_valid )
        ,.o_Ax_0   ( o_Ax_0 )
        ,.o_Ax_1   ( o_Ax_1 )
        ,.o_Ax_2   ( o_Ax_2 )
        ,.o_Ax_3   ( o_Ax_3 )
        ,.o_Ax_4   ( o_Ax_4 )
        ,.o_Ax_5   ( o_Ax_5 )
        ,.o_Ay_0   ( o_Ay_0 )
        ,.o_Ay_1   ( o_Ay_1 )
        ,.o_Ay_2   ( o_Ay_2 )
        ,.o_Ay_3   ( o_Ay_3 )
        ,.o_Ay_4   ( o_Ay_4 )
        ,.o_Ay_5   ( o_Ay_5 )
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(22)
    ) u_frame_start_delay (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_frame_start)
        // Output
        ,.o_data(o_frame_start)
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(22)
    ) u_frame_end_delay (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_frame_end)
        // Output
        ,.o_data(o_frame_end)
    );

    DataDelay
    #(
        .DATA_BW(H_SIZE_BW+1)
       ,.STAGE(4)
    ) u_diffs_x_r_d4 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(diffs_x_r)
        // Output
        ,.o_data(diffs_x_r_d4)
    );

    DataDelay
    #(
        .DATA_BW(V_SIZE_BW+1)
       ,.STAGE(4)
    ) u_diffs_y_r_d4 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(diffs_y_r)
        // Output
        ,.o_data(diffs_y_r_d4)
    );

    //===================
    //    Sequential
    //===================
    //d18
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) diffs_x_r <= '0;
        else diffs_x_r <= $signed(idx1_x_dly) - $signed(proj_x);
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) diffs_y_r <= '0;
        else diffs_y_r <= $signed(idx1_y_dly) - $signed(proj_y);
    end


endmodule

