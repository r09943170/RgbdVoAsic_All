// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023


module UpdatePose
    import RgbdVoConfigPk::*;
#(
)(
    // input
     input                 i_clk
    ,input                 i_rst_n
    ,input                 i_start
    ,input [POSE_BW-1:0]   i_delta_pose [12]    //currRt_cp
    ,input [POSE_BW-1:0]   i_pose [12]          //resultRt
    // Output
    ,output logic               o_done
    ,output logic [POSE_BW-1:0] o_pose [12]
);

    //=================================
    // Signal Declaration
    //=================================
    localparam IDLE = 1'b0 , BUSY = 1'b1;
    logic  state_r, state_w;
    logic signed [POSE_BW - 1 : 0] pose_r [12];	
    logic signed [2 * POSE_BW - 1 : 0] pose_w [12];
    logic signed [POSE_BW - 1 : 0] delta_w [12];	
    logic signed [POSE_BW - 1 : 0] delta_r [12];	
    logic [7:0] cnt_r, cnt_w;
    genvar i;
    integer j, m, n;
    logic signed [POSE_BW-1:0] a, b;
    logic signed [POSE_BW+POSE_BW-1:0] product;
    //logic signed [POSE_BW+POSE_BW:0] product_add;
    logic signed [POSE_BW+POSE_BW-MUL:0] product_shift_r;
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

    //assign product_add = product + $signed({1'b0,{MUL{1'b1}}});

    always_comb begin
    	case(state_r)
    		IDLE : begin if(i_start == 1) state_w = BUSY; else state_w = IDLE; end
    		BUSY : begin if(done_r == 1) state_w = IDLE; else state_w = BUSY; end
    		default : state_w = IDLE;
    	endcase
    end


    always_comb begin
        case(cnt_r)     
            'd1:  begin a = delta_r[0]; b = i_pose[0]; end      //result_final_00 = (curr_00*result_00) + curr_01*result_10 + curr_02*result_20
            'd3:  begin a = delta_r[1]; b = i_pose[4]; end      //result_final_00 = curr_00*result_00 + (curr_01*result_10) + curr_02*result_20
            'd5:  begin a = delta_r[2]; b = i_pose[8]; end      //result_final_00 = curr_00*result_00 + curr_01*result_10 + (curr_02*result_20)
            'd7:  begin a = delta_r[0]; b = i_pose[1]; end      //result_final_01 = (curr_00*result_01) + curr_01*result_11 + curr_02*result_21
            'd9:  begin a = delta_r[1]; b = i_pose[5]; end      //result_final_01 = curr_00*result_01 + (curr_01*result_11) + curr_02*result_21
            'd11: begin a = delta_r[2]; b = i_pose[9]; end      //result_final_01 = curr_00*result_01 + curr_01*result_11 + (curr_02*result_21)
            'd13: begin a = delta_r[0]; b = i_pose[2]; end      //result_final_02 = (curr_00*result_02) + curr_01*result_12 + curr_02*result_22
            'd15: begin a = delta_r[1]; b = i_pose[6]; end      //result_final_02 = curr_00*result_02 + (curr_01*result_12) + curr_02*result_22
            'd17: begin a = delta_r[2]; b = i_pose[10]; end     //result_final_02 = curr_00*result_02 + curr_01*result_12 + (curr_02*result_22)
            'd19: begin a = delta_r[0]; b = i_pose[3]; end      //result_final_03 = (curr_00*result_03) + curr_01*result_13 + curr_02*result_23 + curr_03*result_33
            'd21: begin a = delta_r[1]; b = i_pose[7]; end      //result_final_03 = curr_00*result_03 + (curr_01*result_13) + curr_02*result_23 + curr_03*result_33
            'd23: begin a = delta_r[2]; b = i_pose[11]; end     //result_final_03 = curr_00*result_03 + curr_01*result_13 + (curr_02*result_23) + curr_03*result_33
            'd25: begin a = delta_r[3]; b = 42'sd16777216; end  //result_final_03 = curr_00*result_03 + curr_01*result_13 + curr_02*result_23 + (curr_03*result_33)
            'd27: begin a = delta_r[4]; b = i_pose[0]; end      //result_final_10 = (curr_10*result_00) + curr_11*result_10 + curr_12*result_20
            'd29: begin a = delta_r[5]; b = i_pose[4]; end      //result_final_10 = curr_10*result_00 + (curr_11*result_10) + curr_12*result_20
            'd31: begin a = delta_r[6]; b = i_pose[8]; end      //result_final_10 = curr_10*result_00 + curr_11*result_10 + (curr_12*result_20)
            'd33: begin a = delta_r[4]; b = i_pose[1]; end      //result_final_11 = (curr_10*result_01) + curr_11*result_11 + curr_12*result_21
            'd35: begin a = delta_r[5]; b = i_pose[5]; end      //result_final_11 = curr_10*result_01 + (curr_11*result_11) + curr_12*result_21
            'd37: begin a = delta_r[6]; b = i_pose[9]; end      //result_final_11 = curr_10*result_01 + curr_11*result_11 + (curr_12*result_21)
            'd39: begin a = delta_r[4]; b = i_pose[2]; end      //result_final_12 = (curr_10*result_02) + curr_11*result_12 + curr_12*result_22
            'd41: begin a = delta_r[5]; b = i_pose[6]; end      //result_final_12 = curr_10*result_02 + (curr_11*result_12) + curr_12*result_22
            'd43: begin a = delta_r[6]; b = i_pose[10]; end     //result_final_12 = curr_10*result_02 + curr_11*result_12 + (curr_12*result_22)
            'd45: begin a = delta_r[4]; b = i_pose[3]; end      //result_final_13 = (curr_10*result_03) + curr_11*result_13 + curr_12*result_23 + curr_13*result_33
            'd47: begin a = delta_r[5]; b = i_pose[7]; end      //result_final_13 = curr_10*result_03 + (curr_11*result_13) + curr_12*result_23 + curr_13*result_33
            'd49: begin a = delta_r[6]; b = i_pose[11]; end     //result_final_13 = curr_10*result_03 + curr_11*result_13 + (curr_12*result_23) + curr_13*result_33
            'd51: begin a = delta_r[7]; b = 42'sd16777216; end  //result_final_13 = curr_10*result_03 + curr_11*result_13 + curr_12*result_23 + (curr_13*result_33)
            'd53: begin a = delta_r[8]; b = i_pose[0]; end      //result_final_20 = (curr_20*result_00) + curr_21*result_10 + curr_22*result_20
            'd55: begin a = delta_r[9]; b = i_pose[4]; end      //result_final_20 = curr_20*result_00 + (curr_21*result_10) + curr_22*result_20
            'd57: begin a = delta_r[10]; b = i_pose[8]; end     //result_final_20 = curr_20*result_00 + curr_21*result_10 + (curr_22*result_20)
            'd59: begin a = delta_r[8]; b = i_pose[1]; end      //result_final_21 = (curr_20*result_01) + curr_21*result_11 + curr_22*result_21
            'd61: begin a = delta_r[9]; b = i_pose[5]; end      //result_final_21 = curr_20*result_01 + (curr_21*result_11) + curr_22*result_21
            'd63: begin a = delta_r[10]; b = i_pose[9]; end     //result_final_21 = curr_20*result_01 + curr_21*result_11 + (curr_22*result_21)
            'd65: begin a = delta_r[8]; b = i_pose[2]; end      //result_final_22 = (curr_20*result_02) + curr_21*result_12 + curr_22*result_22
            'd67: begin a = delta_r[9]; b = i_pose[6]; end      //result_final_22 = curr_20*result_02 + (curr_21*result_12) + curr_22*result_22
            'd69: begin a = delta_r[10]; b = i_pose[10]; end    //result_final_22 = curr_20*result_02 + curr_21*result_12 + (curr_22*result_22)
            'd71: begin a = delta_r[8]; b = i_pose[3]; end      //result_final_23 = (curr_20*result_03) + curr_21*result_13 + curr_22*result_23 + curr_23*result_33
            'd73: begin a = delta_r[9]; b = i_pose[7]; end      //result_final_23 = curr_20*result_03 + (curr_21*result_13) + curr_22*result_23 + curr_23*result_33
            'd75: begin a = delta_r[10]; b = i_pose[11]; end    //result_final_23 = curr_20*result_03 + curr_21*result_13 + (curr_22*result_23) + curr_23*result_33
            'd77: begin a = delta_r[11]; b = 42'sd16777216; end //result_final_23 = curr_20*result_03 + curr_21*result_13 + curr_22*result_23 + (curr_23*result_33)
            default: begin a = 0; b = 0;end
        endcase
    end
	
    DW02_mult_2_stage #(
         .A_width(POSE_BW)
        ,.B_width(POSE_BW)
    ) u_mult (
         .A(a)
        ,.B(b)
        ,.TC(1'b1)
        ,.CLK(i_clk)
        ,.PRODUCT(product)
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
                'd3 : pose_w[0] = pose_r[0]+product_shift_r; 
                'd5 : pose_w[0] = pose_r[0]+product_shift_r; 
                'd7 : pose_w[0] = pose_r[0]+product_shift_r; 
                'd9 : pose_w[1] = pose_r[1]+product_shift_r; 
                'd11: pose_w[1] = pose_r[1]+product_shift_r; 
                'd13: pose_w[1] = pose_r[1]+product_shift_r; 
                'd15: pose_w[2] = pose_r[2]+product_shift_r; 
                'd17: pose_w[2] = pose_r[2]+product_shift_r; 
                'd19: pose_w[2] = pose_r[2]+product_shift_r; 
                'd21: pose_w[3] = pose_r[3]+product_shift_r; 
                'd23: pose_w[3] = pose_r[3]+product_shift_r; 
                'd25: pose_w[3] = pose_r[3]+product_shift_r; 
                'd27: pose_w[3] = pose_r[3]+product_shift_r; 
                'd29: pose_w[4] = pose_r[4]+product_shift_r; 
                'd31: pose_w[4] = pose_r[4]+product_shift_r; 
                'd33: pose_w[4] = pose_r[4]+product_shift_r; 
                'd35: pose_w[5] = pose_r[5]+product_shift_r; 
                'd37: pose_w[5] = pose_r[5]+product_shift_r; 
                'd39: pose_w[5] = pose_r[5]+product_shift_r; 
                'd41: pose_w[6] = pose_r[6]+product_shift_r; 
                'd43: pose_w[6] = pose_r[6]+product_shift_r; 
                'd45: pose_w[6] = pose_r[6]+product_shift_r; 
                'd47: pose_w[7] = pose_r[7]+product_shift_r; 
                'd49: pose_w[7] = pose_r[7]+product_shift_r; 
                'd51: pose_w[7] = pose_r[7]+product_shift_r; 
                'd53: pose_w[7] = pose_r[7]+product_shift_r; 
                'd55: pose_w[8] = pose_r[8]+product_shift_r; 
                'd57: pose_w[8] = pose_r[8]+product_shift_r; 
                'd59: pose_w[8] = pose_r[8]+product_shift_r; 
                'd61: pose_w[9] = pose_r[9]+product_shift_r; 
                'd63: pose_w[9] = pose_r[9]+product_shift_r; 
                'd65: pose_w[9] = pose_r[9]+product_shift_r; 
                'd67: pose_w[10] = pose_r[10]+product_shift_r; 
                'd69: pose_w[10] = pose_r[10]+product_shift_r; 
                'd71: pose_w[10] = pose_r[10]+product_shift_r; 
                'd73: pose_w[11] = pose_r[11]+product_shift_r; 
                'd75: pose_w[11] = pose_r[11]+product_shift_r; 
                'd77: pose_w[11] = pose_r[11]+product_shift_r; 
                'd79: pose_w[11] = pose_r[11]+product_shift_r; 
                default: begin for (j = 0; j < 12 ; j = j + 1) pose_w[j] = pose_r[j]; end
            endcase			
        end
    end
	
    always_comb begin
        if(i_start) begin
            for (m= 0; m < 12 ; m = m + 1) 
                delta_w[m] = i_delta_pose[m];				
        end
        else begin
            for (m= 0; m < 12 ; m = m + 1) 
                delta_w[m] = delta_r[m];				
        end
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
        else  done_r <= (cnt_r == 'd80);
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) product_shift_r <= '0;
        //else  product_shift_r <= (product[POSE_BW+POSE_BW-1])? product_add[POSE_BW+POSE_BW:MUL] : product[POSE_BW+POSE_BW-1:MUL];
        else  product_shift_r <= product[POSE_BW+POSE_BW-1:MUL];
    end

    generate
    for (i = 0; i < 12 ; i = i + 1) begin
        always_ff @(posedge i_clk or negedge i_rst_n) begin
            if (!i_rst_n)      pose_r[i] <= '0;
            else  pose_r[i] <= pose_w[i];
        end
    end

    for (i = 0; i < 12 ; i = i + 1) begin
        always_ff @(posedge i_clk or negedge i_rst_n) begin
            if (!i_rst_n)      delta_r[i] <= '0;
            else  delta_r[i] <= delta_w[i];
        end
    end
    endgenerate

endmodule

