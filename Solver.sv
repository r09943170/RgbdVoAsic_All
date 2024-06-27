// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023


module Solver
    import RgbdVoConfigPk::*;   //MUL = 24, MATRIX_BW = 64
#(
)(
    // input
     input                 i_clk
    ,input                 i_rst_n
    ,input                 i_start
    // Mat D, L
    ,input [MATRIX_BW-1:0] i_Mat_00
    ,input [MATRIX_BW-1:0] i_Mat_10
    ,input [MATRIX_BW-1:0] i_Mat_20
    ,input [MATRIX_BW-1:0] i_Mat_30
    ,input [MATRIX_BW-1:0] i_Mat_40
    ,input [MATRIX_BW-1:0] i_Mat_50
    ,input [MATRIX_BW-1:0] i_Mat_11
    ,input [MATRIX_BW-1:0] i_Mat_21
    ,input [MATRIX_BW-1:0] i_Mat_31
    ,input [MATRIX_BW-1:0] i_Mat_41
    ,input [MATRIX_BW-1:0] i_Mat_51
    ,input [MATRIX_BW-1:0] i_Mat_22
    ,input [MATRIX_BW-1:0] i_Mat_32
    ,input [MATRIX_BW-1:0] i_Mat_42
    ,input [MATRIX_BW-1:0] i_Mat_52
    ,input [MATRIX_BW-1:0] i_Mat_33
    ,input [MATRIX_BW-1:0] i_Mat_43
    ,input [MATRIX_BW-1:0] i_Mat_53
    ,input [MATRIX_BW-1:0] i_Mat_44
    ,input [MATRIX_BW-1:0] i_Mat_54
    ,input [MATRIX_BW-1:0] i_Mat_55
    //Vec b
    ,input [MATRIX_BW-1:0] i_Vec_0
    ,input [MATRIX_BW-1:0] i_Vec_1
    ,input [MATRIX_BW-1:0] i_Vec_2
    ,input [MATRIX_BW-1:0] i_Vec_3
    ,input [MATRIX_BW-1:0] i_Vec_4
    ,input [MATRIX_BW-1:0] i_Vec_5
    // Output X
    ,output logic                 o_done
    ,output logic                 o_div_zero
    ,output logic [MATRIX_BW-1:0] o_X0
    ,output logic [MATRIX_BW-1:0] o_X1
    ,output logic [MATRIX_BW-1:0] o_X2
    ,output logic [MATRIX_BW-1:0] o_X3
    ,output logic [MATRIX_BW-1:0] o_X4
    ,output logic [MATRIX_BW-1:0] o_X5
);

    //=================================
    // Signal Declaration
    //=================================
    localparam IDLE = 1'b0 , BUSY = 1'b1;
    logic  state_r, state_w;
    logic signed [MATRIX_BW - 1 : 0] X_r [6];	
    logic signed [2 * MATRIX_BW - 1 : 0] X_w [6];
    logic signed [MATRIX_BW - 1 : 0] D_w [6];	
    logic signed [MATRIX_BW - 1 : 0] L_w [15];	
    logic signed [MATRIX_BW - 1 : 0] D_r [6];	
    logic signed [MATRIX_BW - 1 : 0] L_r [15];	
    logic [9:0] cnt_r, cnt_w;
    genvar i;
    integer j, m, n;
    logic signed [MATRIX_BW+MUL-1:0] a;
    logic signed [MATRIX_BW-1:0] b;
    logic        div_i_valid;
    logic        div_o_valid;
    logic signed [MATRIX_BW+MUL-1:0] quotient;
    logic signed [MATRIX_BW-1:0] c, d;
    logic signed [MATRIX_BW+MATRIX_BW-1:0] product;
    logic signed [MATRIX_BW+MATRIX_BW:0] product_add;
    logic signed [MATRIX_BW+MATRIX_BW-MUL:0] product_shift_r;
    logic  done_r;

    //=================================
    // Combinational Logic
    //=================================
    assign cnt_w = (state_r == IDLE)? 0: cnt_r + 1;
    assign o_done = done_r;
    assign o_X0 = X_r[0];
    assign o_X1 = X_r[1];
    assign o_X2 = X_r[2];
    assign o_X3 = X_r[3];
    assign o_X4 = X_r[4];
    assign o_X5 = X_r[5];

    assign product_add = product + $signed({1'b0,{MUL{1'b1}}});

    always_comb begin   //state_w
    	case(state_r)
    		IDLE : begin if(i_start == 1) state_w = BUSY; else state_w = IDLE; end
    		BUSY : begin if(done_r == 1) state_w = IDLE; else state_w = BUSY; end
    		default : state_w = IDLE;
    	endcase
    end

    always_comb begin
        case(cnt_r)
            // yi/Di, from last
            'd18 : begin a = {X_r[5],{MUL{1'b0}}}; b = D_r[5]; div_i_valid = '1; end   //X[5] = (y[5]/D[5])
            'd108: begin a = {X_r[4],{MUL{1'b0}}}; b = D_r[4]; div_i_valid = '1; end   //X[4] = (y[4]/D[4]) - L[5,4]*X[5]
            'd198: begin a = {X_r[3],{MUL{1'b0}}}; b = D_r[3]; div_i_valid = '1; end   //X[3] = (y[3]/D[3]) - L[5,3]*X[5] - L[4,3]*X[4]
            'd288: begin a = {X_r[2],{MUL{1'b0}}}; b = D_r[2]; div_i_valid = '1; end   //X[2] = (y[2]/D[2]) - L[5,2]*X[5] - L[4,2]*X[4] - L[3,2]*X[3]
            'd378: begin a = {X_r[1],{MUL{1'b0}}}; b = D_r[1]; div_i_valid = '1; end   //X[1] = (y[1]/D[1]) - L[5,1]*X[5] - L[4,1]*X[4] - L[3,1]*X[3] - L[2,1]*X[2]
            'd468: begin a = {X_r[0],{MUL{1'b0}}}; b = D_r[0]; div_i_valid = '1; end   //X[0] = (y[0]/D[0]) - L[5,0]*X[5] - L[4,0]*X[4] - L[3,0]*X[3] - L[2,0]*X[2] - L[1,0]*X[1]
            default: begin a = '0; b = '1; div_i_valid = '0; end
        endcase
    end
    
    seq_div_sign 
    #(
         .DEND_WIDTH(MATRIX_BW+MUL)
        ,.DSOR_WIDTH(MATRIX_BW)
        ,.CNT_WIDTH(7)
    )
    u_seq_div_sign
    (
        // input
         .i_clk     ( i_clk )
        ,.i_rst_n   ( i_rst_n )
        ,.i_valid   ( div_i_valid )
        ,.i_Dend    ( a )
        ,.i_Dsor    ( b )
        // output
        ,.o_valid   ( div_o_valid )
        ,.o_Quot    ( quotient )
        ,.o_Rder    (  )
    );

    always_comb begin
        case(cnt_r)
            // Ly=b
            'd1  : begin c = L_r[0] ; d = X_r[0]; end    //L[1,0]*y[0]
            'd2  : begin c = L_r[1] ; d = X_r[0]; end    //L[2,0]*y[0]
            'd3  : begin c = L_r[3] ; d = X_r[0]; end    //L[3,0]*y[0]
            'd4  : begin c = L_r[2] ; d = X_r[1]; end    //L[2,1]*y[1]
            'd5  : begin c = L_r[4] ; d = X_r[1]; end    //L[3,1]*y[1]
            'd6  : begin c = L_r[6] ; d = X_r[0]; end    //L[4,0]*y[0]
            'd7  : begin c = L_r[5] ; d = X_r[2]; end    //L[3,2]*y[2]
            'd8  : begin c = L_r[7] ; d = X_r[1]; end    //L[4,1]*y[1]
            'd9  : begin c = L_r[8] ; d = X_r[2]; end    //L[4,2]*y[2]
            'd10 : begin c = L_r[9] ; d = X_r[3]; end    //L[4,3]*y[3]
            'd11 : begin c = L_r[10]; d = X_r[0]; end    //L[5,0]*y[0]
            'd12 : begin c = L_r[11]; d = X_r[1]; end    //L[5,1]*y[1]
            'd13 : begin c = L_r[12]; d = X_r[2]; end    //L[5,2]*y[2]
            'd14 : begin c = L_r[13]; d = X_r[3]; end    //L[5,3]*y[3]
            'd15 : begin c = L_r[14]; d = X_r[4]; end    //L[5,4]*y[4]
            // DL'x=y
            'd196: begin c = L_r[14]; d = X_r[5]; end    //L[5,4]*x[5]
            'd286: begin c = L_r[13]; d = X_r[5]; end    //L[5,3]*x[5]
            'd287: begin c = L_r[9] ; d = X_r[4]; end    //L[4,3]*x[4]
            'd376: begin c = L_r[12]; d = X_r[5]; end    //L[5,2]*x[5]
            'd377: begin c = L_r[8] ; d = X_r[4]; end    //L[4,2]*x[4]
            'd378: begin c = L_r[5] ; d = X_r[3]; end    //L[3,2]*x[3]
            'd466: begin c = L_r[11]; d = X_r[5]; end    //L[5,1]*x[5]
            'd467: begin c = L_r[7] ; d = X_r[4]; end    //L[4,1]*x[4]
            'd468: begin c = L_r[4] ; d = X_r[3]; end    //L[3,1]*x[3]
            'd469: begin c = L_r[2] ; d = X_r[2]; end    //L[2,1]*x[2]
            'd556: begin c = L_r[10]; d = X_r[5]; end    //L[5,0]*x[5]
            'd557: begin c = L_r[6] ; d = X_r[4]; end    //L[4,0]*x[4]
            'd558: begin c = L_r[3] ; d = X_r[3]; end    //L[3,0]*x[3]
            'd559: begin c = L_r[1] ; d = X_r[2]; end    //L[2,0]*x[2]
            'd560: begin c = L_r[0] ; d = X_r[1]; end    //L[1,0]*x[1]
            default: begin c = '0; d = '0; end
        endcase
    end

    DW02_mult_2_stage #(
         .A_width(MATRIX_BW)
        ,.B_width(MATRIX_BW)
    ) u_mult (
         .A(c)
        ,.B(d)
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(product)
    );

    always_comb begin
        if(state_r == IDLE) begin
            X_w[0]  = i_Vec_0;  //y[0] = B[0]
            X_w[1]  = i_Vec_1;
            X_w[2]  = i_Vec_2;
            X_w[3]  = i_Vec_3;
            X_w[4]  = i_Vec_4;
            X_w[5]  = i_Vec_5;
	end
        else begin
            for (j= 0; j < 6 ; j = j + 1) 
                X_w[j] = X_r[j];				
            case(cnt_r)
                // Ly=b
                'd3  : X_w[1] = X_r[1] - product_shift_r; //y[1] = B[1] (- L[1,0]*y[0])
                'd4  : X_w[2] = X_r[2] - product_shift_r; //y[2] = B[2] (- L[2,0]*y[0]) - L[2,1]*y[1]
                'd5  : X_w[3] = X_r[3] - product_shift_r; //y[3] = B[3] (- L[3,0]*y[0]) - L[3,1]*y[1] - L[3,2]*y[2]
                'd6  : X_w[2] = X_r[2] - product_shift_r; //y[2] = B[2] - L[2,0]*y[0] (- L[2,1]*y[1])
                'd7  : X_w[3] = X_r[3] - product_shift_r; //y[3] = B[3] - L[3,0]*y[0] (- L[3,1]*y[1]) - L[3,2]*y[2]
                'd8  : X_w[4] = X_r[4] - product_shift_r; //y[4] = B[4] (- L[4,0]*y[0]) - L[4,1]*y[1] - L[4,2]*y[2] - L[4,3]*y[3]
                'd9  : X_w[3] = X_r[3] - product_shift_r; //y[3] = B[3] - L[3,0]*y[0] - L[3,1]*y[1] (- L[3,2]*y[2])
                'd10 : X_w[4] = X_r[4] - product_shift_r; //y[4] = B[4] - L[4,0]*y[0] (- L[4,1]*y[1]) - L[4,2]*y[2] - L[4,3]*y[3]
                'd11 : X_w[4] = X_r[4] - product_shift_r; //y[4] = B[4] - L[4,0]*y[0] - L[4,1]*y[1] (- L[4,2]*y[2]) - L[4,3]*y[3]
                'd12 : X_w[4] = X_r[4] - product_shift_r; //y[4] = B[4] - L[4,0]*y[0] - L[4,1]*y[1] - L[4,2]*y[2] (- L[4,3]*y[3])
                'd13 : X_w[5] = X_r[5] - product_shift_r; //y[5] = B[5] (- L[5,0]*y[0]) - L[5,1]*y[1] - L[5,2]*y[2] - L[5,3]*y[3] - L[5,4]*y[4]
                'd14 : X_w[5] = X_r[5] - product_shift_r; //y[5] = B[5] - L[5,0]*y[0] (- L[5,1]*y[1]) - L[5,2]*y[2] - L[5,3]*y[3] - L[5,4]*y[4]
                'd15 : X_w[5] = X_r[5] - product_shift_r; //y[5] = B[5] - L[5,0]*y[0] - L[5,1]*y[1] (- L[5,2]*y[2]) - L[5,3]*y[3] - L[5,4]*y[4]
                'd16 : X_w[5] = X_r[5] - product_shift_r; //y[5] = B[5] - L[5,0]*y[0] - L[5,1]*y[1] - L[5,2]*y[2] (- L[5,3]*y[3]) - L[5,4]*y[4]
                'd17 : X_w[5] = X_r[5] - product_shift_r; //y[5] = B[5] - L[5,0]*y[0] - L[5,1]*y[1] - L[5,2]*y[2] - L[5,3]*y[3] (- L[5,4]*y[4])
                // DL'x=y
                'd107: X_w[5] = quotient;                 //X[5] = (y[5]/D[5])
                'd197: X_w[4] = quotient;                 //X[4] = (y[4]/D[4]) - L[5,4]*X[5]
                'd198: X_w[4] = X_r[4] - product_shift_r; //X[4] = y[4]/D[4] (- L[5,4]*X[5])
                'd287: X_w[3] = quotient;                 //X[3] = (y[3]/D[3]) - L[5,3]*X[5] - L[4,3]*X[4]
                'd288: X_w[3] = X_r[3] - product_shift_r; //X[3] = y[3]/D[3] (- L[5,3]*X[5]) - L[4,3]*X[4]
                'd289: X_w[3] = X_r[3] - product_shift_r; //X[3] = y[3]/D[3] - L[5,3]*X[5] (- L[4,3]*X[4])
                'd377: X_w[2] = quotient;                 //X[2] = (y[2]/D[2]) - L[5,2]*X[5] - L[4,2]*X[4] - L[3,2]*X[3]
                'd378: X_w[2] = X_r[2] - product_shift_r; //X[2] = y[2]/D[2] (- L[5,2]*X[5]) - L[4,2]*X[4] - L[3,2]*X[3]
                'd379: X_w[2] = X_r[2] - product_shift_r; //X[2] = y[2]/D[2] - L[5,2]*X[5] (- L[4,2]*X[4]) - L[3,2]*X[3]
                'd380: X_w[2] = X_r[2] - product_shift_r; //X[2] = y[2]/D[2] - L[5,2]*X[5] - L[4,2]*X[4] (- L[3,2]*X[3])
                'd467: X_w[1] = quotient;                 //X[1] = (y[1]/D[1]) - L[5,1]*X[5] - L[4,1]*X[4] - L[3,1]*X[3] - L[2,1]*X[2]
                'd468: X_w[1] = X_r[1] - product_shift_r; //X[1] = y[1]/D[1] (- L[5,1]*X[5]) - L[4,1]*X[4] - L[3,1]*X[3] - L[2,1]*X[2]
                'd469: X_w[1] = X_r[1] - product_shift_r; //X[1] = y[1]/D[1] - L[5,1]*X[5] (- L[4,1]*X[4]) - L[3,1]*X[3] - L[2,1]*X[2]
                'd470: X_w[1] = X_r[1] - product_shift_r; //X[1] = y[1]/D[1] - L[5,1]*X[5] - L[4,1]*X[4] (- L[3,1]*X[3]) - L[2,1]*X[2]
                'd471: X_w[1] = X_r[1] - product_shift_r; //X[1] = y[1]/D[1] - L[5,1]*X[5] - L[4,1]*X[4] - L[3,1]*X[3] (- L[2,1]*X[2])
                'd557: X_w[0] = quotient;                 //X[0] = (y[0]/D[0]) - L[5,0]*X[5] - L[4,0]*X[4] - L[3,0]*X[3] - L[2,0]*X[2] - L[1,0]*X[1]
                'd558: X_w[0] = X_r[0] - product_shift_r; //X[0] = y[0]/D[0] (- L[5,0]*X[5]) - L[4,0]*X[4] - L[3,0]*X[3] - L[2,0]*X[2] - L[1,0]*X[1]
                'd559: X_w[0] = X_r[0] - product_shift_r; //X[0] = y[0]/D[0] - L[5,0]*X[5] (- L[4,0]*X[4]) - L[3,0]*X[3] - L[2,0]*X[2] - L[1,0]*X[1]
                'd560: X_w[0] = X_r[0] - product_shift_r; //X[0] = y[0]/D[0] - L[5,0]*X[5] - L[4,0]*X[4] (- L[3,0]*X[3]) - L[2,0]*X[2] - L[1,0]*X[1]
                'd561: X_w[0] = X_r[0] - product_shift_r; //X[0] = y[0]/D[0] - L[5,0]*X[5] - L[4,0]*X[4] - L[3,0]*X[3] (- L[2,0]*X[2]) - L[1,0]*X[1]
                'd562: X_w[0] = X_r[0] - product_shift_r; //X[0] = y[0]/D[0] - L[5,0]*X[5] - L[4,0]*X[4] - L[3,0]*X[3] - L[2,0]*X[2] (- L[1,0]*X[1])
                default: begin for (j = 0; j < 6 ; j = j + 1) X_w[j] = X_r[j]; end
            endcase			
        end
    end
	
    always_comb begin
        if(i_start) begin
            D_w[0] = i_Mat_00;
            D_w[1] = i_Mat_11;
            D_w[2] = i_Mat_22;
            D_w[3] = i_Mat_33;
            D_w[4] = i_Mat_44;
            D_w[5] = i_Mat_55;
	end
        else begin
            for (m= 0; m < 6 ; m = m + 1) 
                D_w[m] = D_r[m];				
        end
    end
	
    always_comb begin
        if(i_start) begin
            L_w[0] =  i_Mat_10;
            L_w[1] =  i_Mat_20;
            L_w[2] =  i_Mat_21;
            L_w[3] =  i_Mat_30;
            L_w[4] =  i_Mat_31;
            L_w[5] =  i_Mat_32;
            L_w[6] =  i_Mat_40;
            L_w[7] =  i_Mat_41;
            L_w[8] =  i_Mat_42;
            L_w[9] =  i_Mat_43;
            L_w[10] = i_Mat_50;
            L_w[11] = i_Mat_51;
            L_w[12] = i_Mat_52;
            L_w[13] = i_Mat_53;
            L_w[14] = i_Mat_54;
	end
        else begin
            for (n= 0; n < 15 ; n = n + 1) 
                L_w[n] = L_r[n];				
        end
    end
	
    //===================
    //    Sequential
    //===================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) state_r <= IDLE;
        else          state_r <= state_w;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) cnt_r <= '0;
        else          cnt_r <= cnt_w;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) done_r <= '0;
        else          done_r <= (cnt_r == 'd563);
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) product_shift_r <= '0;
        else          product_shift_r <= (product[MATRIX_BW+MATRIX_BW-1])? product_add[MATRIX_BW+MATRIX_BW:MUL] : product[MATRIX_BW+MATRIX_BW-1:MUL];
    end

    generate
    for (i = 0; i < 6 ; i = i + 1) begin
        always_ff @(posedge i_clk or negedge i_rst_n) begin
            if (!i_rst_n) X_r[i] <= '0;
            else          X_r[i] <= X_w[i];
        end
        always_ff @(posedge i_clk or negedge i_rst_n) begin
            if (!i_rst_n) D_r[i] <= '0;
            else          D_r[i] <= D_w[i];
        end
    end
    for (i = 0; i < 15 ; i = i + 1) begin
        always_ff @(posedge i_clk or negedge i_rst_n) begin
            if (!i_rst_n) L_r[i] <= '0;
            else          L_r[i] <= L_w[i];
        end
    end
    endgenerate

endmodule

