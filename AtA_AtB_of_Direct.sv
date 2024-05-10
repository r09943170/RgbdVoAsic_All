// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023


module AtA_AtB_of_Direct
    import RgbdVoConfigPk::*;
#(
)(
    // input
     input                     i_clk
    ,input                     i_rst_n
    ,input                     i_frame_start
    ,input                     i_frame_end_icp
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_00
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_10
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_20
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_30
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_40
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_50
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_11
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_21
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_31
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_41
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_51
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_22
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_32
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_42
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_52
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_33
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_43
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_53
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_44
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_54
    ,input [MATRIX_BW-1:0]     i_ICP_Mat_55
    ,input [MATRIX_BW-1:0]     i_ICP_Vec_0
    ,input [MATRIX_BW-1:0]     i_ICP_Vec_1
    ,input [MATRIX_BW-1:0]     i_ICP_Vec_2
    ,input [MATRIX_BW-1:0]     i_ICP_Vec_3
    ,input [MATRIX_BW-1:0]     i_ICP_Vec_4
    ,input [MATRIX_BW-1:0]     i_ICP_Vec_5
    ,input                     i_frame_end_rgbd
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_00
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_10
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_20
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_30
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_40
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_50
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_11
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_21
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_31
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_41
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_51
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_22
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_32
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_42
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_52
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_33
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_43
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_53
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_44
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_54
    ,input [MATRIX_BW-1:0]     i_Rgbd_Mat_55
    ,input [MATRIX_BW-1:0]     i_Rgbd_Vec_0
    ,input [MATRIX_BW-1:0]     i_Rgbd_Vec_1
    ,input [MATRIX_BW-1:0]     i_Rgbd_Vec_2
    ,input [MATRIX_BW-1:0]     i_Rgbd_Vec_3
    ,input [MATRIX_BW-1:0]     i_Rgbd_Vec_4
    ,input [MATRIX_BW-1:0]     i_Rgbd_Vec_5
    // Output
    ,output logic                 o_frame_end
    ,output logic [MATRIX_BW-1:0] o_Mat_00  //MATRIX_BW == 64
    ,output logic [MATRIX_BW-1:0] o_Mat_10
    ,output logic [MATRIX_BW-1:0] o_Mat_20
    ,output logic [MATRIX_BW-1:0] o_Mat_30
    ,output logic [MATRIX_BW-1:0] o_Mat_40
    ,output logic [MATRIX_BW-1:0] o_Mat_50
    ,output logic [MATRIX_BW-1:0] o_Mat_11
    ,output logic [MATRIX_BW-1:0] o_Mat_21
    ,output logic [MATRIX_BW-1:0] o_Mat_31
    ,output logic [MATRIX_BW-1:0] o_Mat_41
    ,output logic [MATRIX_BW-1:0] o_Mat_51
    ,output logic [MATRIX_BW-1:0] o_Mat_22
    ,output logic [MATRIX_BW-1:0] o_Mat_32
    ,output logic [MATRIX_BW-1:0] o_Mat_42
    ,output logic [MATRIX_BW-1:0] o_Mat_52
    ,output logic [MATRIX_BW-1:0] o_Mat_33
    ,output logic [MATRIX_BW-1:0] o_Mat_43
    ,output logic [MATRIX_BW-1:0] o_Mat_53
    ,output logic [MATRIX_BW-1:0] o_Mat_44
    ,output logic [MATRIX_BW-1:0] o_Mat_54
    ,output logic [MATRIX_BW-1:0] o_Mat_55
    ,output logic [MATRIX_BW-1:0] o_Vec_0
    ,output logic [MATRIX_BW-1:0] o_Vec_1
    ,output logic [MATRIX_BW-1:0] o_Vec_2
    ,output logic [MATRIX_BW-1:0] o_Vec_3
    ,output logic [MATRIX_BW-1:0] o_Vec_4
    ,output logic [MATRIX_BW-1:0] o_Vec_5
);

    //=================================
    // Signal Declaration
    //=================================
    logic [1:0]               curr_st;
    logic [1:0]               next_st;
    logic [MATRIX_BW-1:0]     Mat_00_r;
    logic [MATRIX_BW-1:0]     Mat_10_r;
    logic [MATRIX_BW-1:0]     Mat_20_r;
    logic [MATRIX_BW-1:0]     Mat_30_r;
    logic [MATRIX_BW-1:0]     Mat_40_r;
    logic [MATRIX_BW-1:0]     Mat_50_r;
    logic [MATRIX_BW-1:0]     Mat_11_r;
    logic [MATRIX_BW-1:0]     Mat_21_r;
    logic [MATRIX_BW-1:0]     Mat_31_r;
    logic [MATRIX_BW-1:0]     Mat_41_r;
    logic [MATRIX_BW-1:0]     Mat_51_r;
    logic [MATRIX_BW-1:0]     Mat_22_r;
    logic [MATRIX_BW-1:0]     Mat_32_r;
    logic [MATRIX_BW-1:0]     Mat_42_r;
    logic [MATRIX_BW-1:0]     Mat_52_r;
    logic [MATRIX_BW-1:0]     Mat_33_r;
    logic [MATRIX_BW-1:0]     Mat_43_r;
    logic [MATRIX_BW-1:0]     Mat_53_r;
    logic [MATRIX_BW-1:0]     Mat_44_r;
    logic [MATRIX_BW-1:0]     Mat_54_r;
    logic [MATRIX_BW-1:0]     Mat_55_r;
    logic [MATRIX_BW-1:0]     Vec_0_r;
    logic [MATRIX_BW-1:0]     Vec_1_r;
    logic [MATRIX_BW-1:0]     Vec_2_r;
    logic [MATRIX_BW-1:0]     Vec_3_r;
    logic [MATRIX_BW-1:0]     Vec_4_r;
    logic [MATRIX_BW-1:0]     Vec_5_r;
    
    //=================================
    // Combinational Logic
    //=================================
    assign o_frame_end = (curr_st == 2'd3) ? 1 : 0;
    assign o_Mat_00 = Mat_00_r;
    assign o_Mat_10 = Mat_10_r;
    assign o_Mat_20 = Mat_20_r;
    assign o_Mat_30 = Mat_30_r;
    assign o_Mat_40 = Mat_40_r;
    assign o_Mat_50 = Mat_50_r;
    assign o_Mat_11 = Mat_11_r;
    assign o_Mat_21 = Mat_21_r;
    assign o_Mat_31 = Mat_31_r;
    assign o_Mat_41 = Mat_41_r;
    assign o_Mat_51 = Mat_51_r;
    assign o_Mat_22 = Mat_22_r;
    assign o_Mat_32 = Mat_32_r;
    assign o_Mat_42 = Mat_42_r;
    assign o_Mat_52 = Mat_52_r;
    assign o_Mat_33 = Mat_33_r;
    assign o_Mat_43 = Mat_43_r;
    assign o_Mat_53 = Mat_53_r;
    assign o_Mat_44 = Mat_44_r;
    assign o_Mat_54 = Mat_54_r;
    assign o_Mat_55 = Mat_55_r;
    assign o_Vec_0 = Vec_0_r;
    assign o_Vec_1 = Vec_1_r;
    assign o_Vec_2 = Vec_2_r;
    assign o_Vec_3 = Vec_3_r;
    assign o_Vec_4 = Vec_4_r;
    assign o_Vec_5 = Vec_5_r;

    always_comb begin
        case (curr_st)
            2'd0 : begin
                if      (i_frame_end_icp)  next_st = 2'd1;
                else if (i_frame_end_rgbd) next_st = 2'd2;
                else next_st = curr_st;
            end
            2'd1 : begin
                if (i_frame_end_rgbd) next_st = 2'd3;
                else next_st = curr_st;
            end
            2'd2 : begin
                if (i_frame_end_icp) next_st = 2'd3;
                else next_st = curr_st;
            end
            2'd3 : begin
                next_st = 2'd0;
            end
            default : begin
                next_st = 2'd0;
            end
        endcase
    end

    //===================
    //    Sequential
    //===================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) curr_st <= 0;
        else curr_st <= next_st;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_00_r <= 0;
        else if (i_frame_start) Mat_00_r <= 0;
        else if (i_frame_end_icp)  Mat_00_r = Mat_00_r + i_ICP_Mat_00;
        else if (i_frame_end_rgbd) Mat_00_r = Mat_00_r + i_Rgbd_Mat_00;
        else Mat_00_r <= Mat_00_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_10_r <= 0;
        else if (i_frame_start) Mat_10_r <= 0;
        else if (i_frame_end_icp)  Mat_10_r = Mat_10_r + i_ICP_Mat_10;
        else if (i_frame_end_rgbd) Mat_10_r = Mat_10_r + i_Rgbd_Mat_10;
        else Mat_10_r <= Mat_10_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_20_r <= 0;
        else if (i_frame_start) Mat_20_r <= 0;
        else if (i_frame_end_icp)  Mat_20_r = Mat_20_r + i_ICP_Mat_20;
        else if (i_frame_end_rgbd) Mat_20_r = Mat_20_r + i_Rgbd_Mat_20;
        else Mat_20_r <= Mat_20_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_30_r <= 0;
        else if (i_frame_start) Mat_30_r <= 0;
        else if (i_frame_end_icp)  Mat_30_r = Mat_30_r + i_ICP_Mat_30;
        else if (i_frame_end_rgbd) Mat_30_r = Mat_30_r + i_Rgbd_Mat_30;
        else Mat_30_r <= Mat_30_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_40_r <= 0;
        else if (i_frame_start) Mat_40_r <= 0;
        else if (i_frame_end_icp)  Mat_40_r = Mat_40_r + i_ICP_Mat_40;
        else if (i_frame_end_rgbd) Mat_40_r = Mat_40_r + i_Rgbd_Mat_40;
        else Mat_40_r <= Mat_40_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_50_r <= 0;
        else if (i_frame_start) Mat_50_r <= 0;
        else if (i_frame_end_icp)  Mat_50_r = Mat_50_r + i_ICP_Mat_50;
        else if (i_frame_end_rgbd) Mat_50_r = Mat_50_r + i_Rgbd_Mat_50;
        else Mat_50_r <= Mat_50_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_11_r <= 0;
        else if (i_frame_start) Mat_11_r <= 0;
        else if (i_frame_end_icp)  Mat_11_r = Mat_11_r + i_ICP_Mat_11;
        else if (i_frame_end_rgbd) Mat_11_r = Mat_11_r + i_Rgbd_Mat_11;
        else Mat_11_r <= Mat_11_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_21_r <= 0;
        else if (i_frame_start) Mat_21_r <= 0;
        else if (i_frame_end_icp)  Mat_21_r = Mat_21_r + i_ICP_Mat_21;
        else if (i_frame_end_rgbd) Mat_21_r = Mat_21_r + i_Rgbd_Mat_21;
        else Mat_21_r <= Mat_21_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_31_r <= 0;
        else if (i_frame_start) Mat_31_r <= 0;
        else if (i_frame_end_icp)  Mat_31_r = Mat_31_r + i_ICP_Mat_31;
        else if (i_frame_end_rgbd) Mat_31_r = Mat_31_r + i_Rgbd_Mat_31;
        else Mat_31_r <= Mat_31_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_41_r <= 0;
        else if (i_frame_start) Mat_41_r <= 0;
        else if (i_frame_end_icp)  Mat_41_r = Mat_41_r + i_ICP_Mat_41;
        else if (i_frame_end_rgbd) Mat_41_r = Mat_41_r + i_Rgbd_Mat_41;
        else Mat_41_r <= Mat_41_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_51_r <= 0;
        else if (i_frame_start) Mat_51_r <= 0;
        else if (i_frame_end_icp)  Mat_51_r = Mat_51_r + i_ICP_Mat_51;
        else if (i_frame_end_rgbd) Mat_51_r = Mat_51_r + i_Rgbd_Mat_51;
        else Mat_51_r <= Mat_51_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_22_r <= 0;
        else if (i_frame_start) Mat_22_r <= 0;
        else if (i_frame_end_icp)  Mat_22_r = Mat_22_r + i_ICP_Mat_22;
        else if (i_frame_end_rgbd) Mat_22_r = Mat_22_r + i_Rgbd_Mat_22;
        else Mat_22_r <= Mat_22_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_32_r <= 0;
        else if (i_frame_start) Mat_32_r <= 0;
        else if (i_frame_end_icp)  Mat_32_r = Mat_32_r + i_ICP_Mat_32;
        else if (i_frame_end_rgbd) Mat_32_r = Mat_32_r + i_Rgbd_Mat_32;
        else Mat_32_r <= Mat_32_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_42_r <= 0;
        else if (i_frame_start) Mat_42_r <= 0;
        else if (i_frame_end_icp)  Mat_42_r = Mat_42_r + i_ICP_Mat_42;
        else if (i_frame_end_rgbd) Mat_42_r = Mat_42_r + i_Rgbd_Mat_42;
        else Mat_42_r <= Mat_42_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_52_r <= 0;
        else if (i_frame_start) Mat_52_r <= 0;
        else if (i_frame_end_icp)  Mat_52_r = Mat_52_r + i_ICP_Mat_52;
        else if (i_frame_end_rgbd) Mat_52_r = Mat_52_r + i_Rgbd_Mat_52;
        else Mat_52_r <= Mat_52_r;
    end
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_33_r <= 0;
        else if (i_frame_start) Mat_33_r <= 0;
        else if (i_frame_end_icp)  Mat_33_r = Mat_33_r + i_ICP_Mat_33;
        else if (i_frame_end_rgbd) Mat_33_r = Mat_33_r + i_Rgbd_Mat_33;
        else Mat_33_r <= Mat_33_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_43_r <= 0;
        else if (i_frame_start) Mat_43_r <= 0;
        else if (i_frame_end_icp)  Mat_43_r = Mat_43_r + i_ICP_Mat_43;
        else if (i_frame_end_rgbd) Mat_43_r = Mat_43_r + i_Rgbd_Mat_43;
        else Mat_43_r <= Mat_43_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_53_r <= 0;
        else if (i_frame_start) Mat_53_r <= 0;
        else if (i_frame_end_icp)  Mat_53_r = Mat_53_r + i_ICP_Mat_53;
        else if (i_frame_end_rgbd) Mat_53_r = Mat_53_r + i_Rgbd_Mat_53;
        else Mat_53_r <= Mat_53_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_44_r <= 0;
        else if (i_frame_start) Mat_44_r <= 0;
        else if (i_frame_end_icp)  Mat_44_r = Mat_44_r + i_ICP_Mat_44;
        else if (i_frame_end_rgbd) Mat_44_r = Mat_44_r + i_Rgbd_Mat_44;
        else Mat_44_r <= Mat_44_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_54_r <= 0;
        else if (i_frame_start) Mat_54_r <= 0;
        else if (i_frame_end_icp)  Mat_54_r = Mat_54_r + i_ICP_Mat_54;
        else if (i_frame_end_rgbd) Mat_54_r = Mat_54_r + i_Rgbd_Mat_54;
        else Mat_54_r <= Mat_54_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Mat_55_r <= 0;
        else if (i_frame_start) Mat_55_r <= 0;
        else if (i_frame_end_icp)  Mat_55_r = Mat_55_r + i_ICP_Mat_55;
        else if (i_frame_end_rgbd) Mat_55_r = Mat_55_r + i_Rgbd_Mat_55;
        else Mat_55_r <= Mat_55_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Vec_0_r <= 0;
        else if (i_frame_start) Vec_0_r <= 0;
        else if (i_frame_end_icp)  Vec_0_r = Vec_0_r + i_ICP_Vec_0;
        else if (i_frame_end_rgbd) Vec_0_r = Vec_0_r + i_Rgbd_Vec_0;
        else Vec_0_r <= Vec_0_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Vec_1_r <= 0;
        else if (i_frame_start) Vec_1_r <= 0;
        else if (i_frame_end_icp)  Vec_1_r = Vec_1_r + i_ICP_Vec_1;
        else if (i_frame_end_rgbd) Vec_1_r = Vec_1_r + i_Rgbd_Vec_1;
        else Vec_1_r <= Vec_1_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Vec_2_r <= 0;
        else if (i_frame_start) Vec_2_r <= 0;
        else if (i_frame_end_icp)  Vec_2_r = Vec_2_r + i_ICP_Vec_2;
        else if (i_frame_end_rgbd) Vec_2_r = Vec_2_r + i_Rgbd_Vec_2;
        else Vec_2_r <= Vec_2_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Vec_3_r <= 0;
        else if (i_frame_start) Vec_3_r <= 0;
        else if (i_frame_end_icp)  Vec_3_r = Vec_3_r + i_ICP_Vec_3;
        else if (i_frame_end_rgbd) Vec_3_r = Vec_3_r + i_Rgbd_Vec_3;
        else Vec_3_r <= Vec_3_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Vec_4_r <= 0;
        else if (i_frame_start) Vec_4_r <= 0;
        else if (i_frame_end_icp)  Vec_4_r = Vec_4_r + i_ICP_Vec_4;
        else if (i_frame_end_rgbd) Vec_4_r = Vec_4_r + i_Rgbd_Vec_4;
        else Vec_4_r <= Vec_4_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) Vec_5_r <= 0;
        else if (i_frame_start) Vec_5_r <= 0;
        else if (i_frame_end_icp)  Vec_5_r = Vec_5_r + i_ICP_Vec_5;
        else if (i_frame_end_rgbd) Vec_5_r = Vec_5_r + i_Rgbd_Vec_5;
        else Vec_5_r <= Vec_5_r;
    end

endmodule

