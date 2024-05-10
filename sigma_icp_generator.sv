// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023

module sigma_icp_generator
    import RgbdVoConfigPk::*;
#(
)(  
    //input
     input                            i_clk
    ,input                            i_rst_n
    ,input                            i_frame_end
    ,input        [4*CLOUD_BW-1:0]    i_sigma_s_icp
    ,input        [H_SIZE_BW+V_SIZE_BW-1:0] i_corresp_count
    //output
    ,output logic                     o_frame_end
    ,output logic [2*CLOUD_BW-1:0]    o_sigma_icp
);

    //=================================
    // Signal Declaration
    //=================================
    //d2
    logic [4*CLOUD_BW-1:0]    sigma_ms;

    //d4
    logic                     frame_end_d4;
    logic [2*CLOUD_BW-1:0]    sigma_icp_w;

    //d5
    logic                     frame_start_d5;
    logic                     frame_end_d5;
    logic                     valid_d5;
    logic [2*CLOUD_BW-1:0]    sigma_icp_r;

    //=================================
    // Combinational Logic
    //=================================
    //d2
    DW_div_pipe #(
         .a_width(4*CLOUD_BW)
        ,.b_width(H_SIZE_BW+V_SIZE_BW)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(3)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_A0 (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a(i_sigma_s_icp)
        ,.b(i_corresp_count)
        ,.quotient(sigma_ms)
        ,.remainder()
        ,.divide_by_0()
    );

    //d4
    DW_sqrt_pipe #(
         .width(4*CLOUD_BW)
        ,.tc_mode(1)
        ,.num_stages(3)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_sqrt (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a(sigma_ms)
        ,.root(sigma_icp_w)
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(4)
    ) u_frame_end_d4 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_frame_end)
        // Output
        ,.o_data(frame_end_d4)
    );

    //d5
    assign o_frame_end   = frame_end_d5;
    assign o_sigma_icp   = sigma_icp_r;

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(1)
    ) u_frame_end_d5 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(frame_end_d4)
        // Output
        ,.o_data(frame_end_d5)
    );

    //===================
    //    Sequential
    //===================
    //d2
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) sigma_icp_r <= '0;
        else if (frame_end_d4) sigma_icp_r <= sigma_icp_w;
        else sigma_icp_r <= sigma_icp_r;
    end

endmodule