// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023

module sigma_rgbd_generator
    import RgbdVoConfigPk::*;
#(
)(  
    //input
     input                            i_clk
    ,input                            i_rst_n
    ,input                            i_frame_end
    ,input        [H_SIZE_BW+V_SIZE_BW+2*DATA_RGB_BW+1:0]    i_sigma_s_rgbd
    ,input        [H_SIZE_BW+V_SIZE_BW-1:0] i_corresp_count
    //output
    ,output logic                     o_frame_end
    ,output logic [DATA_RGB_BW:0]     o_sigma_rgbd
);

    //=================================
    // Signal Declaration
    //=================================
    //dn
    logic                     seq_div_valid;
    logic [H_SIZE_BW+V_SIZE_BW+2*DATA_RGB_BW+1:0]    sigma_ms;

    //dn+1
    logic [H_SIZE_BW+V_SIZE_BW+2*DATA_RGB_BW+1:0]    sigma_ms_r;

    //dn+5
    logic                     div_valid_d5;
    logic [H_SIZE_BW+DATA_RGB_BW:0]    sigma_rgbd_w;

    //dn+6
    logic                     div_valid_d6;
    logic [DATA_RGB_BW:0]     sigma_rgbd_r;

    //=================================
    // Combinational Logic
    //=================================
    //dn
    seq_div_unsign 
    #(
         .DEND_WIDTH(H_SIZE_BW+V_SIZE_BW+2*DATA_RGB_BW+2)
        ,.DSOR_WIDTH(H_SIZE_BW+V_SIZE_BW)
        ,.CNT_WIDTH(6)
    )
    u_seq_div_unsign
    (
        // input
         .i_clk     ( i_clk )
        ,.i_rst_n   ( i_rst_n )
        ,.i_valid   ( i_frame_end )
        ,.i_Dend    ( i_sigma_s_rgbd )
        ,.i_Dsor    ( i_corresp_count )
        // output
        ,.o_valid   ( seq_div_valid )
        ,.o_Quot    ( sigma_ms )
        ,.o_Rder    (  )
    );

    //dn+5
    DW_sqrt_pipe #(
         .width(H_SIZE_BW+V_SIZE_BW+2*DATA_RGB_BW+2)
        ,.tc_mode(1)
        ,.num_stages(5)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_sqrt (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a(sigma_ms_r)
        ,.root(sigma_rgbd_w)
    );

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(5)
    ) u_div_valid_d5 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(seq_div_valid)
        // Output
        ,.o_data(div_valid_d5)
    );

    //dn+6
    assign o_frame_end  = div_valid_d6;
    assign o_sigma_rgbd = sigma_rgbd_r;

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(1)
    ) u_div_valid_d6 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(div_valid_d5)
        // Output
        ,.o_data(div_valid_d6)
    );

    //===================
    //    Sequential
    //===================
    //dn+1
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) sigma_ms_r <= '0;
        else sigma_ms_r <= sigma_ms;
    end

    //dn+6
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) sigma_rgbd_r <= '0;
        else if (div_valid_d5) sigma_rgbd_r <= sigma_rgbd_w[DATA_RGB_BW:0];
        else sigma_rgbd_r <= sigma_rgbd_r;
    end

endmodule