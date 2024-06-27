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
    //dn
    logic                     seq_div_valid;
    logic [4*CLOUD_BW-1:0]    sigma_ms;

    //dn+1
    logic [4*CLOUD_BW-1:0]    sigma_ms_r;

    //dn+15
    logic                     div_valid_d15;
    logic [2*CLOUD_BW-1:0]    sigma_icp_w;

    //dn+16
    logic                     div_valid_d16;
    logic [2*CLOUD_BW-1:0]    sigma_icp_r;

    //=================================
    // Combinational Logic
    //=================================
    //dn
    seq_div_unsign 
    #(
         .DEND_WIDTH(4*CLOUD_BW)
        ,.DSOR_WIDTH(H_SIZE_BW+V_SIZE_BW)
        ,.CNT_WIDTH(8)
    )
    u_seq_div_unsign
    (
        // input
         .i_clk     ( i_clk )
        ,.i_rst_n   ( i_rst_n )
        ,.i_valid   ( i_frame_end )
        ,.i_Dend    ( i_sigma_s_icp )
        ,.i_Dsor    ( i_corresp_count )
        // output
        ,.o_valid   ( seq_div_valid )
        ,.o_Quot    ( sigma_ms )
        ,.o_Rder    (  )
    );

    //dn+15
    DW_sqrt_pipe #(
         .width(4*CLOUD_BW)
        ,.tc_mode(1)
        ,.num_stages(15)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_sqrt (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a(sigma_ms_r)
        ,.root(sigma_icp_w)
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(15)
    ) u_div_valid_d15 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(seq_div_valid)
        // Output
        ,.o_data(div_valid_d15)
    );

    //dn+16
    assign o_frame_end = div_valid_d16;
    assign o_sigma_icp = sigma_icp_r;

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(1)
    ) u_div_valid_d16 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(div_valid_d15)
        // Output
        ,.o_data(div_valid_d16)
    );

    //===================
    //    Sequential
    //===================
    //dn+1
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) sigma_ms_r <= '0;
        else sigma_ms_r <= sigma_ms;
    end

    //dn+16
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) sigma_icp_r <= '0;
        else if (div_valid_d15) sigma_icp_r <= sigma_icp_w;
        else sigma_icp_r <= sigma_icp_r;
    end

endmodule