// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023


module LDLT
    import RgbdVoConfigPk::*;   //MUL = 24, MATRIX_BW = 64
#(
)(
    // input
     input                 i_clk
    ,input                 i_rst_n
    ,input                 i_start
     // Mat A
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
    // Output D, L
    ,output logic                 o_done
    ,output logic                 o_div_zero
    ,output logic [MATRIX_BW-1:0] o_Mat_00
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
);

    //=================================
    // Signal Declaration
    //=================================
    localparam IDLE = 1'b0 , BUSY = 1'b1;
    logic  state_r, state_w;
    logic signed [MATRIX_BW - 1 : 0] Mat_r [36];	
    logic signed [2 * MATRIX_BW - 1 : 0] Mat_w [36];
    logic [7:0] cnt_r, cnt_w;
    genvar i;
    integer j;
    logic signed [MATRIX_BW+MUL-1:0] a;
    logic signed [MATRIX_BW-1:0] b;
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
    assign o_Mat_00 = Mat_r[0];     //D[0]
    assign o_Mat_10 = Mat_r[6];     //L[1,0]
    assign o_Mat_20 = Mat_r[12];    //L[2,0]
    assign o_Mat_30 = Mat_r[18];    //L[3,0]
    assign o_Mat_40 = Mat_r[24];    //L[4,0]
    assign o_Mat_50 = Mat_r[30];    //L[5,0]
    assign o_Mat_11 = Mat_r[7];     //D[1]
    assign o_Mat_21 = Mat_r[13];    //L[2,1]
    assign o_Mat_31 = Mat_r[19];    //L[3,1]
    assign o_Mat_41 = Mat_r[25];    //L[4,1]
    assign o_Mat_51 = Mat_r[31];    //L[5,1]
    assign o_Mat_22 = Mat_r[14];    //D[2]
    assign o_Mat_32 = Mat_r[20];    //L[3,2]
    assign o_Mat_42 = Mat_r[26];    //L[4,2]
    assign o_Mat_52 = Mat_r[32];    //L[5,2]
    assign o_Mat_33 = Mat_r[21];    //D[3]
    assign o_Mat_43 = Mat_r[27];    //L[4,3]
    assign o_Mat_53 = Mat_r[33];    //L[5,3]
    assign o_Mat_44 = Mat_r[28];    //D[4]
    assign o_Mat_54 = Mat_r[34];    //L[5,4]
    assign o_Mat_55 = Mat_r[35];    //D[5]
	
    assign product_add = product + {1'b0,{MUL{1'b1}}};

    always_comb begin
    	case(state_r)
    		IDLE : begin if(i_start == 1) state_w = BUSY; else state_w = IDLE; end
    		BUSY : begin if(done_r == 1) state_w = IDLE; else state_w = BUSY; end
    		default : state_w = IDLE;
    	endcase
    end


    always_comb begin
        case(cnt_r)
           'd1 : begin a = {Mat_r[1] ,{MUL{1'b0}}}; b = Mat_r[0]; end   //L[1,0] = u[0,1]/D[0]
           'd2 : begin a = {Mat_r[1] ,{MUL{1'b0}}}; b = Mat_r[0]; end 
           'd3 : begin a = {Mat_r[2] ,{MUL{1'b0}}}; b = Mat_r[0]; end   //L[2,0] = u[0,2]/D[0]
           'd4 : begin a = {Mat_r[2] ,{MUL{1'b0}}}; b = Mat_r[0]; end 
           'd5 : begin a = {Mat_r[3] ,{MUL{1'b0}}}; b = Mat_r[0]; end   //L[3,0] = u[0,3]/D[0]
           'd6 : begin a = {Mat_r[3] ,{MUL{1'b0}}}; b = Mat_r[0]; end 
           'd7 : begin a = {Mat_r[4] ,{MUL{1'b0}}}; b = Mat_r[0]; end   //L[4,0] = u[0,4]/D[0]
           'd8 : begin a = {Mat_r[4] ,{MUL{1'b0}}}; b = Mat_r[0]; end 
           'd9 : begin a = {Mat_r[5] ,{MUL{1'b0}}}; b = Mat_r[0]; end   //L[5,0] = u[0,5]/D[0]
           'd10: begin a = {Mat_r[5] ,{MUL{1'b0}}}; b = Mat_r[0]; end 
           'd18: begin a = {Mat_r[8] ,{MUL{1'b0}}}; b = Mat_r[7]; end   //L[2,1] = u[1,2]/D[1]
           'd19: begin a = {Mat_r[8] ,{MUL{1'b0}}}; b = Mat_r[7]; end 
           'd24: begin a = {Mat_r[9] ,{MUL{1'b0}}}; b = Mat_r[7]; end   //L[3,1] = u[1,3]/D[1]
           'd25: begin a = {Mat_r[9] ,{MUL{1'b0}}}; b = Mat_r[7]; end 
           'd30: begin a = {Mat_r[10],{MUL{1'b0}}}; b = Mat_r[7]; end   //L[4,1] = u[1,4]/D[1]
           'd31: begin a = {Mat_r[10],{MUL{1'b0}}}; b = Mat_r[7]; end  
           'd36: begin a = {Mat_r[11],{MUL{1'b0}}}; b = Mat_r[7]; end   //L[5,1] = u[1,5]/D[1]
           'd37: begin a = {Mat_r[11],{MUL{1'b0}}}; b = Mat_r[7]; end 
           'd51: begin a = {Mat_r[15],{MUL{1'b0}}}; b = Mat_r[14]; end  //L[3,2] = u[2,3]/D[2]	
           'd52: begin a = {Mat_r[15],{MUL{1'b0}}}; b = Mat_r[14]; end 
           'd60: begin a = {Mat_r[16],{MUL{1'b0}}}; b = Mat_r[14]; end  //L[4,2] = u[2,4]/D[2]
           'd61: begin a = {Mat_r[16],{MUL{1'b0}}}; b = Mat_r[14]; end  
           'd69: begin a = {Mat_r[17],{MUL{1'b0}}}; b = Mat_r[14]; end  //L[5,2] = u[2,5]/D[2]
           'd70: begin a = {Mat_r[17],{MUL{1'b0}}}; b = Mat_r[14]; end  
           'd90: begin a = {Mat_r[22],{MUL{1'b0}}}; b = Mat_r[21]; end  //L[4,3] = u[3,4]/D[3]
           'd91: begin a = {Mat_r[22],{MUL{1'b0}}}; b = Mat_r[21]; end  
           'd102: begin a = {Mat_r[23],{MUL{1'b0}}}; b = Mat_r[21]; end //L[5,3] = u[3,5]/D[3]
           'd103: begin a = {Mat_r[23],{MUL{1'b0}}}; b = Mat_r[21]; end 
           'd129: begin a = {Mat_r[29],{MUL{1'b0}}}; b = Mat_r[28]; end //L[5,4] = u[4,5]/D[4]
           'd130: begin a = {Mat_r[29],{MUL{1'b0}}}; b = Mat_r[28]; end  
            default: begin a = '0; b = '1; end
        endcase
    end
    
    DW_div_pipe #(
         .a_width(MATRIX_BW+MUL)
        ,.b_width(MATRIX_BW)
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
        ,.a(a)
        ,.b(b)
        ,.quotient(quotient)
        ,.remainder()
        ,.divide_by_0()
    );

    always_comb begin
        case(cnt_r)
            'd12: begin c = Mat_r[1]; d = Mat_r[6]; end     // u[0,1]*L[1,0]
            'd15: begin c = Mat_r[2]; d = Mat_r[6]; end     // u[0,2]*L[1,0]
            'd21: begin c = Mat_r[3]; d = Mat_r[6]; end     // u[0,3]*L[1,0]
            'd27: begin c = Mat_r[4]; d = Mat_r[6]; end     // u[0,4]*L[1,0]
            'd33: begin c = Mat_r[5]; d = Mat_r[6]; end     // u[0,5]*L[1,0]
            'd39: begin c = Mat_r[2]; d = Mat_r[12]; end    // u[0,2]*L[2,0]
            'd42: begin c = Mat_r[8]; d = Mat_r[13]; end    // u[1,2]*L[2,1]
            'd45: begin c = Mat_r[3]; d = Mat_r[12]; end    // u[0,3]*L[2,0]
            'd48: begin c = Mat_r[9]; d = Mat_r[13]; end    // u[1,3]*L[2,1]
            'd54: begin c = Mat_r[4]; d = Mat_r[12]; end    // u[0,4]*L[2,0]
            'd57: begin c = Mat_r[10]; d = Mat_r[13]; end 	// u[1,4]*L[2,1]
            'd63: begin c = Mat_r[5]; d = Mat_r[12]; end    // u[0,5]*L[2,0]
            'd66: begin c = Mat_r[11]; d = Mat_r[13]; end 	// u[1,5]*L[2,1]
            'd72: begin c = Mat_r[3]; d = Mat_r[18]; end    // u[0,3]*L[3,0]
            'd75: begin c = Mat_r[9]; d = Mat_r[19]; end    // u[1,3]*L[3,1]
            'd78: begin c = Mat_r[15]; d = Mat_r[20]; end   // u[2,3]*L[3,2]
            'd81: begin c = Mat_r[4]; d = Mat_r[18]; end    // u[0,4]*L[3,0]
            'd84: begin c = Mat_r[10]; d = Mat_r[19]; end   // u[1,4]*L[3,1]
            'd87: begin c = Mat_r[16]; d = Mat_r[20]; end 	// u[2,4]*L[3,2]
            'd93: begin c = Mat_r[5]; d = Mat_r[18]; end    // u[0,5]*L[3,0]
            'd96: begin c = Mat_r[11]; d = Mat_r[19]; end   // u[1,5]*L[3,1]
            'd99: begin c = Mat_r[17]; d = Mat_r[20]; end 	// u[2,5]*L[3,2]
            'd105: begin c = Mat_r[4]; d = Mat_r[24]; end   // u[0,4]*L[4,0]
            'd108: begin c = Mat_r[10]; d = Mat_r[25]; end  // u[1,4]*L[4,1]
            'd111: begin c = Mat_r[16]; d = Mat_r[26]; end  // u[2,4]*L[4,2]
            'd114: begin c = Mat_r[22]; d = Mat_r[27]; end  // u[3,4]*L[4,3]
            'd117: begin c = Mat_r[5]; d = Mat_r[24]; end   // u[0,5]*L[4,0]
            'd120: begin c = Mat_r[11]; d = Mat_r[25]; end  // u[1,5]*L[4,1]
            'd123: begin c = Mat_r[17]; d = Mat_r[26]; end  // u[2,5]*L[4,2]
            'd126: begin c = Mat_r[23]; d = Mat_r[27]; end  // u[3,5]*L[4,3]
            'd132: begin c = Mat_r[5]; d = Mat_r[30]; end   // u[0,5]*L[5,0]
            'd135: begin c = Mat_r[11]; d = Mat_r[31]; end  // u[1,5]*L[5,1]
            'd138: begin c = Mat_r[17]; d = Mat_r[32]; end  // u[2,5]*L[5,2]
            'd141: begin c = Mat_r[23]; d = Mat_r[33]; end  // u[3,5]*L[5,3]
            'd144: begin c = Mat_r[29]; d = Mat_r[34]; end  // u[4,5]*L[5,4]
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
        if(state_r == IDLE) begin
            Mat_w[0]  = i_Mat_00;   //A[0,0]
            Mat_w[1]  = i_Mat_10;   //A[0,1]
            Mat_w[2]  = i_Mat_20;   //A[0,2]
            Mat_w[3]  = i_Mat_30;   //A[0,3]
            Mat_w[4]  = i_Mat_40;   //A[0,4]
            Mat_w[5]  = i_Mat_50;   //A[0,5]
            Mat_w[6]  = i_Mat_10;   //A[1,0]
            Mat_w[7]  = i_Mat_11;   //A[1,1]
            Mat_w[8]  = i_Mat_21;   //A[1,2]
            Mat_w[9]  = i_Mat_31;   //A[1,3]
            Mat_w[10] = i_Mat_41;   //A[1,4]
            Mat_w[11] = i_Mat_51;   //A[1,5]
            Mat_w[12] = i_Mat_20;   //A[2,0]
            Mat_w[13] = i_Mat_21;   //A[2,1]
            Mat_w[14] = i_Mat_22;   //A[2,2]
            Mat_w[15] = i_Mat_32;   //A[2,3]
            Mat_w[16] = i_Mat_42;   //A[2,4]
            Mat_w[17] = i_Mat_52;   //A[2,5]
            Mat_w[18] = i_Mat_30;   //A[3,0]
            Mat_w[19] = i_Mat_31;   //A[3,1]
            Mat_w[20] = i_Mat_32;   //A[3,2]
            Mat_w[21] = i_Mat_33;   //A[3,3]
            Mat_w[22] = i_Mat_43;   //A[3,4]
            Mat_w[23] = i_Mat_53;   //A[3,5]
            Mat_w[24] = i_Mat_40;   //A[4,0]
            Mat_w[25] = i_Mat_41;   //A[4,1]
            Mat_w[26] = i_Mat_42;   //A[4,2]
            Mat_w[27] = i_Mat_43;   //A[4,3]
            Mat_w[28] = i_Mat_44;   //A[4,4]
            Mat_w[29] = i_Mat_54;   //A[4,5]
            Mat_w[30] = i_Mat_50;   //A[5,0]
            Mat_w[31] = i_Mat_51;   //A[5,1]
            Mat_w[32] = i_Mat_52;   //A[5,2]
            Mat_w[33] = i_Mat_53;   //A[5,3]
            Mat_w[34] = i_Mat_54;   //A[5,4]
            Mat_w[35] = i_Mat_55;   //A[5,5]
	end
        else begin
            for (j= 0; j < 36 ; j = j + 1) 
                Mat_w[j] = Mat_r[j];				
            case(cnt_r)
                'd3 : Mat_w[6] = quotient;                      //L[1,0] = u[0,1]/D[0]
                'd5 : Mat_w[12] = quotient;                     //L[2,0] = u[0,2]/D[0]
                'd7 : Mat_w[18] = quotient;                     //L[3,0] = u[0,3]/D[0]
                'd9 : Mat_w[24] = quotient;                     //L[4,0] = u[0,4]/D[0]
                'd11: Mat_w[30] = quotient;                     //L[5,0] = u[0,5]/D[0]
                'd14: Mat_w[7] = Mat_r[7] - product_shift_r;    //D[1] = A[1,1] (- u[0,1]*L[1,0])
                'd17: Mat_w[8] = Mat_r[8] - product_shift_r;    //u[1,2] = A[1,2] (- u[0,2]*L[1,0])
                'd20: Mat_w[13] = quotient;                     //L[2,1] = u[1,2]/D[1]
                'd23: Mat_w[9]  = Mat_r[9] - product_shift_r;   //u[1,3] = A[1,3] (- u[0,3]*L[1,0])
                'd26: Mat_w[19] = quotient;                     //L[3,1] = u[1,3]/D[1]
                'd29: Mat_w[10] = Mat_r[10] - product_shift_r;  //u[1,4] = A[1,4] (- u[0,4]*L[1,0])
                'd32: Mat_w[25] = quotient;                     //L[4,1] = u[1,4]/D[1]
                'd35: Mat_w[11] = Mat_r[11] - product_shift_r;  //u[1,5] = A[1,5] (- u[0,5]*L[1,0])
                'd38: Mat_w[31] = quotient;                     //L[5,1] = u[1,5]/D[1]
                'd41: Mat_w[14] = Mat_r[14] - product_shift_r;  //D[2] = A[2,2] (- u[0,2]*L[2,0]) - u[1,2]*L[2,1]
                'd44: Mat_w[14] = Mat_r[14] - product_shift_r;  //D[2] = A[2,2] - u[0,2]*L[2,0] (- u[1,2]*L[2,1])
                'd47: Mat_w[15] = Mat_r[15] - product_shift_r;  //u[2,3] = A[2,3] (- u[0,3]*L[2,0]) - u[1,3]*L[2,1]
                'd50: Mat_w[15] = Mat_r[15] - product_shift_r;  //u[2,3] = A[2,3] - u[0,3]*L[2,0] (- u[1,3]*L[2,1])
                'd53: Mat_w[20] = quotient;                     //L[3,2] = u[2,3]/D[2]
                'd56: Mat_w[16] = Mat_r[16] - product_shift_r;  //u[2,4] = A[2,4] (- u[0,4]*L[2,0]) - u[1,4]*L[2,1]
                'd59: Mat_w[16] = Mat_r[16] - product_shift_r;  //u[2,4] = A[2,4] - u[0,4]*L[2,0] (- u[1,4]*L[2,1])
                'd62: Mat_w[26] = quotient;                     //L[4,2] = u[2,4]/D[2]
                'd65: Mat_w[17] = Mat_r[17] - product_shift_r;  //u[2,5] = A[2,5] (- u[0,5]*L[2,0]) - u[1,5]*L[2,1]
                'd68: Mat_w[17] = Mat_r[17] - product_shift_r; 	//u[2,5] = A[2,5] - u[0,5]*L[2,0] (- u[1,5]*L[2,1])
                'd71: Mat_w[32] = quotient; 	                //L[5,2] = u[2,5]/D[2]
                'd74: Mat_w[21] = Mat_r[21] - product_shift_r;  //D[3] = A[3,3] (- u[0,3]*L[3,0]) - u[1,3]*L[3,1] - u[2,3]*L[3,2]
                'd77: Mat_w[21] = Mat_r[21] - product_shift_r;  //D[3] = A[3,3] - u[0,3]*L[3,0] (- u[1,3]*L[3,1]) - u[2,3]*L[3,2]
                'd80: Mat_w[21] = Mat_r[21] - product_shift_r;  //D[3] = A[3,3] - u[0,3]*L[3,0] - u[1,3]*L[3,1] (- u[2,3]*L[3,2])
                'd83: Mat_w[22] = Mat_r[22] - product_shift_r;  //u[3,4] = A[3,4] (- u[0,4]*L[3,0]) - u[1,4]*L[3,1] - u[2,4]*L[3,2]
                'd86: Mat_w[22] = Mat_r[22] - product_shift_r;  //u[3,4] = A[3,4] - u[0,4]*L[3,0] (- u[1,4]*L[3,1]) - u[2,4]*L[3,2]
                'd89: Mat_w[22] = Mat_r[22] - product_shift_r;  //u[3,4] = A[3,4] - u[0,4]*L[3,0] - u[1,4]*L[3,1] (- u[2,4]*L[3,2])
                'd92: Mat_w[27] = quotient;  	                //L[4,3] = u[3,4]/D[3]
                'd95: Mat_w[23] = Mat_r[23] - product_shift_r;  //u[3,5] = A[3,5] (- u[0,5]*L[3,0]) - u[1,5]*L[3,1] - u[2,5]*L[3,2]
                'd98: Mat_w[23] = Mat_r[23] - product_shift_r;  //u[3,5] = A[3,5] - u[0,5]*L[3,0] (- u[1,5]*L[3,1]) - u[2,5]*L[3,2]
                'd101: Mat_w[23] = Mat_r[23] - product_shift_r; //u[3,5] = A[3,5] - u[0,5]*L[3,0] - u[1,5]*L[3,1] (- u[2,5]*L[3,2])
                'd104: Mat_w[33] = quotient; 	                //L[5,3] = u[3,5]/D[3]
                'd107: Mat_w[28] = Mat_r[28] - product_shift_r; //D[4] = A[4,4] (- u[0,4]*L[4,0]) - u[1,4]*L[4,1] - u[2,4]*L[4,2] - u[3,4]*L[4,3]
                'd110: Mat_w[28] = Mat_r[28] - product_shift_r; //D[4] = A[4,4] - u[0,4]*L[4,0] (- u[1,4]*L[4,1]) - u[2,4]*L[4,2] - u[3,4]*L[4,3]
                'd113: Mat_w[28] = Mat_r[28] - product_shift_r; //D[4] = A[4,4] - u[0,4]*L[4,0] - u[1,4]*L[4,1] (- u[2,4]*L[4,2]) - u[3,4]*L[4,3]
                'd116: Mat_w[28] = Mat_r[28] - product_shift_r; //D[4] = A[4,4] - u[0,4]*L[4,0] - u[1,4]*L[4,1] - u[2,4]*L[4,2] (- u[3,4]*L[4,3])
                'd119: Mat_w[29] = Mat_r[29] - product_shift_r; //u[4,5] = A[4,5] (- u[0,5]*L[4,0]) - u[1,5]*L[4,1] - u[2,5]*L[4,2] - u[3,5]*L[4,3]
                'd122: Mat_w[29] = Mat_r[29] - product_shift_r; //u[4,5] = A[4,5] - u[0,5]*L[4,0] (- u[1,5]*L[4,1]) - u[2,5]*L[4,2] - u[3,5]*L[4,3]
                'd125: Mat_w[29] = Mat_r[29] - product_shift_r; //u[4,5] = A[4,5] - u[0,5]*L[4,0] - u[1,5]*L[4,1] (- u[2,5]*L[4,2]) - u[3,5]*L[4,3]
                'd128: Mat_w[29] = Mat_r[29] - product_shift_r; //u[4,5] = A[4,5] - u[0,5]*L[4,0] - u[1,5]*L[4,1] - u[2,5]*L[4,2] (- u[3,5]*L[4,3])
                'd131: Mat_w[34] = quotient;                    //L[5,4] = u[4,5]/D[4]
                'd134: Mat_w[35] = Mat_r[35] - product_shift_r; //D[5] = A[5,5] (- u[0,5]*L[5,0]) - u[1,5]*L[5,1] - u[2,5]*L[5,2] - u[3,5]*L[5,3] - u[4,5]*L[5,4]
                'd137: Mat_w[35] = Mat_r[35] - product_shift_r; //D[5] = A[5,5] - u[0,5]*L[5,0] (- u[1,5]*L[5,1]) - u[2,5]*L[5,2] - u[3,5]*L[5,3] - u[4,5]*L[5,4]
                'd140: Mat_w[35] = Mat_r[35] - product_shift_r; //D[5] = A[5,5] - u[0,5]*L[5,0] - u[1,5]*L[5,1] (- u[2,5]*L[5,2]) - u[3,5]*L[5,3] - u[4,5]*L[5,4]
                'd143: Mat_w[35] = Mat_r[35] - product_shift_r; //D[5] = A[5,5] - u[0,5]*L[5,0] - u[1,5]*L[5,1] - u[2,5]*L[5,2] (- u[3,5]*L[5,3]) - u[4,5]*L[5,4]
                'd146: Mat_w[35] = Mat_r[35] - product_shift_r; //D[5] = A[5,5] - u[0,5]*L[5,0] - u[1,5]*L[5,1] - u[2,5]*L[5,2] - u[3,5]*L[5,3] (- u[4,5]*L[5,4])
                default: begin for (j = 0; j < 36 ; j = j + 1) Mat_w[j] = Mat_r[j]; end
            endcase			
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
        else  done_r <= (cnt_r == 'd147);
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) product_shift_r <= '0;
        else  product_shift_r <= (product[MATRIX_BW+MATRIX_BW-1])? product_add[MATRIX_BW+MATRIX_BW:MUL] : product[MATRIX_BW+MATRIX_BW-1:MUL];
    end

    generate
    for (i = 0; i < 36 ; i = i + 1) begin
        always_ff @(posedge i_clk or negedge i_rst_n) begin
            if (!i_rst_n)      Mat_r[i] <= '0;
            else  Mat_r[i] <= Mat_w[i];
        end
    end
    endgenerate

endmodule

