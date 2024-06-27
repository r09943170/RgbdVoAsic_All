module seq_div_sign
#(
     parameter integer DEND_WIDTH = 32
    ,parameter integer DSOR_WIDTH = 32
    ,parameter integer CNT_WIDTH = 5
)
(
     input                         i_clk
    ,input                         i_rst_n
    ,input                         i_valid
    ,input        [DEND_WIDTH-1:0] i_Dend
    ,input        [DSOR_WIDTH-1:0] i_Dsor

    ,output logic                  o_valid
    ,output logic [DEND_WIDTH-1:0] o_Quot
    ,output logic [DSOR_WIDTH-1:0] o_Rder
);

    //=================================
    // Signal Declaration
    //=================================
    //state
    localparam N_OF_ST = 3;
    localparam IDLE = 3'b001;
    localparam CALC = 3'b010;
    localparam DONE = 3'b100;

    logic [N_OF_ST-1:0]               st_next;

    //st_IDLE initial
    logic [DEND_WIDTH-1:0]            Dend_abs;
    logic [DSOR_WIDTH-1:0]            Dsor_abs;
    logic                             sign_Quot;    //0:positive; 1:negative
    logic                             sign_Rder;    //0:positive; 1:negative
    logic                             en;

    //st_CALC
    logic [DSOR_WIDTH-1:0]            subtract_tmp;
    logic                             flag_pos;
    logic [DSOR_WIDTH+DEND_WIDTH-1:0] RQ_reg_w_pos;
    logic [DSOR_WIDTH+DEND_WIDTH-1:0] RQ_reg_w_neg;
    logic [DSOR_WIDTH+DEND_WIDTH-1:0] RQ_reg_w;

    logic                             flag_done;
    logic [CNT_WIDTH-1:0]             cnt_w;
    
    logic [N_OF_ST-1:0]               st_curr;
    logic [DSOR_WIDTH-1:0]            Dsor_r;
    logic [DSOR_WIDTH+DEND_WIDTH-1:0] RQ_reg_r;
    logic [CNT_WIDTH-1:0]             cnt_r;

    //st_DONE
    logic [DEND_WIDTH-1:0]            Quot_tmp;
    logic [DSOR_WIDTH-1:0]            Rder_tmp;

    //=================================
    // Combinational Logic
    //=================================
    //state
    always_comb begin
    	case(st_curr)
    		IDLE : begin if(en == 1)        st_next = CALC; else st_next = IDLE; end
            CALC : begin if(flag_done == 1) st_next = DONE; else st_next = CALC; end
            DONE : begin st_next = IDLE; end
    		default : st_next = IDLE;
    	endcase
    end

    //st_IDLE initial
    assign Dend_abs = i_Dend[DEND_WIDTH-1] ? -i_Dend : i_Dend;
    assign Dsor_abs = i_Dsor[DSOR_WIDTH-1] ? -i_Dsor : i_Dsor;
    assign en = (st_curr == IDLE) && (i_valid);

    //st_CALC
    assign subtract_tmp = RQ_reg_r[DSOR_WIDTH+DEND_WIDTH-1:DEND_WIDTH] - Dsor_r;
    assign flag_pos  = !subtract_tmp[DSOR_WIDTH-1];
    assign RQ_reg_w_pos = {subtract_tmp[DSOR_WIDTH-2:0], RQ_reg_r[DEND_WIDTH-1:0], flag_pos};
    assign RQ_reg_w_neg = {RQ_reg_r[DSOR_WIDTH+DEND_WIDTH-2:0], flag_pos};
    always_comb begin
        if (en == 1) RQ_reg_w = {{(DSOR_WIDTH-1){1'b0}}, Dend_abs, {1'b0}};
        else if (st_curr == CALC) RQ_reg_w = flag_pos ? RQ_reg_w_pos : RQ_reg_w_neg;
        else RQ_reg_w = '0;
    end
    
    assign flag_done = (cnt_r == (DEND_WIDTH-1));
    assign cnt_w = ((st_curr == CALC) && (!flag_done)) ? (cnt_r + 1) : 0;

    //st_DONE
    assign Quot_tmp = (Dsor_r == 0) ? 0 : RQ_reg_r[DEND_WIDTH-1:0];
    assign Rder_tmp = {{1'b0}, RQ_reg_r[DSOR_WIDTH+DEND_WIDTH-1:DEND_WIDTH+1]};
    assign o_valid = (st_curr == DONE);
    assign o_Quot  = sign_Quot ? -Quot_tmp : Quot_tmp;
    assign o_Rder  = sign_Rder ? -Rder_tmp : Rder_tmp;

    //===================
    //    Sequential
    //===================
    //state
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) st_curr <= IDLE;
        else          st_curr <= st_next;
    end

    //st_IDLE initial
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if      (!i_rst_n) Dsor_r <= '0;
        else if (en)       Dsor_r <= Dsor_abs;
        else if (o_valid)  Dsor_r <= '0;
        else               Dsor_r <= Dsor_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if      (!i_rst_n) sign_Quot <= '0;
        else if (en)       sign_Quot <= (i_Dend[DEND_WIDTH-1] ^ i_Dsor[DSOR_WIDTH-1]); // ^ : exclusive or
        else if (o_valid)  sign_Quot <= '0;
        else               sign_Quot <= sign_Quot;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if      (!i_rst_n) sign_Rder <= '0;
        else if (en)       sign_Rder <= i_Dend[DEND_WIDTH-1];
        else if (o_valid)  sign_Rder <= '0;
        else               sign_Rder <= sign_Rder;
    end

    //st_CALC
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) cnt_r <= '0;
        else          cnt_r <= cnt_w;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) RQ_reg_r <= '0;
        else          RQ_reg_r <= RQ_reg_w;
    end

endmodule