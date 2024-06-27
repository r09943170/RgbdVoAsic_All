// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023

//7T
module normalComputer
    import RgbdVoConfigPk::*;
#(
)(
    // input
     input                            i_clk
    ,input                            i_rst_n
    ,input                            i_valid
    ,input        [DATA_DEPTH_BW-1:0] i_depth_0
    ,input        [DATA_DEPTH_BW-1:0] i_depth_u
    ,input        [DATA_DEPTH_BW-1:0] i_depth_v
    ,input        [H_SIZE_BW-1:0]     i_u
    ,input        [V_SIZE_BW-1:0]     i_v
    // Register
    ,input        [FX_BW-1:0]         r_fx  //FX_BW = 10+24+1(+24 for MUL; +1 for sign)
    ,input        [FY_BW-1:0]         r_fy  //FY_BW = FX_BW
    ,input        [CX_BW-1:0]         r_cx  //CX_BW = FX_BW
    ,input        [CY_BW-1:0]         r_cy  //CY_BW = FX_BW
    // Output
    ,output logic                     o_valid
    ,output logic                     o_maskdepth
    ,output logic [CLOUD_BW+CLOUD_BW-MUL-1:0]      o_normal_x
    ,output logic [CLOUD_BW+CLOUD_BW-MUL-1:0]      o_normal_y
    ,output logic [CLOUD_BW+CLOUD_BW-MUL-1:0]      o_normal_z
);

    //=================================
    // Signal Declaration
    //=================================
    //d0
    logic                     RangeCheck;
    logic                     depthCheck;
    logic [H_SIZE_BW-1:0]     u;
    logic [H_SIZE_BW-1:0]     u1;   //u1 = u + 1
    logic [V_SIZE_BW-1:0]     v;
    logic [V_SIZE_BW-1:0]     v1;   //v1 = v + 1
    logic [DATA_DEPTH_BW-1:0] d;    //from u, v
    logic [DATA_DEPTH_BW-1:0] d_u;  //from u1, v
    logic [DATA_DEPTH_BW-1:0] d_v;  //from u, v1

    //d6
    logic                     p_0_valid;
    logic [CLOUD_BW-1:0]      p_x_0;
    logic [CLOUD_BW-1:0]      p_y_0;
    logic [CLOUD_BW-1:0]      p_z_0;
    logic                     p_u_valid;
    logic [CLOUD_BW-1:0]      p_x_u;
    logic [CLOUD_BW-1:0]      p_y_u;
    logic [CLOUD_BW-1:0]      p_z_u;
    logic                     p_v_valid;
    logic [CLOUD_BW-1:0]      p_x_v;
    logic [CLOUD_BW-1:0]      p_y_v;
    logic [CLOUD_BW-1:0]      p_z_v;

    logic [CLOUD_BW-1:0]      du_x;
    logic [CLOUD_BW-1:0]      du_y;
    logic [CLOUD_BW-1:0]      du_z;
    logic [CLOUD_BW-1:0]      dv_x;
    logic [CLOUD_BW-1:0]      dv_y;
    logic [CLOUD_BW-1:0]      dv_z;

    //d7
    logic                     normal_valid;
    logic [CLOUD_BW+CLOUD_BW-1:0]      n_x_o;
    logic [CLOUD_BW+CLOUD_BW-1:0]      n_y_o;
    logic [CLOUD_BW+CLOUD_BW-1:0]      n_z_o;
    logic                     normalCheck;


    //=================================
    // Combinational Logic
    //=================================
    //d0
    assign RangeCheck = (i_u < MAX_SRC_WID-1)   && (i_v < MAX_SRC_HGT-1);     //MAX_SRC_WID = 640; MAX_SRC_HGT = 480
    // assign depthCheck = (i_depth_0 > MIN_DEPTH) && (i_depth_0 < MAX_DEPTH);   //MIN_DEPTH = 0; MAX_DEPTH = 20000
    assign depthCheck = 1;
    assign u =   (RangeCheck && depthCheck) ? i_u       : 0;
    assign v =   (RangeCheck && depthCheck) ? i_v       : 0;
    assign u1 =  (RangeCheck && depthCheck) ? i_u + 1   : 0;
    assign v1 =  (RangeCheck && depthCheck) ? i_v + 1   : 0;
    assign d =   (RangeCheck && depthCheck) ? i_depth_0 : 0;
    assign d_u = (RangeCheck && depthCheck) ? i_depth_u : 0;
    assign d_v = (RangeCheck && depthCheck) ? i_depth_v : 0;

    //d6
    assign du_x = $signed(p_x_u - p_x_0);
    assign du_y = $signed(p_y_u - p_y_0);
    assign du_z = $signed(p_z_u - p_z_0);
    assign dv_x = $signed(p_x_v - p_x_0);
    assign dv_y = $signed(p_y_v - p_y_0);
    assign dv_z = $signed(p_z_v - p_z_0);

    //6T
    //input u,v,d; output p_x_0, p_y_0, p_z_0
    Idx2Cloud u_idx2cloud_0 (
        // input
         .i_clk   ( i_clk )
        ,.i_rst_n ( i_rst_n )
        ,.i_valid ( i_valid )
        ,.i_idx_x ( u ) //d0
        ,.i_idx_y ( v ) //d0
        ,.i_depth ( d ) //d0
        // Register
        ,.r_fx     ( r_fx )
        ,.r_fy     ( r_fy )
        ,.r_cx     ( r_cx )
        ,.r_cy     ( r_cy )
        // Output
        ,.o_valid   (p_0_valid)
        ,.o_cloud_x (p_x_0) //d6
        ,.o_cloud_y (p_y_0) //d6
        ,.o_cloud_z (p_z_0) //d6
    );

    //input u1,v,d_u; output p_x_u, p_y_u, p_z_u
    Idx2Cloud u_idx2cloud_u (
        // input
         .i_clk   ( i_clk )
        ,.i_rst_n ( i_rst_n )
        ,.i_valid ( i_valid )
        ,.i_idx_x ( u1 ) //d0
        ,.i_idx_y ( v ) //d0
        ,.i_depth ( d_u )   //d0
        // Register
        ,.r_fx     ( r_fx )
        ,.r_fy     ( r_fy )
        ,.r_cx     ( r_cx )
        ,.r_cy     ( r_cy )
        // Output
        ,.o_valid   (p_u_valid)
        ,.o_cloud_x (p_x_u) //d6
        ,.o_cloud_y (p_y_u) //d6
        ,.o_cloud_z (p_z_u) //d6
    );

    //input u,v1,d_v; output p_x_v, p_y_v, p_z_v
    Idx2Cloud u_idx2cloud_v (
        // input
         .i_clk   ( i_clk )
        ,.i_rst_n ( i_rst_n )
        ,.i_valid ( i_valid )
        ,.i_idx_x ( u ) //d0
        ,.i_idx_y ( v1 )    //d0
        ,.i_depth ( d_v )   //d0
        // Register
        ,.r_fx     ( r_fx )
        ,.r_fy     ( r_fy )
        ,.r_cx     ( r_cx )
        ,.r_cy     ( r_cy )
        // Output
        ,.o_valid   (p_v_valid)
        ,.o_cloud_x (p_x_v) //d6
        ,.o_cloud_y (p_y_v) //d6
        ,.o_cloud_z (p_z_v) //d6
    );

    //d7
    assign normalCheck = normal_valid? ((n_x_o != 0) || (n_y_o != 0) || (n_z_o != 0)) : 0;
    assign o_maskdepth = normalCheck;
    assign o_valid = normal_valid;
    assign o_normal_x = $signed(n_x_o[CLOUD_BW+CLOUD_BW-1:MUL]);
    assign o_normal_y = $signed(n_y_o[CLOUD_BW+CLOUD_BW-1:MUL]);
    assign o_normal_z = $signed(n_z_o[CLOUD_BW+CLOUD_BW-1:MUL]);

    //1T
    OuterProduct u_OuterProduct (
        // input
         .i_clk     ( i_clk )
        ,.i_rst_n   ( i_rst_n)
        ,.i_valid   ( p_0_valid )
        ,.i_p0_x    ( $signed(du_x) )   //d6
        ,.i_p0_y    ( $signed(du_y) )   //d6
        ,.i_p0_z    ( $signed(du_z) )   //d6
        ,.i_p1_x    ( $signed(dv_x) )   //d6
        ,.i_p1_y    ( $signed(dv_y) )   //d6
        ,.i_p1_z    ( $signed(dv_z) )   //d6
        // Output
        ,.o_valid     ( normal_valid )
        ,.o_normal_x  ( n_x_o ) //d7
        ,.o_normal_y  ( n_y_o ) //d7
        ,.o_normal_z  ( n_z_o ) //d7
    );

    //===================
    //    Sequential
    //===================


endmodule

