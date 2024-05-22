// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023

module CHIP_All
    import RgbdVoConfigPk::*;
#(
)(  
    //input
     input                            i_clk
    ,input                            i_rst_n
    ,input                            i_frame_start
    ,input                            i_frame_end   //useless
    ,input                            i_f_or_d
    ,input        [3:0]               i_n_of_f
    ,input                            i_valid_0
    ,input        [DATA_RGB_BW-1:0]   i_data0
    ,input        [DATA_DEPTH_BW-1:0] i_depth0
    ,input                            i_valid_1
    ,input        [DATA_RGB_BW-1:0]   i_data1
    ,input        [DATA_DEPTH_BW-1:0] i_depth1
    ,input        [POSE_BW-1:0]       i_pose [12]
    // Register
    ,input        [FX_BW-1:0]         r_fx  //FX_BW = 10+24+1(+24 for MUL; +1 for sign)
    ,input        [FY_BW-1:0]         r_fy  //FY_BW = FX_BW
    ,input        [CX_BW-1:0]         r_cx  //CX_BW = FX_BW
    ,input        [CY_BW-1:0]         r_cy  //CY_BW = FX_BW
    ,input        [H_SIZE_BW-1:0]     r_hsize   //H_SIZE_BW = 10
    ,input        [V_SIZE_BW-1:0]     r_vsize   //V_SIZE_BW = 10
    ,input        [2*CLOUD_BW-1:0]    sigma_icp
    ,input        [DATA_RGB_BW:0]     sigma_rgbd
    //output
    ,output logic                     o_feature_ready
    ,output logic                     o_done
    ,output logic [POSE_BW-1:0]       o_pose [12]
    ,output logic [2*CLOUD_BW-1:0]    o_sigma_icp
    ,output logic [DATA_RGB_BW:0]     o_sigma_rgbd
    //test
    ,output logic                     o_update_done
);

    //=================================
    // Signal Declaration
    //=================================
    //Feature_based
    logic [DATA_RGB_BW-1:0]     pixel_feature;
    logic [DATA_DEPTH_BW-1:0]   depth_feature;
    logic                       frame_start_feature; 
    logic                       valid_feature;

    logic                       feature_frame_start;
    logic                       feature_frame_end;
    logic                       feature_valid;
    logic                       feature_ready;
    logic [H_SIZE_BW-1:0]       src_coor_x;
    logic [V_SIZE_BW-1:0]       src_coor_y;
    logic [DATA_DEPTH_BW-1:0]   src_depth;
    logic [H_SIZE_BW-1:0]       dst_coor_x;
    logic [V_SIZE_BW-1:0]       dst_coor_y;
    logic [DATA_DEPTH_BW-1:0]   dst_depth;

    logic [3:0]                 count_of_f;
    logic [7:0]                 number_feature_match;
    logic                       cnt_en;
    logic                       cnt_en_d2;
    logic                       cnt_en_d3;
    logic [7:0]                 counter_feature_match;
    logic                       feature_out;

    logic [23:0]    bus1_sram_QA [0:5];
    logic [23:0]    bus1_sram_QB [0:5];
    logic           bus1_sram_WENA [0:5];
    logic           bus1_sram_WENB [0:5];
    logic [23:0]    bus1_sram_DA [0:5]; // pixel + depth
    logic [23:0]    bus1_sram_DB [0:5]; // pixel + depth
    logic [9:0]     bus1_sram_AA [0:5];
    logic [9:0]     bus1_sram_AB [0:5];

    logic [11:0]    bus2_sram_QA [0:1];
    logic [11:0]    bus2_sram_QB [0:1];
    logic           bus2_sram_WENA [0:1];
    logic           bus2_sram_WENB [0:1];
    logic [11:0]    bus2_sram_DA [0:1];
    logic [11:0]    bus2_sram_DB [0:1];
    logic [9:0]     bus2_sram_AA [0:1];
    logic [9:0]     bus2_sram_AB [0:1];

    logic [25:0]    bus3_sram_QA;
    logic [25:0]    bus3_sram_QB;
    logic           bus3_sram_WENA;
    logic           bus3_sram_WENB;
    logic [25:0]    bus3_sram_DA; // score, flag, reserved + depth
    logic [25:0]    bus3_sram_DB; // score, flag, reserved + depth
    logic [9:0]     bus3_sram_AA;
    logic [9:0]     bus3_sram_AB;

    logic [7:0]     bus4_sram_QA [0:29];
    logic [7:0]     bus4_sram_QB [0:29];
    logic           bus4_sram_WENA [0:29];
    logic           bus4_sram_WENB [0:29];
    logic [7:0]     bus4_sram_DA [0:29];
    logic [7:0]     bus4_sram_DB [0:29];
    logic [9:0]     bus4_sram_AA [0:29];
    logic [9:0]     bus4_sram_AB [0:29];

    logic [31:0]    bus5_sram_QA [0:7];
    logic           bus5_sram_WENA [0:7];
    logic [31:0]    bus5_sram_DA [0:7];
    logic [8:0]     bus5_sram_AA [0:7];

    logic [31:0]    bus6_sram_QA [0:7];
    logic           bus6_sram_WENA [0:7];
    logic [31:0]    bus6_sram_DA [0:7];
    logic [8:0]     bus6_sram_AA [0:7];

    logic [19:0]    bus7_sram_QA;
    logic           bus7_sram_WENA;
    logic [19:0]    bus7_sram_DA;
    logic [8:0]     bus7_sram_AA;

    logic [19:0]    bus8_sram_QA;
    logic           bus8_sram_WENA;
    logic [19:0]    bus8_sram_DA;
    logic [8:0]     bus8_sram_AA;

    logic [15:0]    bus9_sram_QA;
    logic           bus9_sram_WENA;
    logic [15:0]    bus9_sram_DA;
    logic [8:0]     bus9_sram_AA;

    logic [15:0]    bus10_sram_QA;
    logic           bus10_sram_WENA;
    logic [15:0]    bus10_sram_DA;
    logic [8:0]     bus10_sram_AA;

    logic                                 Feature_dstFrame_lb_sram_even_WENA[0:4];
    logic                                 Feature_dstFrame_lb_sram_even_WENB[0:4];
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] Feature_dstFrame_lb_sram_even_DA[0:4];
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] Feature_dstFrame_lb_sram_even_DB[0:4];
    logic [H_SIZE_BW-2:0]                 Feature_dstFrame_lb_sram_even_AA[0:4];
    logic [H_SIZE_BW-2:0]                 Feature_dstFrame_lb_sram_even_AB[0:4];

        //IndirectCalc
    logic                     i_id_frame_start;
    logic                     i_id_frame_end;
    logic                     i_id_valid;
    logic [H_SIZE_BW-1:0]     u0_r;
    logic [V_SIZE_BW-1:0]     v0_r;
    logic [DATA_DEPTH_BW-1:0] d0_r;
    logic [H_SIZE_BW-1:0]     u1_r;
    logic [V_SIZE_BW-1:0]     v1_r;
    logic [H_SIZE_BW-1:0]     i_id_u0;
    logic [V_SIZE_BW-1:0]     i_id_v0;
    logic [DATA_DEPTH_BW-1:0] i_id_d0;
    logic [H_SIZE_BW-1:0]     i_id_u1;
    logic [V_SIZE_BW-1:0]     i_id_v1;

    logic                     id_frame_start;
    logic                     id_frame_end;
    logic                     id_valid;
    logic [ID_COE_BW-1:0]     id_Ax_0;
    logic [ID_COE_BW-1:0]     id_Ax_1;
    logic [ID_COE_BW-1:0]     id_Ax_2;
    logic [ID_COE_BW-1:0]     id_Ax_3;
    logic [ID_COE_BW-1:0]     id_Ax_4;
    logic [ID_COE_BW-1:0]     id_Ax_5;
    logic [ID_COE_BW-1:0]     id_Ay_0;
    logic [ID_COE_BW-1:0]     id_Ay_1;
    logic [ID_COE_BW-1:0]     id_Ay_2;
    logic [ID_COE_BW-1:0]     id_Ay_3;
    logic [ID_COE_BW-1:0]     id_Ay_4;
    logic [ID_COE_BW-1:0]     id_Ay_5;
    logic [ID_COE_BW-1:0]     id_diffs_x;
    logic [ID_COE_BW-1:0]     id_diffs_y;

    //Direct
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] srcFrame_lb_sram_QA;
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] srcFrame_lb_sram_QB;

    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] dstFrame_lb_sram_even_QA[0:62];
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] dstFrame_lb_sram_even_QB[0:62];

    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] dstFrame_lb_sram_odd_QA[0:62];
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] dstFrame_lb_sram_odd_QB[0:62];

    logic                                 Corr_srcFrame_lb_sram_WENA;
    logic                                 Corr_srcFrame_lb_sram_WENB;
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] Corr_srcFrame_lb_sram_DA;
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] Corr_srcFrame_lb_sram_DB;
    logic [H_SIZE_BW-1:0]                 Corr_srcFrame_lb_sram_AA;
    logic [H_SIZE_BW-1:0]                 Corr_srcFrame_lb_sram_AB;

    logic                                 Corr_dstFrame_lb_sram_even_WENA[0:62];
    logic                                 Corr_dstFrame_lb_sram_even_WENB[0:62];
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] Corr_dstFrame_lb_sram_even_DA[0:62];
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] Corr_dstFrame_lb_sram_even_DB[0:62];
    logic [H_SIZE_BW-2:0]                 Corr_dstFrame_lb_sram_even_AA[0:62];
    logic [H_SIZE_BW-2:0]                 Corr_dstFrame_lb_sram_even_AB[0:62];

    logic                                 Corr_dstFrame_lb_sram_odd_WENA[0:62];
    logic                                 Corr_dstFrame_lb_sram_odd_WENB[0:62];
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] Corr_dstFrame_lb_sram_odd_DA[0:62];
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] Corr_dstFrame_lb_sram_odd_DB[0:62];
    logic [H_SIZE_BW-2:0]                 Corr_dstFrame_lb_sram_odd_AA[0:62];
    logic [H_SIZE_BW-2:0]                 Corr_dstFrame_lb_sram_odd_AB[0:62];

    logic                     i_Corr_frame_start;
    logic                     i_Corr_frame_end;
    logic                     i_Corr_valid_0;
    logic                     i_Corr_valid_1;
    logic                     Corr_frame_start;
    logic                     Corr_frame_end;
    logic                     Corr_valid;
    logic                     Corr_valid_corresps;
    logic [H_SIZE_BW-1:0]     Corr_u0;
    logic [V_SIZE_BW-1:0]     Corr_v0;
    logic [DATA_DEPTH_BW-1:0] Corr_d0;
    logic [H_SIZE_BW-1:0]     Corr_u1;
    logic [V_SIZE_BW-1:0]     Corr_v1;
    logic [DATA_DEPTH_BW-1:0] Corr_d1;
    logic [CLOUD_BW-1:0]      Corr_n1_x;
    logic [CLOUD_BW-1:0]      Corr_n1_y;
    logic [CLOUD_BW-1:0]      Corr_n1_z;
    logic [DATA_RGB_BW:0]     Corr_dI_dx;
    logic [DATA_RGB_BW:0]     Corr_dI_dy;
    logic [DATA_RGB_BW-1:0]   Corr_data0;
    logic [DATA_RGB_BW-1:0]   Corr_data1;

    logic                     ICP_frame_start;
    logic                     ICP_frame_end;
    logic                     ICP_valid;
    logic                     ICP_corresps_valid;
    logic [ID_COE_BW-1:0]     ICP_A0; 
    logic [ID_COE_BW-1:0]     ICP_A1; 
    logic [ID_COE_BW-1:0]     ICP_A2; 
    logic [ID_COE_BW-1:0]     ICP_A3; 
    logic [ID_COE_BW-1:0]     ICP_A4; 
    logic [ID_COE_BW-1:0]     ICP_A5; 
    logic [ID_COE_BW-1:0]     ICP_diff_div_w;
    logic [4*CLOUD_BW-1:0]    ICP_sigma_s;
    logic [H_SIZE_BW+V_SIZE_BW-1:0] ICP_corresp_count;

    logic                     ICP_sigma_frame_end;
    logic [2*CLOUD_BW-1:0]    ICP_sigma;
    logic [2*CLOUD_BW-1:0]    ICP_sigma_r;

    logic                     Rgbd_frame_start;
    logic                     Rgbd_frame_end;
    logic                     Rgbd_valid;
    logic                     Rgbd_corresps_valid;
    logic [ID_COE_BW-1:0]     Rgbd_A0; 
    logic [ID_COE_BW-1:0]     Rgbd_A1; 
    logic [ID_COE_BW-1:0]     Rgbd_A2; 
    logic [ID_COE_BW-1:0]     Rgbd_A3; 
    logic [ID_COE_BW-1:0]     Rgbd_A4; 
    logic [ID_COE_BW-1:0]     Rgbd_A5; 
    logic [ID_COE_BW-1:0]     Rgbd_diff_div_w;
    logic [H_SIZE_BW+V_SIZE_BW+2*DATA_RGB_BW+1:0] Rgbd_sigma_s;
    logic [H_SIZE_BW+V_SIZE_BW-1:0] Rgbd_corresp_count;

    logic                     Rgbd_mat_frame_end;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_00;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_10;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_20;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_30;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_40;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_50;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_11;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_21;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_31;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_41;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_51;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_22;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_32;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_42;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_52;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_33;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_43;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_53;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_44;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_54;
    logic [MATRIX_BW-1:0]     Rgbd_Mat_55;
    logic [MATRIX_BW-1:0]     Rgbd_Vec_0;
    logic [MATRIX_BW-1:0]     Rgbd_Vec_1;
    logic [MATRIX_BW-1:0]     Rgbd_Vec_2;
    logic [MATRIX_BW-1:0]     Rgbd_Vec_3;
    logic [MATRIX_BW-1:0]     Rgbd_Vec_4;
    logic [MATRIX_BW-1:0]     Rgbd_Vec_5;

    logic                     Rgbd_sigma_frame_end;
    logic [DATA_RGB_BW:0]     Rgbd_sigma;
    logic [DATA_RGB_BW:0]     Rgbd_sigma_r;

    logic                     ICP_mat_frame_end;

    logic                     Direct_mat_frame_end;
    logic [MATRIX_BW-1:0]     Direct_Mat_00;
    logic [MATRIX_BW-1:0]     Direct_Mat_10;
    logic [MATRIX_BW-1:0]     Direct_Mat_20;
    logic [MATRIX_BW-1:0]     Direct_Mat_30;
    logic [MATRIX_BW-1:0]     Direct_Mat_40;
    logic [MATRIX_BW-1:0]     Direct_Mat_50;
    logic [MATRIX_BW-1:0]     Direct_Mat_11;
    logic [MATRIX_BW-1:0]     Direct_Mat_21;
    logic [MATRIX_BW-1:0]     Direct_Mat_31;
    logic [MATRIX_BW-1:0]     Direct_Mat_41;
    logic [MATRIX_BW-1:0]     Direct_Mat_51;
    logic [MATRIX_BW-1:0]     Direct_Mat_22;
    logic [MATRIX_BW-1:0]     Direct_Mat_32;
    logic [MATRIX_BW-1:0]     Direct_Mat_42;
    logic [MATRIX_BW-1:0]     Direct_Mat_52;
    logic [MATRIX_BW-1:0]     Direct_Mat_33;
    logic [MATRIX_BW-1:0]     Direct_Mat_43;
    logic [MATRIX_BW-1:0]     Direct_Mat_53;
    logic [MATRIX_BW-1:0]     Direct_Mat_44;
    logic [MATRIX_BW-1:0]     Direct_Mat_54;
    logic [MATRIX_BW-1:0]     Direct_Mat_55;
    logic [MATRIX_BW-1:0]     Direct_Vec_0;
    logic [MATRIX_BW-1:0]     Direct_Vec_1;
    logic [MATRIX_BW-1:0]     Direct_Vec_2;
    logic [MATRIX_BW-1:0]     Direct_Vec_3;
    logic [MATRIX_BW-1:0]     Direct_Vec_4;
    logic [MATRIX_BW-1:0]     Direct_Vec_5;

    //Solver
    logic [POSE_BW-1:0]       curr_pose [12];

        //u_matrix_1
    logic                     i_Mat1_frame_start;
    logic                     i_Mat1_frame_end;
    logic                     Mat1_valid;
    logic [ID_COE_BW-1:0]     Mat1_Ax_0;
    logic [ID_COE_BW-1:0]     Mat1_Ax_1;
    logic [ID_COE_BW-1:0]     Mat1_Ax_2;
    logic [ID_COE_BW-1:0]     Mat1_Ax_3;
    logic [ID_COE_BW-1:0]     Mat1_Ax_4;
    logic [ID_COE_BW-1:0]     Mat1_Ax_5;
    logic [ID_COE_BW-1:0]     Mat1_Ay_0;
    logic [ID_COE_BW-1:0]     Mat1_Ay_1;
    logic [ID_COE_BW-1:0]     Mat1_Ay_2;
    logic [ID_COE_BW-1:0]     Mat1_Ay_3;
    logic [ID_COE_BW-1:0]     Mat1_Ay_4;
    logic [ID_COE_BW-1:0]     Mat1_Ay_5;
    logic [ID_COE_BW-1:0]     Mat1_diffs_x;
    logic [ID_COE_BW-1:0]     Mat1_diffs_y;

    logic                     o_Mat1_frame_end;
    logic [MATRIX_BW-1:0]     Mat1_00;
    logic [MATRIX_BW-1:0]     Mat1_10;
    logic [MATRIX_BW-1:0]     Mat1_20;
    logic [MATRIX_BW-1:0]     Mat1_30;
    logic [MATRIX_BW-1:0]     Mat1_40;
    logic [MATRIX_BW-1:0]     Mat1_50;
    logic [MATRIX_BW-1:0]     Mat1_11;
    logic [MATRIX_BW-1:0]     Mat1_21;
    logic [MATRIX_BW-1:0]     Mat1_31;
    logic [MATRIX_BW-1:0]     Mat1_41;
    logic [MATRIX_BW-1:0]     Mat1_51;
    logic [MATRIX_BW-1:0]     Mat1_22;
    logic [MATRIX_BW-1:0]     Mat1_32;
    logic [MATRIX_BW-1:0]     Mat1_42;
    logic [MATRIX_BW-1:0]     Mat1_52;
    logic [MATRIX_BW-1:0]     Mat1_33;
    logic [MATRIX_BW-1:0]     Mat1_43;
    logic [MATRIX_BW-1:0]     Mat1_53;
    logic [MATRIX_BW-1:0]     Mat1_44;
    logic [MATRIX_BW-1:0]     Mat1_54;
    logic [MATRIX_BW-1:0]     Mat1_55;
    logic [MATRIX_BW-1:0]     Vec1_0;
    logic [MATRIX_BW-1:0]     Vec1_1;
    logic [MATRIX_BW-1:0]     Vec1_2;
    logic [MATRIX_BW-1:0]     Vec1_3;
    logic [MATRIX_BW-1:0]     Vec1_4;
    logic [MATRIX_BW-1:0]     Vec1_5;

        //ldlt
    logic                 i_ldlt_frame_end;
    logic [MATRIX_BW-1:0] Mat_00;
    logic [MATRIX_BW-1:0] Mat_10;
    logic [MATRIX_BW-1:0] Mat_20;
    logic [MATRIX_BW-1:0] Mat_30;
    logic [MATRIX_BW-1:0] Mat_40;
    logic [MATRIX_BW-1:0] Mat_50;
    logic [MATRIX_BW-1:0] Mat_11;
    logic [MATRIX_BW-1:0] Mat_21;
    logic [MATRIX_BW-1:0] Mat_31;
    logic [MATRIX_BW-1:0] Mat_41;
    logic [MATRIX_BW-1:0] Mat_51;
    logic [MATRIX_BW-1:0] Mat_22;
    logic [MATRIX_BW-1:0] Mat_32;
    logic [MATRIX_BW-1:0] Mat_42;
    logic [MATRIX_BW-1:0] Mat_52;
    logic [MATRIX_BW-1:0] Mat_33;
    logic [MATRIX_BW-1:0] Mat_43;
    logic [MATRIX_BW-1:0] Mat_53;
    logic [MATRIX_BW-1:0] Mat_44;
    logic [MATRIX_BW-1:0] Mat_54;
    logic [MATRIX_BW-1:0] Mat_55;
    logic [MATRIX_BW-1:0] Vec_0;
    logic [MATRIX_BW-1:0] Vec_1;
    logic [MATRIX_BW-1:0] Vec_2;
    logic [MATRIX_BW-1:0] Vec_3;
    logic [MATRIX_BW-1:0] Vec_4;
    logic [MATRIX_BW-1:0] Vec_5;
                                
    logic                 ldlt_done;
    logic [MATRIX_BW-1:0] LDLT_Mat_00;
    logic [MATRIX_BW-1:0] LDLT_Mat_10;
    logic [MATRIX_BW-1:0] LDLT_Mat_20;
    logic [MATRIX_BW-1:0] LDLT_Mat_30;
    logic [MATRIX_BW-1:0] LDLT_Mat_40;
    logic [MATRIX_BW-1:0] LDLT_Mat_50;
    logic [MATRIX_BW-1:0] LDLT_Mat_11;
    logic [MATRIX_BW-1:0] LDLT_Mat_21;
    logic [MATRIX_BW-1:0] LDLT_Mat_31;
    logic [MATRIX_BW-1:0] LDLT_Mat_41;
    logic [MATRIX_BW-1:0] LDLT_Mat_51;
    logic [MATRIX_BW-1:0] LDLT_Mat_22;
    logic [MATRIX_BW-1:0] LDLT_Mat_32;
    logic [MATRIX_BW-1:0] LDLT_Mat_42;
    logic [MATRIX_BW-1:0] LDLT_Mat_52;
    logic [MATRIX_BW-1:0] LDLT_Mat_33;
    logic [MATRIX_BW-1:0] LDLT_Mat_43;
    logic [MATRIX_BW-1:0] LDLT_Mat_53;
    logic [MATRIX_BW-1:0] LDLT_Mat_44;
    logic [MATRIX_BW-1:0] LDLT_Mat_54;
    logic [MATRIX_BW-1:0] LDLT_Mat_55;
                                
    logic                 solver_done;
    logic [MATRIX_BW-1:0] X0;
    logic [MATRIX_BW-1:0] X1;
    logic [MATRIX_BW-1:0] X2;
    logic [MATRIX_BW-1:0] X3;
    logic [MATRIX_BW-1:0] X4;
    logic [MATRIX_BW-1:0] X5;
                                
    logic               rodrigues_done;
    logic [POSE_BW-1:0] pose [12];
                                
    logic               update_done;
    logic [POSE_BW-1:0] update_pose [12];

    //=================================
    // Combinational Logic
    //=================================
    //Feature_based
    assign pixel_feature       = (!i_f_or_d) ? i_data0       : 0;
    assign depth_feature       = (!i_f_or_d) ? i_depth0      : 0;
    assign frame_start_feature = (!i_f_or_d) ? i_frame_start : 0;
    assign valid_feature       = (!i_f_or_d) ? i_valid_0     : 0;
    CHIP
    #(
        .WIDTH(12'd640),
        .HEIGHT(12'd480),
        .EDGE(12'd31)
    )
    chip0  
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_pixel(pixel_feature),
        .i_depth(depth_feature),
        .i_frame_start(frame_start_feature),
        .i_valid(valid_feature),

        // .inspect_coordinate_X(inspect_coordinate_X),
        // .inspect_coordinate_Y(inspect_coordinate_Y),
        // .inspect_score(inspect_score),
        // .inspect_depth(inspect_depth),
        // .inspect_flag(inspect_flag),
        // .inspect_descriptor(inspect_descriptor),
        // .inspect_start(inspect_start),
        // .inspect_end(inspect_end),

        .o_ready            (feature_ready),
        .o_frame_end        (feature_frame_end),
        .o_frame_start      (feature_frame_start),
        .o_valid            (feature_valid),
        .o_src_coor_x       (src_coor_x),
        .o_src_coor_y       (src_coor_y),
        .o_src_depth        (src_depth),
        .o_dst_coor_x       (dst_coor_x),
        .o_dst_coor_y       (dst_coor_y),
        .o_dst_depth        (dst_depth),

        .FAST_lb_sram_QA(bus1_sram_QA),
        .FAST_lb_sram_QB(bus1_sram_QB),
        .FAST_lb_sram_WENA(bus1_sram_WENA),
        .FAST_lb_sram_WENB(bus1_sram_WENB),
        .FAST_lb_sram_DA(bus1_sram_DA),
        .FAST_lb_sram_DB(bus1_sram_DB),
        .FAST_lb_sram_AA(bus1_sram_AA),
        .FAST_lb_sram_AB(bus1_sram_AB),

        .FAST_sincos_sram_QA(bus2_sram_QA),
        .FAST_sincos_sram_QB(bus2_sram_QB),
        .FAST_sincos_sram_WENA(bus2_sram_WENA),
        .FAST_sincos_sram_WENB(bus2_sram_WENB),
        .FAST_sincos_sram_DA(bus2_sram_DA),
        .FAST_sincos_sram_DB(bus2_sram_DB),
        .FAST_sincos_sram_AA(bus2_sram_AA),
        .FAST_sincos_sram_AB(bus2_sram_AB),

        .FAST_NMS_sram_QA(bus3_sram_QA),
        .FAST_NMS_sram_QB(bus3_sram_QB),
        .FAST_NMS_sram_WENA(bus3_sram_WENA),
        .FAST_NMS_sram_WENB(bus3_sram_WENB),
        .FAST_NMS_sram_DA(bus3_sram_DA),
        .FAST_NMS_sram_DB(bus3_sram_DB),
        .FAST_NMS_sram_AA(bus3_sram_AA),
        .FAST_NMS_sram_AB(bus3_sram_AB),

        .BRIEF_lb_sram_QA(bus4_sram_QA),
        .BRIEF_lb_sram_QB(bus4_sram_QB),
        .BRIEF_lb_sram_WENA(bus4_sram_WENA),
        .BRIEF_lb_sram_WENB(bus4_sram_WENB),
        .BRIEF_lb_sram_DA(bus4_sram_DA),
        .BRIEF_lb_sram_DB(bus4_sram_DB),
        .BRIEF_lb_sram_AA(bus4_sram_AA),
        .BRIEF_lb_sram_AB(bus4_sram_AB),

        .MATCH_mem1_point_QA(bus7_sram_QA),
        .MATCH_mem1_point_WENA(bus7_sram_WENA),
        .MATCH_mem1_point_DA(bus7_sram_DA),
        .MATCH_mem1_point_AA(bus7_sram_AA),

        .MATCH_mem2_point_QA(bus8_sram_QA),
        .MATCH_mem2_point_WENA(bus8_sram_WENA),
        .MATCH_mem2_point_DA(bus8_sram_DA),
        .MATCH_mem2_point_AA(bus8_sram_AA),

        .MATCH_mem1_depth_QA(bus9_sram_QA),
        .MATCH_mem1_depth_WENA(bus9_sram_WENA),
        .MATCH_mem1_depth_DA(bus9_sram_DA),
        .MATCH_mem1_depth_AA(bus9_sram_AA),

        .MATCH_mem2_depth_QA(bus10_sram_QA),
        .MATCH_mem2_depth_WENA(bus10_sram_WENA),
        .MATCH_mem2_depth_DA(bus10_sram_DA),
        .MATCH_mem2_depth_AA(bus10_sram_AA),

        .MATCH_mem1_desc_QA(bus5_sram_QA),
        .MATCH_mem1_desc_WENA(bus5_sram_WENA),
        .MATCH_mem1_desc_DA(bus5_sram_DA),
        .MATCH_mem1_desc_AA(bus5_sram_AA),

        .MATCH_mem2_desc_QA(bus6_sram_QA),
        .MATCH_mem2_desc_WENA(bus6_sram_WENA),
        .MATCH_mem2_desc_DA(bus6_sram_DA),
        .MATCH_mem2_desc_AA(bus6_sram_AA)
    );

    always_comb begin
        Feature_dstFrame_lb_sram_even_DA[0] = (!i_f_or_d) ? {{(DATA_RGB_BW+DATA_DEPTH_BW-H_SIZE_BW){1'b0}}, {src_coor_x}}    : 0;
        Feature_dstFrame_lb_sram_even_DA[1] = (!i_f_or_d) ? {{(DATA_RGB_BW+DATA_DEPTH_BW-V_SIZE_BW){1'b0}}, {src_coor_y}}    : 0;
        Feature_dstFrame_lb_sram_even_DA[2] = (!i_f_or_d) ? {{(DATA_RGB_BW+DATA_DEPTH_BW-DATA_DEPTH_BW){1'b0}}, {src_depth}} : 0;
        Feature_dstFrame_lb_sram_even_DA[3] = (!i_f_or_d) ? {{(DATA_RGB_BW+DATA_DEPTH_BW-H_SIZE_BW){1'b0}}, {dst_coor_x}}    : 0;
        Feature_dstFrame_lb_sram_even_DA[4] = (!i_f_or_d) ? {{(DATA_RGB_BW+DATA_DEPTH_BW-V_SIZE_BW){1'b0}}, {dst_coor_y}}    : 0;
        // Feature_dstFrame_lb_sram_even_DA[5] = (!i_f_or_d) ? {{(DATA_RGB_BW+DATA_DEPTH_BW-DATA_DEPTH_BW){1'b0}}, {dst_depth}} : 0;
        for(int i = 0; i <= 4; i = i + 1)begin
            Feature_dstFrame_lb_sram_even_WENA[i] = (!i_f_or_d) ? ((count_of_f == 0) ? (!feature_valid) : 1) : 1;
            Feature_dstFrame_lb_sram_even_WENB[i] = (!i_f_or_d) ? 1 : 1;
            Feature_dstFrame_lb_sram_even_DB[i] = (!i_f_or_d) ? 0 : 0;
            Feature_dstFrame_lb_sram_even_AA[i] = (!i_f_or_d) ? ((count_of_f == 0) ? {{1'b0},{number_feature_match}} : {{1'b0},{counter_feature_match}}) : 0;
            Feature_dstFrame_lb_sram_even_AB[i] = (!i_f_or_d) ? ((count_of_f == 0) ? {{1'b0},{number_feature_match}} + 20 : {{1'b0},{counter_feature_match}}) +20 : 0;
        end
    end

    SRAM_all u_SRAM_all(
         .i_clk           ( i_clk )
        ,.i_rst_n         ( i_rst_n)
        ,.i_f_or_d        ( i_f_or_d )

        ,.bus1_sram_QA    ( bus1_sram_QA )
        ,.bus1_sram_QB    ( bus1_sram_QB )
        ,.bus1_sram_WENA  ( bus1_sram_WENA )
        ,.bus1_sram_WENB  ( bus1_sram_WENB )
        ,.bus1_sram_DA    ( bus1_sram_DA )
        ,.bus1_sram_DB    ( bus1_sram_DB )
        ,.bus1_sram_AA    ( bus1_sram_AA )
        ,.bus1_sram_AB    ( bus1_sram_AB )

        ,.bus2_sram_QA    ( bus2_sram_QA )
        ,.bus2_sram_QB    ( bus2_sram_QB )
        ,.bus2_sram_WENA  ( bus2_sram_WENA )
        ,.bus2_sram_WENB  ( bus2_sram_WENB )
        ,.bus2_sram_DA    ( bus2_sram_DA )
        ,.bus2_sram_DB    ( bus2_sram_DB )
        ,.bus2_sram_AA    ( bus2_sram_AA )
        ,.bus2_sram_AB    ( bus2_sram_AB )

        ,.bus3_sram_QA    ( bus3_sram_QA )
        ,.bus3_sram_QB    ( bus3_sram_QB )
        ,.bus3_sram_WENA  ( bus3_sram_WENA )
        ,.bus3_sram_WENB  ( bus3_sram_WENB )
        ,.bus3_sram_DA    ( bus3_sram_DA )
        ,.bus3_sram_DB    ( bus3_sram_DB )
        ,.bus3_sram_AA    ( bus3_sram_AA )
        ,.bus3_sram_AB    ( bus3_sram_AB )

        ,.bus4_sram_QA    ( bus4_sram_QA )
        ,.bus4_sram_QB    ( bus4_sram_QB )
        ,.bus4_sram_WENA  ( bus4_sram_WENA )
        ,.bus4_sram_WENB  ( bus4_sram_WENB )
        ,.bus4_sram_DA    ( bus4_sram_DA )
        ,.bus4_sram_DB    ( bus4_sram_DB )
        ,.bus4_sram_AA    ( bus4_sram_AA )
        ,.bus4_sram_AB    ( bus4_sram_AB )

        ,.bus5_sram_QA    ( bus5_sram_QA )
        ,.bus5_sram_WENA  ( bus5_sram_WENA )
        ,.bus5_sram_DA    ( bus5_sram_DA )
        ,.bus5_sram_AA    ( bus5_sram_AA )

        ,.bus6_sram_QA    ( bus6_sram_QA )
        ,.bus6_sram_WENA  ( bus6_sram_WENA )
        ,.bus6_sram_DA    ( bus6_sram_DA )
        ,.bus6_sram_AA    ( bus6_sram_AA )

        ,.bus7_sram_QA    ( bus7_sram_QA )
        ,.bus7_sram_WENA  ( bus7_sram_WENA )
        ,.bus7_sram_DA    ( bus7_sram_DA )
        ,.bus7_sram_AA    ( bus7_sram_AA )

        ,.bus8_sram_QA    ( bus8_sram_QA )
        ,.bus8_sram_WENA  ( bus8_sram_WENA )
        ,.bus8_sram_DA    ( bus8_sram_DA )
        ,.bus8_sram_AA    ( bus8_sram_AA )

        ,.bus9_sram_QA    ( bus9_sram_QA )
        ,.bus9_sram_WENA  ( bus9_sram_WENA )
        ,.bus9_sram_DA    ( bus9_sram_DA )
        ,.bus9_sram_AA    ( bus9_sram_AA )

        ,.bus10_sram_QA   ( bus10_sram_QA )
        ,.bus10_sram_WENA ( bus10_sram_WENA )
        ,.bus10_sram_DA   ( bus10_sram_DA )
        ,.bus10_sram_AA   ( bus10_sram_AA )

        ,.Feature_dstFrame_lb_sram_even_WENA ( Feature_dstFrame_lb_sram_even_WENA )
        ,.Feature_dstFrame_lb_sram_even_WENB ( Feature_dstFrame_lb_sram_even_WENB )
        ,.Feature_dstFrame_lb_sram_even_DA   ( Feature_dstFrame_lb_sram_even_DA )
        ,.Feature_dstFrame_lb_sram_even_DB   ( Feature_dstFrame_lb_sram_even_DB )
        ,.Feature_dstFrame_lb_sram_even_AA   ( Feature_dstFrame_lb_sram_even_AA )
        ,.Feature_dstFrame_lb_sram_even_AB   ( Feature_dstFrame_lb_sram_even_AB )

        ,.srcFrame_lb_sram_QA             ( srcFrame_lb_sram_QA )
        ,.srcFrame_lb_sram_QB             ( srcFrame_lb_sram_QB )
        ,.Corr_srcFrame_lb_sram_WENA      ( Corr_srcFrame_lb_sram_WENA )
        ,.Corr_srcFrame_lb_sram_WENB      ( Corr_srcFrame_lb_sram_WENB )
        ,.Corr_srcFrame_lb_sram_DA        ( Corr_srcFrame_lb_sram_DA )
        ,.Corr_srcFrame_lb_sram_DB        ( Corr_srcFrame_lb_sram_DB )
        ,.Corr_srcFrame_lb_sram_AA        ( Corr_srcFrame_lb_sram_AA )
        ,.Corr_srcFrame_lb_sram_AB        ( Corr_srcFrame_lb_sram_AB )

        ,.dstFrame_lb_sram_even_QA        ( dstFrame_lb_sram_even_QA )
        ,.dstFrame_lb_sram_even_QB        ( dstFrame_lb_sram_even_QB )
        ,.Corr_dstFrame_lb_sram_even_WENA ( Corr_dstFrame_lb_sram_even_WENA )
        ,.Corr_dstFrame_lb_sram_even_WENB ( Corr_dstFrame_lb_sram_even_WENB )
        ,.Corr_dstFrame_lb_sram_even_DA   ( Corr_dstFrame_lb_sram_even_DA )
        ,.Corr_dstFrame_lb_sram_even_DB   ( Corr_dstFrame_lb_sram_even_DB )
        ,.Corr_dstFrame_lb_sram_even_AA   ( Corr_dstFrame_lb_sram_even_AA )
        ,.Corr_dstFrame_lb_sram_even_AB   ( Corr_dstFrame_lb_sram_even_AB )

        ,.dstFrame_lb_sram_odd_QA         ( dstFrame_lb_sram_odd_QA )
        ,.dstFrame_lb_sram_odd_QB         ( dstFrame_lb_sram_odd_QB )
        ,.Corr_dstFrame_lb_sram_odd_WENA  ( Corr_dstFrame_lb_sram_odd_WENA )
        ,.Corr_dstFrame_lb_sram_odd_WENB  ( Corr_dstFrame_lb_sram_odd_WENB )
        ,.Corr_dstFrame_lb_sram_odd_DA    ( Corr_dstFrame_lb_sram_odd_DA )
        ,.Corr_dstFrame_lb_sram_odd_DB    ( Corr_dstFrame_lb_sram_odd_DB )
        ,.Corr_dstFrame_lb_sram_odd_AA    ( Corr_dstFrame_lb_sram_odd_AA )
        ,.Corr_dstFrame_lb_sram_odd_AB    ( Corr_dstFrame_lb_sram_odd_AB )
    );

    //12T
    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(2)
    ) u_cnt_en_d2 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(cnt_en)
        // Output
        ,.o_data(cnt_en_d2)
    );
    
    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(1)
    ) u_cnt_en_d3 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(cnt_en_d2)
        // Output
        ,.o_data(cnt_en_d3)
    );

    assign cnt_en = ((count_of_f > 0) && (counter_feature_match < number_feature_match)) ? 1 : 0;

    assign i_id_frame_start = i_f_or_d ? 0 : ((count_of_f == 0) ? feature_frame_start : ((cnt_en_d3 == 0) && (cnt_en_d2 == 1)));
    assign i_id_frame_end   = i_f_or_d ? 0 : ((count_of_f == 0) ? feature_frame_end   : ((cnt_en_d3 == 1) && (cnt_en_d2 == 0)));
    assign i_id_valid       = i_f_or_d ? 0 : ((count_of_f == 0) ? feature_valid       : cnt_en_d2);
    assign i_id_u0          = i_f_or_d ? 0 : ((count_of_f == 0) ? src_coor_x          : u0_r);
    assign i_id_v0          = i_f_or_d ? 0 : ((count_of_f == 0) ? src_coor_y          : v0_r);
    assign i_id_d0          = i_f_or_d ? 0 : ((count_of_f == 0) ? src_depth           : d0_r);
    assign i_id_u1          = i_f_or_d ? 0 : ((count_of_f == 0) ? dst_coor_x          : u1_r);
    assign i_id_v1          = i_f_or_d ? 0 : ((count_of_f == 0) ? dst_coor_y          : v1_r);
    IndirectCalc u_indirect_calc(
        // input                
         .i_clk         ( i_clk )
        ,.i_rst_n       ( i_rst_n)
        ,.i_frame_start ( i_id_frame_start )
        ,.i_frame_end   ( i_id_frame_end )
        ,.i_valid       ( i_id_valid )
        ,.i_idx0_x      ( i_id_u0 )
        ,.i_idx0_y      ( i_id_v0 )
        ,.i_depth0      ( i_id_d0 )
        ,.i_idx1_x      ( i_id_u1 )
        ,.i_idx1_y      ( i_id_v1 )
        ,.i_pose        ( curr_pose )
        // Register
        ,.r_fx           ( r_fx )
        ,.r_fy           ( r_fy )
        ,.r_cx           ( r_cx )
        ,.r_cy           ( r_cy )
        // Output
        ,.o_frame_start  ( id_frame_start )
        ,.o_frame_end    ( id_frame_end )
        ,.o_valid        ( id_valid )
        ,.o_Ax_0         ( id_Ax_0 )
        ,.o_Ax_1         ( id_Ax_1 )
        ,.o_Ax_2         ( id_Ax_2 )
        ,.o_Ax_3         ( id_Ax_3 )
        ,.o_Ax_4         ( id_Ax_4 )
        ,.o_Ax_5         ( id_Ax_5 )
        ,.o_Ay_0         ( id_Ay_0 )
        ,.o_Ay_1         ( id_Ay_1 )
        ,.o_Ay_2         ( id_Ay_2 )
        ,.o_Ay_3         ( id_Ay_3 )
        ,.o_Ay_4         ( id_Ay_4 )
        ,.o_Ay_5         ( id_Ay_5 )
        ,.o_diffs_x      ( id_diffs_x )
        ,.o_diffs_y      ( id_diffs_y )
    );

    //Direct
    assign i_Corr_frame_start = i_f_or_d ? i_frame_start : 0;
    assign i_Corr_frame_end   = i_f_or_d ? i_frame_end   : 0;
    assign i_Corr_valid_0     = i_f_or_d ? i_valid_0     : 0;
    assign i_Corr_valid_1     = i_f_or_d ? i_valid_1     : 0;
    ComputeCorresps u_ComputeCorresps(
        // input/output
         .i_clk                   ( i_clk )
        ,.i_rst_n                 ( i_rst_n )
        ,.i_frame_start           ( i_Corr_frame_start )
        ,.i_frame_end             ( i_Corr_frame_end )
        ,.i_valid_0               ( i_Corr_valid_0 )
        ,.i_data0                 ( i_data0 )
        ,.i_depth0                ( i_depth0 )
        ,.i_valid_1               ( i_Corr_valid_1 )
        ,.i_data1                 ( i_data1 )
        ,.i_depth1                ( i_depth1 )
        ,.i_update_done           ( update_done )
        ,.i_pose                  ( curr_pose )
        ,.o_frame_start           ( Corr_frame_start )
        ,.o_frame_end             ( Corr_frame_end )
        ,.o_valid                 ( Corr_valid )
        ,.o_valid_corresps        ( Corr_valid_corresps )
        ,.o_corresps_u0           ( Corr_u0 )
        ,.o_corresps_v0           ( Corr_v0 )
        ,.o_corresps_d0           ( Corr_d0 )
        ,.o_corresps_u1           ( Corr_u1 )
        ,.o_corresps_v1           ( Corr_v1 )
        ,.o_corresps_d1           ( Corr_d1 )
        ,.o_n1_x                  ( Corr_n1_x )
        ,.o_n1_y                  ( Corr_n1_y )
        ,.o_n1_z                  ( Corr_n1_z )
        ,.o_dI_dx                 ( Corr_dI_dx )
        ,.o_dI_dy                 ( Corr_dI_dy )
        ,.o_data0                 ( Corr_data0 )
        ,.o_data1                 ( Corr_data1 )
        // Register  
        ,.r_fx                    ( r_fx )
        ,.r_fy                    ( r_fy )
        ,.r_cx                    ( r_cx )
        ,.r_cy                    ( r_cy )
        ,.r_hsize                 ( r_hsize )
        ,.r_vsize                 ( r_vsize )
        // depth_lb_sram interface
        ,.i_srcFrame_lb_sram_QA      ( srcFrame_lb_sram_QA )
        ,.i_srcFrame_lb_sram_QB      ( srcFrame_lb_sram_QB )
        ,.o_srcFrame_lb_sram_WENA    ( Corr_srcFrame_lb_sram_WENA )
        ,.o_srcFrame_lb_sram_WENB    ( Corr_srcFrame_lb_sram_WENB )
        ,.o_srcFrame_lb_sram_DA      ( Corr_srcFrame_lb_sram_DA )
        ,.o_srcFrame_lb_sram_DB      ( Corr_srcFrame_lb_sram_DB )
        ,.o_srcFrame_lb_sram_AA      ( Corr_srcFrame_lb_sram_AA )
        ,.o_srcFrame_lb_sram_AB      ( Corr_srcFrame_lb_sram_AB )
        // dstFrame_lb_sram interface
        ,.i_dstFrame_lb_sram_even_QA   ( dstFrame_lb_sram_even_QA )
        ,.i_dstFrame_lb_sram_even_QB   ( dstFrame_lb_sram_even_QB )
        ,.o_dstFrame_lb_sram_even_WENA ( Corr_dstFrame_lb_sram_even_WENA )
        ,.o_dstFrame_lb_sram_even_WENB ( Corr_dstFrame_lb_sram_even_WENB )
        ,.o_dstFrame_lb_sram_even_DA   ( Corr_dstFrame_lb_sram_even_DA )
        ,.o_dstFrame_lb_sram_even_DB   ( Corr_dstFrame_lb_sram_even_DB )
        ,.o_dstFrame_lb_sram_even_AA   ( Corr_dstFrame_lb_sram_even_AA )
        ,.o_dstFrame_lb_sram_even_AB   ( Corr_dstFrame_lb_sram_even_AB )

        ,.i_dstFrame_lb_sram_odd_QA   ( dstFrame_lb_sram_odd_QA )
        ,.i_dstFrame_lb_sram_odd_QB   ( dstFrame_lb_sram_odd_QB )
        ,.o_dstFrame_lb_sram_odd_WENA ( Corr_dstFrame_lb_sram_odd_WENA )
        ,.o_dstFrame_lb_sram_odd_WENB ( Corr_dstFrame_lb_sram_odd_WENB )
        ,.o_dstFrame_lb_sram_odd_DA   ( Corr_dstFrame_lb_sram_odd_DA )
        ,.o_dstFrame_lb_sram_odd_DB   ( Corr_dstFrame_lb_sram_odd_DB )
        ,.o_dstFrame_lb_sram_odd_AA   ( Corr_dstFrame_lb_sram_odd_AA )
        ,.o_dstFrame_lb_sram_odd_AB   ( Corr_dstFrame_lb_sram_odd_AB )
    );

    CalcICPLsmMatrices u_CalcICPLsmMatrices(
        // input
         .i_clk                   ( i_clk )
        ,.i_rst_n                 ( i_rst_n )
        ,.i_frame_start           ( Corr_frame_start )
        ,.i_frame_end             ( Corr_frame_end )
        ,.i_valid                 ( Corr_valid )
        ,.i_corresps_valid        ( Corr_valid_corresps )
        ,.i_u0                    ( Corr_u0 )
        ,.i_v0                    ( Corr_v0 )
        ,.i_d0                    ( Corr_d0 )
        ,.i_u1                    ( Corr_u1 )
        ,.i_v1                    ( Corr_v1 )
        ,.i_d1                    ( Corr_d1 )
        ,.i_n1_x                  ( Corr_n1_x )
        ,.i_n1_y                  ( Corr_n1_y )
        ,.i_n1_z                  ( Corr_n1_z )
        ,.i_sigma_icp             ( sigma_icp )
        ,.i_update_done           ( update_done )
        ,.i_pose                  ( curr_pose )

        // Register  
        ,.r_fx                    ( r_fx )
        ,.r_fy                    ( r_fy )
        ,.r_cx                    ( r_cx )
        ,.r_cy                    ( r_cy )

        // Output
        ,.o_frame_start           ( ICP_frame_start )
        ,.o_frame_end             ( ICP_frame_end )
        ,.o_valid                 ( ICP_valid )
        ,.o_corresps_valid        ( ICP_corresps_valid )
        ,.o_A0                    ( ICP_A0 )
        ,.o_A1                    ( ICP_A1 )
        ,.o_A2                    ( ICP_A2 )
        ,.o_A3                    ( ICP_A3 )
        ,.o_A4                    ( ICP_A4 )
        ,.o_A5                    ( ICP_A5 )
        ,.o_diff_div_w            ( ICP_diff_div_w )
        ,.o_sigma_s_icp           ( ICP_sigma_s )
        ,.o_corresp_count         ( ICP_corresp_count )
    );

    sigma_icp_generator u_sigma_icp_generator(
        //input
         .i_clk                   ( i_clk )
        ,.i_rst_n                 ( i_rst_n )
        ,.i_frame_end             ( ICP_frame_end )
        ,.i_sigma_s_icp           ( ICP_sigma_s )
        ,.i_corresp_count         ( ICP_corresp_count )
        //output
        ,.o_frame_end             ( ICP_sigma_frame_end )
        ,.o_sigma_icp             ( ICP_sigma )
    );

    CalcRgbdLsmMatrices u_CalcRgbdLsmMatrices(
        // input
         .i_clk                   ( i_clk )
        ,.i_rst_n                 ( i_rst_n )
        ,.i_frame_start           ( Corr_frame_start )
        ,.i_frame_end             ( Corr_frame_end )
        ,.i_valid                 ( Corr_valid )
        ,.i_corresps_valid        ( Corr_valid_corresps )
        ,.i_u0                    ( Corr_u0 )
        ,.i_v0                    ( Corr_v0 )
        ,.i_d0                    ( Corr_d0 )
        ,.i_Rgb_0                 ( Corr_data0 )
        ,.i_Rgb_1                 ( Corr_data1 )
        ,.dI_dx_1                 ( Corr_dI_dx )
        ,.dI_dy_1                 ( Corr_dI_dy )
        ,.i_sigma_rgb             ( sigma_rgbd )
        ,.i_update_done           ( update_done )
        ,.i_pose                  ( curr_pose )

        // Register  
        ,.r_fx                    ( r_fx )
        ,.r_fy                    ( r_fy )
        ,.r_cx                    ( r_cx )
        ,.r_cy                    ( r_cy )

        // Output
        ,.o_frame_start           ( Rgbd_frame_start )
        ,.o_frame_end             ( Rgbd_frame_end )
        ,.o_valid                 ( Rgbd_valid )
        ,.o_corresps_valid        ( Rgbd_corresps_valid )
        ,.o_A0                    ( Rgbd_A0 )
        ,.o_A1                    ( Rgbd_A1 )
        ,.o_A2                    ( Rgbd_A2 )
        ,.o_A3                    ( Rgbd_A3 )
        ,.o_A4                    ( Rgbd_A4 )
        ,.o_A5                    ( Rgbd_A5 )
        ,.o_diff_div_w            ( Rgbd_diff_div_w )
        ,.o_sigma_s_rgbd          ( Rgbd_sigma_s )
        ,.o_corresp_count         ( Rgbd_corresp_count )
    );

    Matrix u_Matrix_rgbd(
        // input
         .i_clk                   ( i_clk )
        ,.i_rst_n                 ( i_rst_n )
        ,.i_frame_start           ( Rgbd_frame_start )
        ,.i_frame_end             ( Rgbd_frame_end )
        ,.i_valid                 ( Rgbd_corresps_valid )
        ,.i_Ax_0                  ( Rgbd_A0 )
        ,.i_Ax_1                  ( Rgbd_A1 )
        ,.i_Ax_2                  ( Rgbd_A2 )
        ,.i_Ax_3                  ( Rgbd_A3 )
        ,.i_Ax_4                  ( Rgbd_A4 )
        ,.i_Ax_5                  ( Rgbd_A5 )
        ,.i_Ay_0                  ( 42'd0 )
        ,.i_Ay_1                  ( 42'd0 )
        ,.i_Ay_2                  ( 42'd0 )
        ,.i_Ay_3                  ( 42'd0 )
        ,.i_Ay_4                  ( 42'd0 )
        ,.i_Ay_5                  ( 42'd0 )
        ,.i_diffs_x               ( Rgbd_diff_div_w )
        ,.i_diffs_y               ( 42'd0 )
        // output
        ,.o_frame_end             ( Rgbd_mat_frame_end )
        ,.o_Mat_00                ( Rgbd_Mat_00 )
        ,.o_Mat_10                ( Rgbd_Mat_10 )
        ,.o_Mat_20                ( Rgbd_Mat_20 )
        ,.o_Mat_30                ( Rgbd_Mat_30 )
        ,.o_Mat_40                ( Rgbd_Mat_40 )
        ,.o_Mat_50                ( Rgbd_Mat_50 )
        ,.o_Mat_11                ( Rgbd_Mat_11 )
        ,.o_Mat_21                ( Rgbd_Mat_21 )
        ,.o_Mat_31                ( Rgbd_Mat_31 )
        ,.o_Mat_41                ( Rgbd_Mat_41 )
        ,.o_Mat_51                ( Rgbd_Mat_51 )
        ,.o_Mat_22                ( Rgbd_Mat_22 )
        ,.o_Mat_32                ( Rgbd_Mat_32 )
        ,.o_Mat_42                ( Rgbd_Mat_42 )
        ,.o_Mat_52                ( Rgbd_Mat_52 )
        ,.o_Mat_33                ( Rgbd_Mat_33 )
        ,.o_Mat_43                ( Rgbd_Mat_43 )
        ,.o_Mat_53                ( Rgbd_Mat_53 )
        ,.o_Mat_44                ( Rgbd_Mat_44 )
        ,.o_Mat_54                ( Rgbd_Mat_54 )
        ,.o_Mat_55                ( Rgbd_Mat_55 )
        ,.o_Vec_0                 ( Rgbd_Vec_0 )
        ,.o_Vec_1                 ( Rgbd_Vec_1 )
        ,.o_Vec_2                 ( Rgbd_Vec_2 )
        ,.o_Vec_3                 ( Rgbd_Vec_3 )
        ,.o_Vec_4                 ( Rgbd_Vec_4 )
        ,.o_Vec_5                 ( Rgbd_Vec_5 )
    );

    sigma_rgbd_generator u_sigma_rgbd_generator(
        //input
         .i_clk                   ( i_clk )
        ,.i_rst_n                 ( i_rst_n )
        ,.i_frame_end             ( Rgbd_frame_end )
        ,.i_sigma_s_rgbd          ( Rgbd_sigma_s )
        ,.i_corresp_count         ( Rgbd_corresp_count )
        //output
        ,.o_frame_end             ( Rgbd_sigma_frame_end )
        ,.o_sigma_rgbd            ( Rgbd_sigma )
    );

    assign ICP_mat_frame_end = i_f_or_d ? o_Mat1_frame_end : 0;
    AtA_AtB_of_Direct u_AtA_AtB_of_Direct(
        // input
         .i_clk                   ( i_clk )
        ,.i_rst_n                 ( i_rst_n )
        ,.i_frame_start           ( Corr_frame_start )
        ,.i_frame_end_icp         ( ICP_mat_frame_end )
        ,.i_ICP_Mat_00            ( Mat1_00 )
        ,.i_ICP_Mat_10            ( Mat1_10 )
        ,.i_ICP_Mat_20            ( Mat1_20 )
        ,.i_ICP_Mat_30            ( Mat1_30 )
        ,.i_ICP_Mat_40            ( Mat1_40 )
        ,.i_ICP_Mat_50            ( Mat1_50 )
        ,.i_ICP_Mat_11            ( Mat1_11 )
        ,.i_ICP_Mat_21            ( Mat1_21 )
        ,.i_ICP_Mat_31            ( Mat1_31 )
        ,.i_ICP_Mat_41            ( Mat1_41 )
        ,.i_ICP_Mat_51            ( Mat1_51 )
        ,.i_ICP_Mat_22            ( Mat1_22 )
        ,.i_ICP_Mat_32            ( Mat1_32 )
        ,.i_ICP_Mat_42            ( Mat1_42 )
        ,.i_ICP_Mat_52            ( Mat1_52 )
        ,.i_ICP_Mat_33            ( Mat1_33 )
        ,.i_ICP_Mat_43            ( Mat1_43 )
        ,.i_ICP_Mat_53            ( Mat1_53 )
        ,.i_ICP_Mat_44            ( Mat1_44 )
        ,.i_ICP_Mat_54            ( Mat1_54 )
        ,.i_ICP_Mat_55            ( Mat1_55 )
        ,.i_ICP_Vec_0             ( Vec1_0 )
        ,.i_ICP_Vec_1             ( Vec1_1 )
        ,.i_ICP_Vec_2             ( Vec1_2 )
        ,.i_ICP_Vec_3             ( Vec1_3 )
        ,.i_ICP_Vec_4             ( Vec1_4 )
        ,.i_ICP_Vec_5             ( Vec1_5 )
        ,.i_frame_end_rgbd        ( Rgbd_mat_frame_end )
        ,.i_Rgbd_Mat_00           ( Rgbd_Mat_00 )
        ,.i_Rgbd_Mat_10           ( Rgbd_Mat_10 )
        ,.i_Rgbd_Mat_20           ( Rgbd_Mat_20 )
        ,.i_Rgbd_Mat_30           ( Rgbd_Mat_30 )
        ,.i_Rgbd_Mat_40           ( Rgbd_Mat_40 )
        ,.i_Rgbd_Mat_50           ( Rgbd_Mat_50 )
        ,.i_Rgbd_Mat_11           ( Rgbd_Mat_11 )
        ,.i_Rgbd_Mat_21           ( Rgbd_Mat_21 )
        ,.i_Rgbd_Mat_31           ( Rgbd_Mat_31 )
        ,.i_Rgbd_Mat_41           ( Rgbd_Mat_41 )
        ,.i_Rgbd_Mat_51           ( Rgbd_Mat_51 )
        ,.i_Rgbd_Mat_22           ( Rgbd_Mat_22 )
        ,.i_Rgbd_Mat_32           ( Rgbd_Mat_32 )
        ,.i_Rgbd_Mat_42           ( Rgbd_Mat_42 )
        ,.i_Rgbd_Mat_52           ( Rgbd_Mat_52 )
        ,.i_Rgbd_Mat_33           ( Rgbd_Mat_33 )
        ,.i_Rgbd_Mat_43           ( Rgbd_Mat_43 )
        ,.i_Rgbd_Mat_53           ( Rgbd_Mat_53 )
        ,.i_Rgbd_Mat_44           ( Rgbd_Mat_44 )
        ,.i_Rgbd_Mat_54           ( Rgbd_Mat_54 )
        ,.i_Rgbd_Mat_55           ( Rgbd_Mat_55 )
        ,.i_Rgbd_Vec_0            ( Rgbd_Vec_0 )
        ,.i_Rgbd_Vec_1            ( Rgbd_Vec_1 )
        ,.i_Rgbd_Vec_2            ( Rgbd_Vec_2 )
        ,.i_Rgbd_Vec_3            ( Rgbd_Vec_3 )
        ,.i_Rgbd_Vec_4            ( Rgbd_Vec_4 )
        ,.i_Rgbd_Vec_5            ( Rgbd_Vec_5 )
        // output
        ,.o_frame_end             ( Direct_mat_frame_end )
        ,.o_Mat_00                ( Direct_Mat_00 )
        ,.o_Mat_10                ( Direct_Mat_10 )
        ,.o_Mat_20                ( Direct_Mat_20 )
        ,.o_Mat_30                ( Direct_Mat_30 )
        ,.o_Mat_40                ( Direct_Mat_40 )
        ,.o_Mat_50                ( Direct_Mat_50 )
        ,.o_Mat_11                ( Direct_Mat_11 )
        ,.o_Mat_21                ( Direct_Mat_21 )
        ,.o_Mat_31                ( Direct_Mat_31 )
        ,.o_Mat_41                ( Direct_Mat_41 )
        ,.o_Mat_51                ( Direct_Mat_51 )
        ,.o_Mat_22                ( Direct_Mat_22 )
        ,.o_Mat_32                ( Direct_Mat_32 )
        ,.o_Mat_42                ( Direct_Mat_42 )
        ,.o_Mat_52                ( Direct_Mat_52 )
        ,.o_Mat_33                ( Direct_Mat_33 )
        ,.o_Mat_43                ( Direct_Mat_43 )
        ,.o_Mat_53                ( Direct_Mat_53 )
        ,.o_Mat_44                ( Direct_Mat_44 )
        ,.o_Mat_54                ( Direct_Mat_54 )
        ,.o_Mat_55                ( Direct_Mat_55 )
        ,.o_Vec_0                 ( Direct_Vec_0 )
        ,.o_Vec_1                 ( Direct_Vec_1 )
        ,.o_Vec_2                 ( Direct_Vec_2 )
        ,.o_Vec_3                 ( Direct_Vec_3 )
        ,.o_Vec_4                 ( Direct_Vec_4 )
        ,.o_Vec_5                 ( Direct_Vec_5 )
    );

    //Solver
    assign i_Mat1_frame_start = (!i_f_or_d) ? id_frame_start : ICP_frame_start;
    assign i_Mat1_frame_end   = (!i_f_or_d) ? id_frame_end   : ICP_frame_end;
    assign Mat1_valid         = (!i_f_or_d) ? id_valid       : ICP_corresps_valid;
    assign Mat1_Ax_0          = (!i_f_or_d) ? id_Ax_0        : ICP_A0;
    assign Mat1_Ax_1          = (!i_f_or_d) ? id_Ax_1        : ICP_A1;
    assign Mat1_Ax_2          = (!i_f_or_d) ? id_Ax_2        : ICP_A2;
    assign Mat1_Ax_3          = (!i_f_or_d) ? id_Ax_3        : ICP_A3;
    assign Mat1_Ax_4          = (!i_f_or_d) ? id_Ax_4        : ICP_A4;
    assign Mat1_Ax_5          = (!i_f_or_d) ? id_Ax_5        : ICP_A5;
    assign Mat1_Ay_0          = (!i_f_or_d) ? id_Ay_0        : 0;
    assign Mat1_Ay_1          = (!i_f_or_d) ? id_Ay_1        : 0;
    assign Mat1_Ay_2          = (!i_f_or_d) ? id_Ay_2        : 0;
    assign Mat1_Ay_3          = (!i_f_or_d) ? id_Ay_3        : 0;
    assign Mat1_Ay_4          = (!i_f_or_d) ? id_Ay_4        : 0;
    assign Mat1_Ay_5          = (!i_f_or_d) ? id_Ay_5        : 0;
    assign Mat1_diffs_x       = (!i_f_or_d) ? id_diffs_x     : ICP_diff_div_w;
    assign Mat1_diffs_y       = (!i_f_or_d) ? id_diffs_y     : 0;
    Matrix u_matrix_1(
        // input
         .i_clk         ( i_clk )
        ,.i_rst_n       ( i_rst_n)
        ,.i_frame_start ( i_Mat1_frame_start )
        ,.i_frame_end   ( i_Mat1_frame_end )
        ,.i_valid       ( Mat1_valid )
        ,.i_Ax_0        ( Mat1_Ax_0 )
        ,.i_Ax_1        ( Mat1_Ax_1 )
        ,.i_Ax_2        ( Mat1_Ax_2 )
        ,.i_Ax_3        ( Mat1_Ax_3 )
        ,.i_Ax_4        ( Mat1_Ax_4 )
        ,.i_Ax_5        ( Mat1_Ax_5 )
        ,.i_Ay_0        ( Mat1_Ay_0 )
        ,.i_Ay_1        ( Mat1_Ay_1 )
        ,.i_Ay_2        ( Mat1_Ay_2 )
        ,.i_Ay_3        ( Mat1_Ay_3 )
        ,.i_Ay_4        ( Mat1_Ay_4 )
        ,.i_Ay_5        ( Mat1_Ay_5 )
        ,.i_diffs_x     ( Mat1_diffs_x )
        ,.i_diffs_y     ( Mat1_diffs_y )
        // Output
        ,.o_frame_end   ( o_Mat1_frame_end )
        ,.o_Mat_00      ( Mat1_00 ) 
        ,.o_Mat_10      ( Mat1_10 ) 
        ,.o_Mat_20      ( Mat1_20 ) 
        ,.o_Mat_30      ( Mat1_30 ) 
        ,.o_Mat_40      ( Mat1_40 ) 
        ,.o_Mat_50      ( Mat1_50 ) 
        ,.o_Mat_11      ( Mat1_11 ) 
        ,.o_Mat_21      ( Mat1_21 ) 
        ,.o_Mat_31      ( Mat1_31 ) 
        ,.o_Mat_41      ( Mat1_41 ) 
        ,.o_Mat_51      ( Mat1_51 ) 
        ,.o_Mat_22      ( Mat1_22 ) 
        ,.o_Mat_32      ( Mat1_32 ) 
        ,.o_Mat_42      ( Mat1_42 ) 
        ,.o_Mat_52      ( Mat1_52 ) 
        ,.o_Mat_33      ( Mat1_33 ) 
        ,.o_Mat_43      ( Mat1_43 ) 
        ,.o_Mat_53      ( Mat1_53 ) 
        ,.o_Mat_44      ( Mat1_44 ) 
        ,.o_Mat_54      ( Mat1_54 ) 
        ,.o_Mat_55      ( Mat1_55 ) 
        ,.o_Vec_0       ( Vec1_0 ) 
        ,.o_Vec_1       ( Vec1_1 ) 
        ,.o_Vec_2       ( Vec1_2 ) 
        ,.o_Vec_3       ( Vec1_3 ) 
        ,.o_Vec_4       ( Vec1_4 ) 
        ,.o_Vec_5       ( Vec1_5 ) 
    );                     
     
    assign i_ldlt_frame_end = (!i_f_or_d) ? o_Mat1_frame_end : Direct_mat_frame_end;
    assign Mat_00           = (!i_f_or_d) ? Mat1_00          : Direct_Mat_00;
    assign Mat_10           = (!i_f_or_d) ? Mat1_10          : Direct_Mat_10;
    assign Mat_20           = (!i_f_or_d) ? Mat1_20          : Direct_Mat_20;
    assign Mat_30           = (!i_f_or_d) ? Mat1_30          : Direct_Mat_30;
    assign Mat_40           = (!i_f_or_d) ? Mat1_40          : Direct_Mat_40;
    assign Mat_50           = (!i_f_or_d) ? Mat1_50          : Direct_Mat_50;
    assign Mat_11           = (!i_f_or_d) ? Mat1_11          : Direct_Mat_11;
    assign Mat_21           = (!i_f_or_d) ? Mat1_21          : Direct_Mat_21;
    assign Mat_31           = (!i_f_or_d) ? Mat1_31          : Direct_Mat_31;
    assign Mat_41           = (!i_f_or_d) ? Mat1_41          : Direct_Mat_41;
    assign Mat_51           = (!i_f_or_d) ? Mat1_51          : Direct_Mat_51;
    assign Mat_22           = (!i_f_or_d) ? Mat1_22          : Direct_Mat_22;
    assign Mat_32           = (!i_f_or_d) ? Mat1_32          : Direct_Mat_32;
    assign Mat_42           = (!i_f_or_d) ? Mat1_42          : Direct_Mat_42;
    assign Mat_52           = (!i_f_or_d) ? Mat1_52          : Direct_Mat_52;
    assign Mat_33           = (!i_f_or_d) ? Mat1_33          : Direct_Mat_33;
    assign Mat_43           = (!i_f_or_d) ? Mat1_43          : Direct_Mat_43;
    assign Mat_53           = (!i_f_or_d) ? Mat1_53          : Direct_Mat_53;
    assign Mat_44           = (!i_f_or_d) ? Mat1_44          : Direct_Mat_44;
    assign Mat_54           = (!i_f_or_d) ? Mat1_54          : Direct_Mat_54;
    assign Mat_55           = (!i_f_or_d) ? Mat1_55          : Direct_Mat_55;
    LDLT u_ldlt (
        // input
         .i_clk         ( i_clk )
        ,.i_rst_n       ( i_rst_n)
        ,.i_start       ( i_ldlt_frame_end )
        ,.i_Mat_00      ( Mat_00 ) 
        ,.i_Mat_10      ( Mat_10 ) 
        ,.i_Mat_20      ( Mat_20 ) 
        ,.i_Mat_30      ( Mat_30 ) 
        ,.i_Mat_40      ( Mat_40 ) 
        ,.i_Mat_50      ( Mat_50 ) 
        ,.i_Mat_11      ( Mat_11 ) 
        ,.i_Mat_21      ( Mat_21 ) 
        ,.i_Mat_31      ( Mat_31 ) 
        ,.i_Mat_41      ( Mat_41 ) 
        ,.i_Mat_51      ( Mat_51 ) 
        ,.i_Mat_22      ( Mat_22 ) 
        ,.i_Mat_32      ( Mat_32 ) 
        ,.i_Mat_42      ( Mat_42 ) 
        ,.i_Mat_52      ( Mat_52 ) 
        ,.i_Mat_33      ( Mat_33 ) 
        ,.i_Mat_43      ( Mat_43 ) 
        ,.i_Mat_53      ( Mat_53 ) 
        ,.i_Mat_44      ( Mat_44 ) 
        ,.i_Mat_54      ( Mat_54 ) 
        ,.i_Mat_55      ( Mat_55 ) 
        // Output 
        ,.o_done        ( ldlt_done )
        ,.o_Mat_00      ( LDLT_Mat_00 ) 
        ,.o_Mat_10      ( LDLT_Mat_10 ) 
        ,.o_Mat_20      ( LDLT_Mat_20 ) 
        ,.o_Mat_30      ( LDLT_Mat_30 ) 
        ,.o_Mat_40      ( LDLT_Mat_40 ) 
        ,.o_Mat_50      ( LDLT_Mat_50 ) 
        ,.o_Mat_11      ( LDLT_Mat_11 ) 
        ,.o_Mat_21      ( LDLT_Mat_21 ) 
        ,.o_Mat_31      ( LDLT_Mat_31 ) 
        ,.o_Mat_41      ( LDLT_Mat_41 ) 
        ,.o_Mat_51      ( LDLT_Mat_51 ) 
        ,.o_Mat_22      ( LDLT_Mat_22 ) 
        ,.o_Mat_32      ( LDLT_Mat_32 ) 
        ,.o_Mat_42      ( LDLT_Mat_42 ) 
        ,.o_Mat_52      ( LDLT_Mat_52 ) 
        ,.o_Mat_33      ( LDLT_Mat_33 ) 
        ,.o_Mat_43      ( LDLT_Mat_43 ) 
        ,.o_Mat_53      ( LDLT_Mat_53 ) 
        ,.o_Mat_44      ( LDLT_Mat_44 ) 
        ,.o_Mat_54      ( LDLT_Mat_54 ) 
        ,.o_Mat_55      ( LDLT_Mat_55 ) 
    );

    assign Vec_0 = (!i_f_or_d) ? Vec1_0 : Direct_Vec_0;
    assign Vec_1 = (!i_f_or_d) ? Vec1_1 : Direct_Vec_1;
    assign Vec_2 = (!i_f_or_d) ? Vec1_2 : Direct_Vec_2;
    assign Vec_3 = (!i_f_or_d) ? Vec1_3 : Direct_Vec_3;
    assign Vec_4 = (!i_f_or_d) ? Vec1_4 : Direct_Vec_4;
    assign Vec_5 = (!i_f_or_d) ? Vec1_5 : Direct_Vec_5;
    Solver u_solver(
        // input
         .i_clk        ( i_clk )
        ,.i_rst_n      ( i_rst_n)
        ,.i_start      ( ldlt_done )
        ,.i_Mat_00     ( LDLT_Mat_00 ) 
        ,.i_Mat_10     ( LDLT_Mat_10 ) 
        ,.i_Mat_20     ( LDLT_Mat_20 ) 
        ,.i_Mat_30     ( LDLT_Mat_30 ) 
        ,.i_Mat_40     ( LDLT_Mat_40 ) 
        ,.i_Mat_50     ( LDLT_Mat_50 ) 
        ,.i_Mat_11     ( LDLT_Mat_11 ) 
        ,.i_Mat_21     ( LDLT_Mat_21 ) 
        ,.i_Mat_31     ( LDLT_Mat_31 ) 
        ,.i_Mat_41     ( LDLT_Mat_41 ) 
        ,.i_Mat_51     ( LDLT_Mat_51 ) 
        ,.i_Mat_22     ( LDLT_Mat_22 ) 
        ,.i_Mat_32     ( LDLT_Mat_32 ) 
        ,.i_Mat_42     ( LDLT_Mat_42 ) 
        ,.i_Mat_52     ( LDLT_Mat_52 ) 
        ,.i_Mat_33     ( LDLT_Mat_33 ) 
        ,.i_Mat_43     ( LDLT_Mat_43 ) 
        ,.i_Mat_53     ( LDLT_Mat_53 ) 
        ,.i_Mat_44     ( LDLT_Mat_44 ) 
        ,.i_Mat_54     ( LDLT_Mat_54 ) 
        ,.i_Mat_55     ( LDLT_Mat_55 ) 
        ,.i_Vec_0      ( Vec_0 ) 
        ,.i_Vec_1      ( Vec_1 ) 
        ,.i_Vec_2      ( Vec_2 ) 
        ,.i_Vec_3      ( Vec_3 ) 
        ,.i_Vec_4      ( Vec_4 ) 
        ,.i_Vec_5      ( Vec_5 ) 
        // Output
        ,.o_done       ( solver_done)
        ,.o_div_zero   (  )
        ,.o_X0         ( X0 )
        ,.o_X1         ( X1 )
        ,.o_X2         ( X2 )
        ,.o_X3         ( X3 )
        ,.o_X4         ( X4 )
        ,.o_X5         ( X5 )
    );

    Rodrigues u_rodrigues(
        // input
         .i_clk        ( i_clk )
        ,.i_rst_n      ( i_rst_n)
        ,.i_start      ( solver_done )
        ,.i_X0         ( X0 )
        ,.i_X1         ( X1 )
        ,.i_X2         ( X2 )
        ,.i_X3         ( X3 )
        ,.i_X4         ( X4 )
        ,.i_X5         ( X5 )
        // Output
        ,.o_done        ( rodrigues_done )
        ,.o_pose        ( pose )
    );

    UpdatePose u_updatepose (
        // input
         .i_clk        ( i_clk )
        ,.i_rst_n      ( i_rst_n)
        ,.i_start      ( rodrigues_done )
        ,.i_delta_pose ( pose )
        ,.i_pose       ( curr_pose )
        // Output
        ,.o_done     ( update_done )
        ,.o_pose     ( update_pose )
    );
    assign o_feature_ready = feature_ready;
    assign o_done = i_f_or_d ? update_done : (update_done && (count_of_f == (i_n_of_f - 1)));
    assign o_pose = update_pose;
    assign o_sigma_icp  = ICP_sigma_r;
    assign o_sigma_rgbd = Rgbd_sigma_r;
    assign o_update_done = update_done;

    //===================
    //    Sequential
    //===================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)                          feature_out <= 0;
        else if (o_done)                       feature_out <= 0;
        else if ((!i_f_or_d) && feature_valid) feature_out <= 1;
        else                                   feature_out <= feature_out;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)           number_feature_match <= 0;
        else if (i_f_or_d)      number_feature_match <= 0;
        else if (feature_valid) number_feature_match <= number_feature_match + 1;
        else                    number_feature_match <= number_feature_match;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)                                           count_of_f <= 0;
        else if (i_f_or_d)                                      count_of_f <= 0;
        else if ((!i_f_or_d) && (update_done) && feature_out)   count_of_f <= count_of_f + 1;
        else                                                    count_of_f <= count_of_f;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)           counter_feature_match <= 0;
        else if (i_f_or_d)      counter_feature_match <= 0;
        else if (update_done)   counter_feature_match <= 0;
        else if (cnt_en)        counter_feature_match <= counter_feature_match + 1;
        else                    counter_feature_match <= counter_feature_match;
    end
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            for(int i = 0; i <= 11; i = i + 1) begin curr_pose[i] <= 0; end
        end
        else if (i_frame_start && (curr_pose[0] == 0)) begin
            for(int i = 0; i <= 11; i = i + 1) begin curr_pose[i] <= i_pose[i]; end
        end
        else if (((feature_out) || (i_f_or_d)) && update_done) begin
            for(int i = 0; i <= 11; i = i + 1) begin curr_pose[i] <= update_pose[i]; end
        end
        else begin
            for(int i = 0; i <= 11; i = i + 1) begin curr_pose[i] <= curr_pose[i]; end
        end
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            u0_r <= 0;
            v0_r <= 0;
            d0_r <= 0;
            u1_r <= 0;
            v1_r <= 0;
        end
        else if (!i_f_or_d) begin
            u0_r <= dstFrame_lb_sram_even_QA[0][H_SIZE_BW-1:0];
            v0_r <= dstFrame_lb_sram_even_QA[1][V_SIZE_BW-1:0];
            d0_r <= dstFrame_lb_sram_even_QA[2][DATA_DEPTH_BW-1:0];
            u1_r <= dstFrame_lb_sram_even_QA[3][H_SIZE_BW-1:0];
            v1_r <= dstFrame_lb_sram_even_QA[4][V_SIZE_BW-1:0];
        end
        else begin
            u0_r <= 0;
            v0_r <= 0;
            d0_r <= 0;
            u1_r <= 0;
            v1_r <= 0;
        end
    end

    //Direct
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) ICP_sigma_r <= 0;
        else if (o_done) ICP_sigma_r <= 0;
        else if (ICP_sigma_frame_end) ICP_sigma_r <= ICP_sigma;
        else ICP_sigma_r <= ICP_sigma_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Rgbd_sigma_r <= 0;
        else if (o_done) Rgbd_sigma_r <= 0;
        else if (Rgbd_sigma_frame_end) Rgbd_sigma_r <= Rgbd_sigma;
        else Rgbd_sigma_r <= Rgbd_sigma_r;
    end

endmodule