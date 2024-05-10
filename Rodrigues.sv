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
    logic [7:0] cnt_r, cnt_w;
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
    logic signed [MUL+1+33-1:0] quotient;
    logic sin_cos;
    logic [34:0] wave;
    logic signed [MUL+2-1:0] sin_r;
    logic signed [MUL+2-1:0] cos_r;
    logic signed [MUL+2-1:0] one_sub_cos_r;
    logic signed [MATRIX_BW+MUL-1:0] e;
    logic signed [MUL+1-1:0] f;
    logic signed [MATRIX_BW+MUL-1:0] quotient2;
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
            'd11: begin a = r_total_square_r; end   //theta^2
            default: begin a = '1; end
        endcase
    end
    
    DW_sqrt_pipe #(
         .width(2*MATRIX_BW+2)
        ,.tc_mode(1)
        ,.num_stages(3)
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
            'd16: begin b = quotient[33:0]; sin_cos = 1; end    //1 = cos
            'd17: begin b = quotient[33:0]; sin_cos = 0; end    //0 = sin
            default: begin b = 0; sin_cos = 0;end
        endcase
    end
	
    DW_div_pipe #(
         .a_width(MUL+1+33)
        ,.b_width(28)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(3)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_div (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a({theta_r,{33{1'b0}}})
        ,.b(28'd52707178) //3.14159265*2^24
        ,.quotient(quotient)
        ,.remainder()
        ,.divide_by_0()
    );

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
            'd1 : begin c = X_r[0]; d = X_r[0]; end //phi_x*phi_x
            'd4 : begin c = X_r[1]; d = X_r[1]; end //phi_y*phi_y
            'd7 : begin c = X_r[2]; d = X_r[2]; end //phi_z*phi_z
            'd17: begin c = X_r[0]; d = X_r[0]; end //rx*rx
            'd20: begin c = X_r[1]; d = X_r[1]; end //ry*ry
            'd23: begin c = X_r[2]; d = X_r[2]; end //rz*rz
            'd26: begin c = X_r[0]; d = X_r[1]; end //rx*ry
            'd29: begin c = X_r[0]; d = X_r[2]; end //rx*rz
            'd32: begin c = X_r[1]; d = X_r[2]; end //ry*rz
            'd35: begin c = {{(MATRIX_BW-MUL-2){one_sub_cos_r[MUL+1]}},one_sub_cos_r}; d = r_xx_r; end  //(1-cos)*rx*rx
            'd37: begin c = {{(MATRIX_BW-MUL-2){one_sub_cos_r[MUL+1]}},one_sub_cos_r}; d = r_xy_r; end  //(1-cos)*rx*ry
            'd39: begin c = {{(MATRIX_BW-MUL-2){sin_r[MUL+1]}},sin_r}; d = X_r[2]; end                  //sin*rz
            'd41: begin c = {{(MATRIX_BW-MUL-2){one_sub_cos_r[MUL+1]}},one_sub_cos_r}; d = r_xz_r; end  //(1-cos)*rx*rz
            'd43: begin c = {{(MATRIX_BW-MUL-2){sin_r[MUL+1]}},sin_r}; d = X_r[1]; end                  //sin*ry
            'd45: begin c = {{(MATRIX_BW-MUL-2){one_sub_cos_r[MUL+1]}},one_sub_cos_r}; d = r_yy_r; end  //(1-cos)*ry*ry
            'd47: begin c = {{(MATRIX_BW-MUL-2){one_sub_cos_r[MUL+1]}},one_sub_cos_r}; d = r_yz_r; end  //(1-cos)*ry*rz
            'd49: begin c = {{(MATRIX_BW-MUL-2){sin_r[MUL+1]}},sin_r}; d = X_r[0]; end                  //sin*rx
            'd51: begin c = {{(MATRIX_BW-MUL-2){one_sub_cos_r[MUL+1]}},one_sub_cos_r}; d = r_zz_r; end  //(1-cos)*rz*rz
            default: begin c = '0; d = '0; end
        endcase
    end
    
    DW_mult_pipe #(
         .a_width(MATRIX_BW)
        ,.b_width(MATRIX_BW)
        ,.num_stages(2)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_mult (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.tc(1'b1)
        ,.a(c)
        ,.b(d)
        ,.product(product)
    );

    always_comb begin
        case(cnt_r)
            'd14 : begin e = {X_r[0],{MUL{1'b0}}}; f = theta_r; end //rx
            'd17 : begin e = {X_r[1],{MUL{1'b0}}}; f = theta_r; end //ry
            'd20 : begin e = {X_r[2],{MUL{1'b0}}}; f = theta_r; end //rz
            default: begin e = '0; f = '1; end
        endcase
    end
    
    DW_div_pipe #(
         .a_width(MATRIX_BW+MUL)
        ,.b_width(MUL+1)
        ,.tc_mode(1)
        ,.rem_mode(1)
        ,.num_stages(3)
        ,.stall_mode(0)
        ,.rst_mode(1)
        ,.op_iso_mode(1)
    ) u_div2 (
         .clk(i_clk)
        ,.rst_n(i_rst_n)
        ,.en(1'b1)
        ,.a(e)
        ,.b(f) 
        ,.quotient(quotient2)
        ,.remainder()
        ,.divide_by_0()
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
                'd17 : begin
                           pose_w[0] = cos_r; //Rt[0,0] = (c) + c1*rx*rx
                           pose_w[5] = cos_r; //Rt[1,1] = (c) + c1*ry*ry
                           pose_w[10] = cos_r;//Rt[2,2] = (c) + c1*rz*rz
                       end
                'd37 : pose_w[0] = pose_r[0]+product_shift_r; //Rt[0,0] = c (+ c1*rx*rx)
                'd39 : begin 
                           pose_w[1] = product_shift_r; //Rt[0,1] = (c1*rx*ry) - s*rz
                           pose_w[4] = product_shift_r; //Rt[1,0] = (c1*rx*ry) + s*rz
                       end
                'd41 : begin
                          pose_w[1] = pose_r[1]-product_shift_r; //Rt[0,1] = c1*rx*ry (- s*rz)
                          pose_w[4] = pose_r[4]+product_shift_r; //Rt[1,0] = c1*rx*ry (+ s*rz)
                       end
                'd43 : begin 
                           pose_w[2] = product_shift_r; //Rt[0,2] = (c1*rx*rz) + s*ry
                           pose_w[8] = product_shift_r; //Rt[2,0] = (c1*rx*rz) - s*ry
                       end
                'd45 : begin
                          pose_w[2] = pose_r[2]+product_shift_r; //Rt[0,2] = c1*rx*rz (+ s*ry)
                          pose_w[8] = pose_r[8]-product_shift_r; //Rt[2,0] = c1*rx*rz (- s*ry)
                       end
                'd47 : pose_w[5] = pose_r[5]+product_shift_r; //Rt[1,1] = c + (c1*ry*ry)
                'd49 : begin 
                           pose_w[6] = product_shift_r; //Rt[1,2] = (c1*ry*rz) - s*rx
                           pose_w[9] = product_shift_r; //Rt[2,1] = (c1*ry*rz) + s*rx
                       end
                'd51 : begin
                          pose_w[6] = pose_r[6]-product_shift_r; //Rt[1,2] = c1*ry*rz (- s*rx)
                          pose_w[9] = pose_r[9]+product_shift_r; //Rt[2,1] = c1*ry*rz (+ s*rx)
                       end
                'd53 : pose_w[10] = pose_r[10]+product_shift_r; //Rt[2,2] = c + (c1*rz*rz)
                'd54 : begin
                          pose_w[3] = X_r[3];  //Rt[0,3] = tx
                          pose_w[7] = X_r[4];  //Rt[1,3] = ty
                          pose_w[11] = X_r[5]; //Rt[2,3] = tz
                       end
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
        else if(cnt_r == 16)
            X_w[0] = quotient2[MATRIX_BW-1:0];  //rx
        else
            X_w[0] = X_r[0];				
    end
        
    always_comb begin
        if(i_start)
            X_w[1] = i_X1;  //phi_y
        else if(cnt_r == 19)
            X_w[1] = quotient2[MATRIX_BW-1:0];  //ry
        else
            X_w[1] = X_r[1];				
    end
        
    always_comb begin
        if(i_start)
            X_w[2] = i_X2;  //phi_z
        else if(cnt_r == 22)
            X_w[2] = quotient2[MATRIX_BW-1:0];  //rz
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
        else  done_r <= (cnt_r == 'd55);
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) product_shift_r <= '0;
        else  product_shift_r <= (product[MATRIX_BW+MATRIX_BW-1])? product_add[MATRIX_BW+MATRIX_BW:MUL] : product[MATRIX_BW+MATRIX_BW-1:MUL];
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_xx_r <= '0;
        else if (cnt_r==19) r_xx_r <= product_shift_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_yy_r <= '0;
        else if (cnt_r==22) r_yy_r <= product_shift_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_zz_r <= '0;
        else if (cnt_r==25) r_zz_r <= product_shift_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_xy_r <= '0;
        else if (cnt_r==28) r_xy_r <= product_shift_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_xz_r <= '0;
        else if (cnt_r==31) r_xz_r <= product_shift_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_yz_r <= '0;
        else if (cnt_r==34) r_yz_r <= product_shift_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_x_square_r <= '0;
        else if (cnt_r==2) r_x_square_r <= product;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_y_square_r <= '0;
        else if (cnt_r==5) r_y_square_r <= product;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_z_square_r <= '0;
        else if (cnt_r==8) r_z_square_r <= product;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) r_total_square_r <= '0;
        else if (cnt_r==6) r_total_square_r <= r_x_square_r + r_y_square_r;
        else if (cnt_r==9) r_total_square_r <= r_total_square_r + r_z_square_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) theta_r <= '0;
        else if (cnt_r==13) theta_r <= root;    //theta
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) cos_r <= '0;
        else if (cnt_r==16) cos_r <= wave[34:9];
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) one_sub_cos_r <= '0;
        else if (cnt_r==17) one_sub_cos_r <= {1'b1,{MUL{1'b0}}} - cos_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) sin_r <= '0;
        else if (cnt_r==17) sin_r <= wave[34:9];
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

