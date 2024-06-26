// `include "LUT.sv"

module BRIEF
(
    input           i_clk,
    input           i_rst_n,

    input [7:0]     i_window [0:30][0:30],

    input [9:0]     i_coor_x, 
    input [9:0]     i_coor_y, 
    input [7:0]     i_score,
    input [15:0]     i_depth,

    input signed [11:0]    i_sin,
    input signed [11:0]    i_cos,
    input [9:0]     i_buf_coor_x, 
    input [9:0]     i_buf_coor_y, 

    output          o_hit,
    output [9:0]    o_coor_x, 
    output [9:0]    o_coor_y, 
    output [255:0]  o_descriptor,
    output          o_flag,
    output [7:0]    o_score,
    output [15:0]    o_depth

);
    // parameter


    // ========== reg/wire declaration ==========
    integer i;
    genvar idx;
    // logic [7:0] pixel [0:30][0:30];
    logic signed [7:0] x_a [0:255];
    logic signed [7:0] y_a [0:255];
    logic signed [7:0] x_b [0:255];
    logic signed [7:0] y_b [0:255];

    logic signed [17:0] x_a_cos_w [0:255], x_a_cos_r [0:255];
    logic signed [17:0] x_a_sin_w [0:255], x_a_sin_r [0:255];
    logic signed [17:0] y_a_cos_w [0:255], y_a_cos_r [0:255];
    logic signed [17:0] y_a_sin_w [0:255], y_a_sin_r [0:255];
    logic signed [17:0] x_b_cos_w [0:255], x_b_cos_r [0:255];
    logic signed [17:0] x_b_sin_w [0:255], x_b_sin_r [0:255];
    logic signed [17:0] y_b_cos_w [0:255], y_b_cos_r [0:255];
    logic signed [17:0] y_b_sin_w [0:255], y_b_sin_r [0:255];

    // logic signed [19:0] x_a_cos [0:255];
    // logic signed [19:0] x_a_sin [0:255];
    // logic signed [19:0] y_a_cos [0:255];
    // logic signed [19:0] y_a_sin [0:255];
    // logic signed [19:0] x_b_cos [0:255];
    // logic signed [19:0] x_b_sin [0:255];
    // logic signed [19:0] y_b_cos [0:255];
    // logic signed [19:0] y_b_sin [0:255];

    // logic [9:0] coor1_x_w, coor1_x_r;
    // logic [9:0] coor1_y_w, coor1_y_r;
    logic       flag1_w, flag1_r;

    logic signed [8:0] x1_w [0:255], x1_r[0:255];
    logic signed [8:0] x2_w [0:255], x2_r[0:255];
    logic signed [8:0] y1_w [0:255], y1_r[0:255];
    logic signed [8:0] y2_w [0:255], y2_r[0:255];

    logic signed [18:0] x1_mid [0:255], x2_mid [0:255], y1_mid [0:255], y2_mid [0:255];
    logic signed [7:0] x1_shift [0:255], x2_shift [0:255], y1_shift [0:255], y2_shift [0:255];
    logic signed [7:0] x1_search [0:255], x2_search [0:255], y1_search [0:255], y2_search [0:255];
    logic signed [8:0] x1_round [0:255], x2_round [0:255], y1_round [0:255], y2_round [0:255];
    logic [7:0] comp1 [0:255], comp2 [0:255];

    // logic [9:0] coor2_x_w, coor2_x_r;
    // logic [9:0] coor2_y_w, coor2_y_r;
    logic       flag2_w, flag2_r;
    logic [7:0] center;

    logic [255:0] descriptor_w, descriptor_r;

    logic [9:0] coor3_x_w, coor3_x_r;
    logic [9:0] coor3_y_w, coor3_y_r;

    logic [7:0] score1_w, score1_r;
    logic [7:0] score2_w, score2_r;
    logic [7:0] score3_w, score3_r;

    logic [15:0] depth1_w, depth1_r;
    logic [15:0] depth2_w, depth2_r;
    logic [15:0] depth3_w, depth3_r;

    logic       flag3_w, flag3_r;

    generate
        for (idx = 0; idx < 256; idx = idx + 1) begin
            LUT inst(
                .i_num(idx[7:0]),
                .o_xa(x_a[idx]),
                .o_ya(y_a[idx]),
                .o_xb(x_b[idx]),
                .o_yb(y_b[idx])
            );
        end
    endgenerate


    // ========== Combinational Block ==========
    assign o_hit = (i_buf_coor_x == i_coor_x) && (i_buf_coor_y == i_coor_y);
    assign o_coor_x = coor3_x_r;
    assign o_coor_y = coor3_y_r;
    assign o_flag = flag3_r;
    assign o_descriptor = descriptor_r;
    assign o_score = score3_r;
    assign o_depth = depth3_r;

    always_comb begin
        for(int i = 0; i < 256; i = i+1) begin

            x_a_cos_w[i] = (x_a[i]*i_cos);
            x_a_sin_w[i] = (x_a[i]*i_sin);
            y_a_cos_w[i] = (y_a[i]*i_cos);
            y_a_sin_w[i] = (y_a[i]*i_sin);
            x_b_cos_w[i] = (x_b[i]*i_cos);
            x_b_sin_w[i] = (x_b[i]*i_sin);
            y_b_cos_w[i] = (y_b[i]*i_cos);
            y_b_sin_w[i] = (y_b[i]*i_sin);

            // x_a_cos_w[i] = x_a_cos[i][17] ? (x_a_cos[i][17:10] + 1) : x_a_cos[i][17:10];
            // x_a_sin_w[i] = x_a_sin[i][17] ? (x_a_sin[i][17:10] + 1) : x_a_sin[i][17:10];
            // y_a_cos_w[i] = y_a_cos[i][17] ? (y_a_cos[i][17:10] + 1) : y_a_cos[i][17:10];
            // y_a_sin_w[i] = y_a_sin[i][17] ? (y_a_sin[i][17:10] + 1) : y_a_sin[i][17:10];
            // x_b_cos_w[i] = x_b_cos[i][17] ? (x_b_cos[i][17:10] + 1) : x_b_cos[i][17:10];
            // x_b_sin_w[i] = x_b_sin[i][17] ? (x_b_sin[i][17:10] + 1) : x_b_sin[i][17:10];
            // y_b_cos_w[i] = y_b_cos[i][17] ? (y_b_cos[i][17:10] + 1) : y_b_cos[i][17:10];
            // y_b_sin_w[i] = y_b_sin[i][17] ? (y_b_sin[i][17:10] + 1) : y_b_sin[i][17:10];

            x1_mid[i] = x_a_cos_r[i] - y_a_sin_r[i];
            y1_mid[i] = x_a_sin_r[i] + y_a_cos_r[i];
            x2_mid[i] = x_b_cos_r[i] - y_b_sin_r[i];
            y2_mid[i] = x_b_sin_r[i] + y_b_cos_r[i];

            x1_w[i] = x1_mid[i][18] ? (x1_mid[i][18:10] + (x1_mid[i][9] && |x1_mid[i][8:0])) : (x1_mid[i][18:10] + x1_mid[i][9]);
            y1_w[i] = y1_mid[i][18] ? (y1_mid[i][18:10] + (y1_mid[i][9] && |y1_mid[i][8:0])) : (y1_mid[i][18:10] + y1_mid[i][9]);
            x2_w[i] = x2_mid[i][18] ? (x2_mid[i][18:10] + (x2_mid[i][9] && |x2_mid[i][8:0])) : (x2_mid[i][18:10] + x2_mid[i][9]);
            y2_w[i] = y2_mid[i][18] ? (y2_mid[i][18:10] + (y2_mid[i][9] && |y2_mid[i][8:0])) : (y2_mid[i][18:10] + y2_mid[i][9]);
            

            // x1_mid[i] = x_a_cos_r[i] - y_a_sin_r[i] + $signed(8'd15);
            // y1_mid[i] = x_a_sin_r[i] + y_a_cos_r[i] + $signed(8'd15);
            // x2_mid[i] = x_b_cos_r[i] - y_b_sin_r[i] + $signed(8'd15);
            // y2_mid[i] = x_b_sin_r[i] + y_b_cos_r[i] + $signed(8'd15);

            x1_shift[i] = x1_r[i] + $signed(8'd15);
            y1_shift[i] = y1_r[i] + $signed(8'd15);
            x2_shift[i] = x2_r[i] + $signed(8'd15);
            y2_shift[i] = y2_r[i] + $signed(8'd15);

            x1_search[i] = (x1_shift[i] > 30) ? 30 : (x1_shift[i][7] ? 0 : x1_shift[i]);
            y1_search[i] = (y1_shift[i] > 30) ? 30 : (y1_shift[i][7] ? 0 : y1_shift[i]);
            x2_search[i] = (x2_shift[i] > 30) ? 30 : (x2_shift[i][7] ? 0 : x2_shift[i]);
            y2_search[i] = (y2_shift[i] > 30) ? 30 : (y2_shift[i][7] ? 0 : y2_shift[i]);

            comp1[i] = i_window[y1_search[i]][x1_search[i]];
            comp2[i] = i_window[y2_search[i]][x2_search[i]];

            descriptor_w[i] = (flag2_r) ? comp1[i] > comp2[i] : 0;
        end
        // coor1_x_w = ((i_buf_coor_x == i_coor_x) && (i_buf_coor_y == i_coor_y)) ? i_coor_x : 0;
        // coor1_y_w = ((i_buf_coor_x == i_coor_x) && (i_buf_coor_y == i_coor_y)) ? i_coor_y : 0;
        flag1_w = ((i_buf_coor_x == i_coor_x) && (i_buf_coor_y == i_coor_y)) && i_coor_x != 0 && i_coor_y != 0;
        flag2_w = flag1_r;
        flag3_w = flag2_r;
        // coor2_x_w = coor1_x_r;
        // coor2_y_w = coor1_y_r;
        coor3_x_w = flag2_r ? i_coor_x - 2 : 0;
        coor3_y_w = flag2_r ? i_coor_y : 0;

        score1_w = flag1_w ? i_score : 0;
        score2_w = score1_r;
        score3_w = score2_r;

        depth1_w = flag1_w ? i_depth : 0;
        depth2_w = depth1_r;
        depth3_w = depth2_r;
        
    end

    // ========== Sequential Block ==========
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            for(int i = 0; i < 256; i = i+1) begin
                x_a_cos_r[i] <= 0; 
                x_a_sin_r[i] <= 0; 
                y_a_cos_r[i] <= 0; 
                y_a_sin_r[i] <= 0; 
                x_b_cos_r[i] <= 0; 
                x_b_sin_r[i] <= 0; 
                y_b_cos_r[i] <= 0; 
                y_b_sin_r[i] <= 0; 
                x1_r[i] <= 0;
                y1_r[i] <= 0;
                x2_r[i] <= 0;
                y2_r[i] <= 0;
            end
            descriptor_r <= 0;
            // coor1_x_r <= 0;
            // coor1_y_r <= 0;
            // coor2_x_r <= 0;
            // coor2_y_r <= 0;
            coor3_x_r <= 0;
            coor3_y_r <= 0;
            flag1_r <= 0;
            flag2_r <= 0;
            flag3_r <= 0;
            score1_r <= 0;
            score2_r <= 0;
            score3_r <= 0;
            depth1_r <= 0;
            depth2_r <= 0;
            depth3_r <= 0;
        end
        else begin
            for(int i = 0; i < 256; i = i+1) begin
                x_a_cos_r[i] <= x_a_cos_w[i]; 
                x_a_sin_r[i] <= x_a_sin_w[i]; 
                y_a_cos_r[i] <= y_a_cos_w[i]; 
                y_a_sin_r[i] <= y_a_sin_w[i]; 
                x_b_cos_r[i] <= x_b_cos_w[i]; 
                x_b_sin_r[i] <= x_b_sin_w[i]; 
                y_b_cos_r[i] <= y_b_cos_w[i]; 
                y_b_sin_r[i] <= y_b_sin_w[i]; 

                x1_r[i] <= x1_w[i];
                y1_r[i] <= y1_w[i];
                x2_r[i] <= x2_w[i];
                y2_r[i] <= y2_w[i];
            end
            descriptor_r <= descriptor_w;
            // coor1_x_r <= coor1_x_w;
            // coor1_y_r <= coor1_y_w;
            // coor2_x_r <= coor2_x_w;
            // coor2_y_r <= coor2_y_w;
            coor3_x_r <= coor3_x_w;
            coor3_y_r <= coor3_y_w;
            flag1_r <= flag1_w;
            flag2_r <= flag2_w;
            flag3_r <= flag3_w;
            
            score1_r <= score1_w;
            score2_r <= score2_w;
            score3_r <= score3_w;
            depth1_r <= depth1_w;
            depth2_r <= depth2_w;
            depth3_r <= depth3_w;
        end
    end

endmodule
