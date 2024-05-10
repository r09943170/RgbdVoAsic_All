// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023

//3T
module gradient
    import RgbdVoConfigPk::*;
#(
)(
    // input
     input                            i_clk
    ,input                            i_rst_n
    ,input                            i_valid
    ,input        [DATA_RGB_BW-1:0]   i_data_0
    ,input        [DATA_RGB_BW-1:0]   i_data_u
    ,input        [DATA_RGB_BW-1:0]   i_data_v
    ,input        [H_SIZE_BW-1:0]     i_u
    ,input        [V_SIZE_BW-1:0]     i_v
    // Register
    ,input        [H_SIZE_BW-1:0]     r_hsize
    ,input        [V_SIZE_BW-1:0]     r_vsize
    // Output
    ,output logic                     o_valid
    ,output logic [DATA_RGB_BW:0]     o_dI_dx
    ,output logic [DATA_RGB_BW:0]     o_dI_dy
);

    //=================================
    // Signal Declaration
    //=================================
    //d1
    logic [DATA_RGB_BW-1:0]   data_0_r;
    logic [DATA_RGB_BW-1:0]   data_u_r;
    logic [DATA_RGB_BW-1:0]   data_v_r;
    logic [H_SIZE_BW-1:0]     u_r;
    logic [V_SIZE_BW-1:0]     v_r;

    logic                     check_edge_u;
    logic                     check_edge_v;
    logic [DATA_RGB_BW:0]     dI_dx_tmp_w;
    logic [DATA_RGB_BW:0]     dI_dy_tmp_w;

    //d2
    logic                     check_edge_u_r;
    logic                     check_edge_v_r;

    logic [DATA_RGB_BW:0]     dI_dx_tmp_r;
    logic [DATA_RGB_BW:0]     dI_dy_tmp_r;

    logic [DATA_RGB_BW:0]     dI_dx_w;
    logic [DATA_RGB_BW:0]     dI_dy_w;

    //d3
    logic [DATA_RGB_BW:0]     dI_dx_r;
    logic [DATA_RGB_BW:0]     dI_dy_r;

    logic                     valid_d3;

    //=================================
    // Combinational Logic
    //=================================
    //d1
    assign check_edge_u = ((u_r == 0) || (u_r >= r_hsize-1)) ? 0 : 1;
    assign check_edge_v = ((v_r == 0) || (v_r >= r_vsize-1)) ? 0 : 1;
    assign dI_dx_tmp_w = data_u_r - data_0_r;
    assign dI_dy_tmp_w = data_v_r - data_0_r;

    //d2
    assign dI_dx_w = check_edge_u_r ? dI_dx_tmp_r : 0;
    assign dI_dy_w = check_edge_v_r ? dI_dy_tmp_r : 0;

    //d3
    assign o_valid = valid_d3;
    assign o_dI_dx = dI_dx_r;
    assign o_dI_dy = dI_dy_r;

    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(3)
    ) u_valid_d3 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(i_valid)
        // Output
        ,.o_data(valid_d3)
    );

    //===================
    //    Sequential
    //===================
    //d1
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) data_0_r <= '0;
        else data_0_r <= i_data_0;  //d1
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) data_u_r <= '0;
        else data_u_r <= i_data_u;  //d1
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) data_v_r <= '0;
        else data_v_r <= i_data_v;  //d1
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) u_r <= '0;
        else u_r <= i_u;  //d1
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) v_r <= '0;
        else v_r <= i_v;  //d1
    end

    //d2
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) check_edge_u_r <= '0;
        else check_edge_u_r <= check_edge_u;  //d2
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) check_edge_v_r <= '0;
        else check_edge_v_r <= check_edge_v;  //d2
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) dI_dx_tmp_r <= '0;
        else dI_dx_tmp_r <= dI_dx_tmp_w;  //d2
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) dI_dy_tmp_r <= '0;
        else dI_dy_tmp_r <= dI_dy_tmp_w;  //d2
    end

    //d3
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) dI_dx_r <= '0;
        else dI_dx_r <= dI_dx_w;  //d3
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) dI_dy_r <= '0;
        else dI_dy_r <= dI_dy_w;  //d3
    end
endmodule

