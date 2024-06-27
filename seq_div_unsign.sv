// `include "BRIEF_Top.sv"
// `include "FAST.sv"
// `include "MATCH_Top.sv"

module seq_div_unsign
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
    localparam N_OF_ST = 3;
    localparam IDLE = 3'b001;
    localparam CALC = 3'b010;
    localparam DONE = 3'b100;

    logic [N_OF_ST-1:0]               st_next;
    logic                             en;
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

    assign en = (st_curr == IDLE) && (i_valid);
    assign subtract_tmp = RQ_reg_r[DSOR_WIDTH+DEND_WIDTH-1:DEND_WIDTH] - Dsor_r;
    assign flag_pos  = !subtract_tmp[DSOR_WIDTH-1];
    assign RQ_reg_w_pos = {subtract_tmp[DSOR_WIDTH-2:0], RQ_reg_r[DEND_WIDTH-1:0], flag_pos};
    assign RQ_reg_w_neg = {RQ_reg_r[DSOR_WIDTH+DEND_WIDTH-2:0], flag_pos};
    always_comb begin
        if (en == 1) RQ_reg_w = {{(DSOR_WIDTH-1){1'b0}}, i_Dend, {1'b0}};
        else if (st_curr == CALC) RQ_reg_w = flag_pos ? RQ_reg_w_pos : RQ_reg_w_neg;
        else RQ_reg_w = '0;
    end
    
    assign flag_done = (cnt_r == (DEND_WIDTH-1));
    assign cnt_w = ((st_curr == CALC) && (!flag_done)) ? (cnt_r + 1) : 0;

    assign o_valid = (st_curr == DONE);
    assign o_Quot  = RQ_reg_r[DEND_WIDTH-1:0];
    assign o_Rder  = {{1'b0}, RQ_reg_r[DSOR_WIDTH+DEND_WIDTH-1:DEND_WIDTH+1]};

    //===================
    //    Sequential
    //===================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) st_curr <= IDLE;
        else          st_curr <= st_next;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if      (!i_rst_n) Dsor_r <= '0;
        else if (en)       Dsor_r <= i_Dsor;
        else if (o_valid)  Dsor_r <= '0;
        else               Dsor_r <= Dsor_r;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) cnt_r <= '0;
        else          cnt_r <= cnt_w;
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) RQ_reg_r <= '0;
        else          RQ_reg_r <= RQ_reg_w;
    end

endmodule