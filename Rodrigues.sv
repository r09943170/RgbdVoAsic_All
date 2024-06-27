// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023


module Rodrigues
    import RgbdVoConfigPk::*;
#(
)(
    // input
     input                 i_clk
    ,input                 i_rst_n
    ,input                 i_start
    //
    ,input [MATRIX_BW-1:0] i_X0
    ,input [MATRIX_BW-1:0] i_X1
    ,input [MATRIX_BW-1:0] i_X2
    ,input [MATRIX_BW-1:0] i_X3
    ,input [MATRIX_BW-1:0] i_X4
    ,input [MATRIX_BW-1:0] i_X5
    // Output
    ,output logic                 o_done
    ,output logic [POSE_BW-1:0]   o_pose [12]
);

    //=================================
    // Signal Declaration
    //=================================
    localparam IDLE = 1'b0 , BUSY = 1'b1;
    logic  state_r, state_w;
    logic signed [MATRIX_BW - 1 : 0] pose_r [12];	
    logic signed [2 * MATRIX_BW - 1 : 0] pose_w [12];
    logic signed [MATRIX_BW - 1 : 0] X_r [6];	
    logic signed [MATRIX_BW - 1 : 0] X_w [6];	
    logic signed [2*MATRIX_BW - 1 : 0] r_x_square_r;	
    logic signed [2*MATRIX_BW - 1 : 0] r_y_square_r;	
    logic signed [2*MATRIX_BW - 1 : 0] r_z_square_r;	
    logic signed [2*MATRIX_BW + 1 : 0] r_total_square_r;	
    logic [8:0] cnt_r, cnt_w;
    genvar i;
    integer j, m, n;
    logic signed [2*MATRIX_BW+1:0] a;
    logic signed [MATRIX_BW:0] root;
    logic signed [MATRIX_BW-1:0] c, d;
    logic signed [MATRIX_BW+MATRIX_BW-1:0] product;
    logic signed [MATRIX_BW+MATRIX_BW:0] product_add;
    logic signed [MATRIX_BW+MATRIX_BW-MUL:0] product_shift_r;
    logic [33:0] b;
    logic signed [MUL+1-1:0] theta_r;
    logic        div_i_valid_1;
    logic        div_o_valid_1;
    logic signed [MUL+1+33-1:0] quotient_1;
    logic signed [33:0] theta_div_pi_r;
    logic sin_cos;
    logic [34:0] wave;
    logic signed [MUL+2-1:0] sin_r;
    logic signed [MUL+2-1:0] cos_r;
    logic signed [MUL+2-1:0] one_sub_cos_r;
    logic signed [MATRIX_BW+MUL-1:0] e;
    logic signed [MUL+1-1:0] f;
    logic        div_i_valid_2;
    logic        div_o_valid_2;
    logic signed [MATRIX_BW+MUL-1:0] quotient_2;
    logic signed [MATRIX_BW - 1 : 0] r_xx_r;
    logic signed [MATRIX_BW - 1 : 0] r_yy_r;
    logic signed [MATRIX_BW - 1 : 0] r_zz_r;
    logic signed [MATRIX_BW - 1 : 0] r_xy_r;
    logic signed [MATRIX_BW - 1 : 0] r_xz_r;
    logic signed [MATRIX_BW - 1 : 0] r_yz_r;
    logic  done_r;

    //=================================
    // Combinational Logic
    //=================================
    assign cnt_w = (state_r == IDLE)? 0: cnt_r + 1;
    assign o_done = done_r;
    generate
    for (i = 0; i < 12 ; i = i + 1) begin
        assign o_pose[i] = pose_r[i];	
    end
    endgenerate

    assign product_add = product + $signed({1'b0,{MUL{1'b1}}});

    always_comb begin
    	case(state_r)
    		IDLE : begin if(i_start == 1) state_w = BUSY; else state_w = IDLE; end
    		BUSY : begin if(done_r == 1) state_w = IDLE; else state_w = BUSY; end
    		default : state_w = IDLE;
    	endcase
    end

    always_comb begin
        case(cnt_r)
            'd6: begin a = r_total_square_r; end   //theta^2
            default: begin a = '1; end
        endcase
    end
    
    DW_sqrt_pipe #(
         .width(2*MATRIX_BW+2)
        ,.tc_mode(1)
        ,.num_stages(9)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_sqrt (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a(a)
        ,.root(root)
    );

    always_comb begin
        case(cnt_r)     
            'd15: begin div_i_valid_1 = '1; end
            default: begin div_i_valid_1 = '0;end
        endcase
    end
	
    seq_div_sign 
    #(
         .DEND_WIDTH(MUL+1+33)  //58 bits
        ,.DSOR_WIDTH(28)
        ,.CNT_WIDTH(6)
    )
    u_seq_div_sign_1
    (
        // input
         .i_clk     ( i_clk )
        ,.i_rst_n   ( i_rst_n )
        ,.i_valid   ( div_i_valid_1 )
        ,.i_Dend    ( {theta_r,{33{1'b0}}} )
        ,.i_Dsor    ( 28'd52707178 )    //3.14159265*2^24
        // output
        ,.o_valid   ( div_o_valid_1 )
        ,.o_Quot    ( quotient_1 )
        ,.o_Rder    (  )
    );

    always_comb begin
        case(cnt_r)     
            'd75: begin b = theta_div_pi_r; sin_cos = 1; end    //1 = cos
            'd76: begin b = theta_div_pi_r; sin_cos = 0; end    //0 = sin
            default: begin b = 0; sin_cos = 0;end
        endcase
    end

    DW_sincos #(
         .A_width(34)
        ,.WAVE_width(35)
        ,.arch(0)
        ,.err_range(1)
    ) u_sincos (
        .WAVE(wave),
        .A(b), 
        .SIN_COS(sin_cos)
    );


    always_comb begin
        case(cnt_r)
            'd1  : begin c = X_r[0]; d = X_r[0]; end //phi_x*phi_x
            'd2  : begin c = X_r[1]; d = X_r[1]; end //phi_y*phi_y
            'd3  : begin c = X_r[2]; d = X_r[2]; end //phi_z*phi_z
            'd105: begin c = X_r[0]; d = X_r[0]; end //rx*rx
            'd195: begin c = X_r[1]; d = X_r[1]; end //ry*ry
            'd196: begin c = X_r[0]; d = X_r[1]; end //rx*ry
            'd285: begin c = X_r[2]; d = X_r[2]; end //rz*rz
            'd286: begin c = X_r[0]; d = X_r[2]; end //rx*rz
            'd287: begin c = X_r[1]; d = X_r[2]; end //ry*rz
            'd288: begin c = {{(MATRIX_BW-MUL-2){one_sub_cos_r[MUL+1]}},one_sub_cos_r}; d = r_xx_r; end  //(1-cos)*rx*rx
            'd289: begin c = {{(MATRIX_BW-MUL-2){one_sub_cos_r[MUL+1]}},one_sub_cos_r}; d = r_xy_r; end  //(1-cos)*rx*ry
            'd290: begin c = {{(MATRIX_BW-MUL-2){sin_r[MUL+1]}},sin_r}; d = X_r[2]; end                  //sin*rz
            'd291: begin c = {{(MATRIX_BW-MUL-2){one_sub_cos_r[MUL+1]}},one_sub_cos_r}; d = r_xz_r; end  //(1-cos)*rx*rz
            'd292: begin c = {{(MATRIX_BW-MUL-2){sin_r[MUL+1]}},sin_r}; d = X_r[1]; end                  //sin*ry
            'd293: begin c = {{(MATRIX_BW-MUL-2){one_sub_cos_r[MUL+1]}},one_sub_cos_r}; d = r_yy_r; end  //(1-cos)*ry*ry
            'd294: begin c = {{(MATRIX_BW-MUL-2){one_sub_cos_r[MUL+1]}},one_sub_cos_r}; d = r_yz_r; end  //(1-cos)*ry*rz
            'd295: begin c = {{(MATRIX_BW-MUL-2){sin_r[MUL+1]}},sin_r}; d = X_r[0]; end                  //sin*rx
            'd296: begin c = {{(MATRIX_BW-MUL-2){one_sub_cos_r[MUL+1]}},one_sub_cos_r}; d = r_zz_r; end  //(1-cos)*rz*rz
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
        case(cnt_r)
            'd15 : begin e = {X_r[0],{MUL{1'b0}}}; f = theta_r; div_i_valid_2 = '1; end //rx
            'd105: begin e = {X_r[1],{MUL{1'b0}}}; f = theta_r; div_i_valid_2 = '1; end //ry
            'd195: begin e = {X_r[2],{MUL{1'b0}}}; f = theta_r; div_i_valid_2 = '1; end //rz
            default: begin e = '0; f = '1; div_i_valid_2 = '0; end
        endcase
    end
    
    seq_div_sign 
    #(
         .DEND_WIDTH(MATRIX_BW+MUL)  //88 bits
        ,.DSOR_WIDTH(MUL+1) //25 bits
        ,.CNT_WIDTH(7)
    )
    u_seq_div_sign_2
    (
        // input
         .i_clk     ( i_clk )
        ,.i_rst_n   ( i_rst_n )
        ,.i_valid   ( div_i_valid_2 )
        ,.i_Dend    ( e )
        ,.i_Dsor    ( f )
        // output
        ,.o_valid   ( div_o_valid_2 )
        ,.o_Quot    ( quotient_2 )
        ,.o_Rder    (  )
    );

    always_comb begin
        if(state_r == IDLE) begin
            for (j= 0; j < 12 ; j = j + 1) 
                pose_w[j] = 0;				
	end
        else begin
            for (j= 0; j < 12 ; j = j + 1) 
                pose_w[j] = pose_r[j];				
            case(cnt_r)
                'd1  : begin
                          pose_w[3] = X_r[3];  //Rt[0,3] = tx
                          pose_w[7] = X_r[4];  //Rt[1,3] = ty
                          pose_w[11] = X_r[5]; //Rt[2,3] = tz
                       end
                'd76 : begin
                           pose_w[0] = cos_r; //Rt[0,0] = (c) + c1*rx*rx
                           pose_w[5] = cos_r; //Rt[1,1] = (c) + c1*ry*ry
                           pose_w[10] = cos_r;//Rt[2,2] = (c) + c1*rz*rz
                       end
                'd290: pose_w[0] = pose_r[0]+product_shift_r; //Rt[0,0] = c (+ c1*rx*rx)
                'd291: begin 
                           pose_w[1] = product_shift_r; //Rt[0,1] = (c1*rx*ry) - s*rz
                           pose_w[4] = product_shift_r; //Rt[1,0] = (c1*rx*ry) + s*rz
                       end
                'd292: begin
                          pose_w[1] = pose_r[1]-product_shift_r; //Rt[0,1] = c1*rx*ry (- s*rz)
                          pose_w[4] = pose_r[4]+product_shift_r; //Rt[1,0] = c1*rx*ry (+ s*rz)
                       end
                'd293: begin 
                           pose_w[2] = product_shift_r; //Rt[0,2] = (c1*rx*rz) + s*ry
                           pose_w[8] = product_shift_r; //Rt[2,0] = (c1*rx*rz) - s*ry
                       end
                'd294: begin
                          pose_w[2] = pose_r[2]+product_shift_r; //Rt[0,2] = c1*rx*rz (+ s*ry)
                          pose_w[8] = pose_r[8]-product_shift_r; //Rt[2,0] = c1*rx*rz (- s*ry)
                       end
                'd295: pose_w[5] = pose_r[5]+product_shift_r; //Rt[1,1] = c + (c1*ry*ry)
                'd296: begin 
                           pose_w[6] = product_shift_r; //Rt[1,2] = (c1*ry*rz) - s*rx
                           pose_w[9] = product_shift_r; //Rt[2,1] = (c1*ry*rz) + s*rx
                       end
                'd297: begin
                          pose_w[6] = pose_r[6]-product_shift_r; //Rt[1,2] = c1*ry*rz (- s*rx)
                          pose_w[9] = pose_r[9]+product_shift_r; //Rt[2,1] = c1*ry*rz (+ s*rx)
                       end
                'd298: pose_w[10] = pose_r[10]+product_shift_r; //Rt[2,2] = c + (c1*rz*rz)
                
                default: begin for (j = 0; j < 12 ; j = j + 1) pose_w[j] = pose_r[j]; end
            endcase			
        end
    end
	
    always_comb begin
        if(i_start) begin
            X_w[3] = i_X3;  //tx
            X_w[4] = i_X4;  //ty
            X_w[5] = i_X5;  //tz
        end
        else begin
            for (m= 3; m < 6 ; m = m + 1) 
                X_w[m] = X_r[m];				
        end
    end
        
    always_comb begin
        if(i_start)
            X_w[0] = i_X0;  //phi_x
        else if(cnt_r == 104)
            X_w[0] = quotient_2[MATRIX_BW-1:0];  //rx
        else
            X_w[0] = X_r[0];				
    end
        
    always_comb begin
        if(i_start)
            X_w[1] = i_X1;  //phi_y
        else if(cnt_r == 194)
            X_w[1] = quotient_2[MATRIX_BW-1:0];  //ry
        else
            X_w[1] = X_r[1];				
    end
        
    always_comb begin
        if(i_start)
            X_w[2] = i_X2;  //phi_z
        else if(cnt_r == 284)
            X_w[2] = quotient_2[MATRIX_BW-1:0];  //rz
        else
            X_w[2] = X_r[2];				
    end
        

    //===================
    //    Sequential
    //===================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) state_r <= IDLE;
        else  state_r <= state_w;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) cnt_r <= '0;
        else  cnt_r <= cnt_w;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) done_r <= '0;
        else  done_r <= (cnt_r == 'd299);
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) product_shift_r <= '0;
        else  product_shift_r <= (product[MATRIX_BW+MATRIX_BW-1])? product_add[MATRIX_BW+MATRIX_BW:MUL] : product[MATRIX_BW+MATRIX_BW-1:MUL];
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_x_square_r <= '0;
        else if (cnt_r==2) r_x_square_r <= product;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_y_square_r <= '0;
        else if (cnt_r==3) r_y_square_r <= product;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_z_square_r <= '0;
        else if (cnt_r==4) r_z_square_r <= product;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_total_square_r <= '0;
        else if (cnt_r==4) r_total_square_r <= r_x_square_r + r_y_square_r;
        else if (cnt_r==5) r_total_square_r <= r_total_square_r + r_z_square_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) theta_r <= '0;
        else if (cnt_r==14) theta_r <= root;    //theta
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) theta_div_pi_r <= '0;
        else if (cnt_r==74) theta_div_pi_r <= quotient_1[33:0];
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) cos_r <= '0;
        else if (cnt_r==75) cos_r <= wave[34:9];
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) one_sub_cos_r <= '0;
        else if (cnt_r==76) one_sub_cos_r <= {1'b1,{MUL{1'b0}}} - cos_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) sin_r <= '0;
        else if (cnt_r==76) sin_r <= wave[34:9];
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_xx_r <= '0;
        else if (cnt_r==107) r_xx_r <= product_shift_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_yy_r <= '0;
        else if (cnt_r==197) r_yy_r <= product_shift_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_xy_r <= '0;
        else if (cnt_r==198) r_xy_r <= product_shift_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_zz_r <= '0;
        else if (cnt_r==287) r_zz_r <= product_shift_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_xz_r <= '0;
        else if (cnt_r==288) r_xz_r <= product_shift_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_yz_r <= '0;
        else if (cnt_r==289) r_yz_r <= product_shift_r;
    end

    generate
    for (i = 0; i < 12 ; i = i + 1) begin
        always_ff @(posedge i_clk or negedge i_rst_n) begin
            if (!i_rst_n)      pose_r[i] <= '0;
            else  pose_r[i] <= pose_w[i];
        end
    end

    for (i = 0; i < 6 ; i = i + 1) begin
        always_ff @(posedge i_clk or negedge i_rst_n) begin
            if (!i_rst_n)      X_r[i] <= '0;
            else  X_r[i] <= X_w[i];
        end
    end
    endgenerate

endmodule

