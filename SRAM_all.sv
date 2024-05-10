// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2023

module SRAM_all
    import RgbdVoConfigPk::*;
#(
)(  
    //input
     input                                           i_clk

    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    bus1_sram_QA [6]
    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    bus1_sram_QB [6]
    ,input                                           bus1_sram_WENA [6]
    ,input                                           bus1_sram_WENB [6]
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    bus1_sram_DA [6]
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    bus1_sram_DB [6]
    ,input        [H_SIZE_BW-1:0]                    bus1_sram_AA [6]
    ,input        [H_SIZE_BW-1:0]                    bus1_sram_AB [6]

    ,output logic [11:0]                             bus2_sram_QA [2]
    ,output logic [11:0]                             bus2_sram_QB [2]
    ,input                                           bus2_sram_WENA [2]
    ,input                                           bus2_sram_WENB [2]
    ,input        [11:0]                             bus2_sram_DA [2]
    ,input        [11:0]                             bus2_sram_DB [2]
    ,input        [H_SIZE_BW-1:0]                    bus2_sram_AA [2]
    ,input        [H_SIZE_BW-1:0]                    bus2_sram_AB [2]

    ,output logic [25:0]                             bus3_sram_QA
    ,output logic [25:0]                             bus3_sram_QB
    ,input                                           bus3_sram_WENA
    ,input                                           bus3_sram_WENB
    ,input        [25:0]                             bus3_sram_DA
    ,input        [25:0]                             bus3_sram_DB
    ,input        [H_SIZE_BW-1:0]                    bus3_sram_AA
    ,input        [H_SIZE_BW-1:0]                    bus3_sram_AB

    ,output logic [7:0]                              bus4_sram_QA [30]
    ,output logic [7:0]                              bus4_sram_QB [30]
    ,input                                           bus4_sram_WENA [30]
    ,input                                           bus4_sram_WENB [30]
    ,input        [7:0]                              bus4_sram_DA [30]
    ,input        [7:0]                              bus4_sram_DB [30]
    ,input        [H_SIZE_BW-1:0]                    bus4_sram_AA [30]
    ,input        [H_SIZE_BW-1:0]                    bus4_sram_AB [30]

    ,output logic [31:0]                             bus5_sram_QA [8]
    ,input                                           bus5_sram_WENA [8]
    ,input        [31:0]                             bus5_sram_DA [8]
    ,input        [8:0]                              bus5_sram_AA [8]

    ,output logic [31:0]                             bus6_sram_QA [8]
    ,input                                           bus6_sram_WENA [8]
    ,input        [31:0]                             bus6_sram_DA [8]
    ,input        [8:0]                              bus6_sram_AA [8]

    ,output logic [19:0]                             bus7_sram_QA
    ,input                                           bus7_sram_WENA
    ,input        [19:0]                             bus7_sram_DA
    ,input        [8:0]                              bus7_sram_AA

    ,output logic [19:0]                             bus8_sram_QA
    ,input                                           bus8_sram_WENA
    ,input        [19:0]                             bus8_sram_DA
    ,input        [8:0]                              bus8_sram_AA

    ,output logic [15:0]                             bus9_sram_QA
    ,input                                           bus9_sram_WENA
    ,input        [15:0]                             bus9_sram_DA
    ,input        [8:0]                              bus9_sram_AA

    ,output logic [15:0]                             bus10_sram_QA
    ,input                                           bus10_sram_WENA
    ,input        [15:0]                             bus10_sram_DA
    ,input        [8:0]                              bus10_sram_AA

    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    srcFrame_lb_sram_QA
    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    srcFrame_lb_sram_QB
    ,input                                           srcFrame_lb_sram_WENA
    ,input                                           srcFrame_lb_sram_WENB
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    srcFrame_lb_sram_DA
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    srcFrame_lb_sram_DB
    ,input        [H_SIZE_BW-1:0]                    srcFrame_lb_sram_AA
    ,input        [H_SIZE_BW-1:0]                    srcFrame_lb_sram_AB

    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    dstFrame_lb_sram_even_QA [63]
    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    dstFrame_lb_sram_even_QB [63]
    ,input                                           dstFrame_lb_sram_even_WENA [63]
    ,input                                           dstFrame_lb_sram_even_WENB [63]
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    dstFrame_lb_sram_even_DA [63]
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    dstFrame_lb_sram_even_DB [63]
    ,input        [H_SIZE_BW-2:0]                    dstFrame_lb_sram_even_AA [63]
    ,input        [H_SIZE_BW-2:0]                    dstFrame_lb_sram_even_AB [63]

    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    dstFrame_lb_sram_odd_QA [63]
    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    dstFrame_lb_sram_odd_QB [63]
    ,input                                           dstFrame_lb_sram_odd_WENA [63]
    ,input                                           dstFrame_lb_sram_odd_WENB [63]
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    dstFrame_lb_sram_odd_DA [63]
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    dstFrame_lb_sram_odd_DB [63]
    ,input        [H_SIZE_BW-2:0]                    dstFrame_lb_sram_odd_AA [63]
    ,input        [H_SIZE_BW-2:0]                    dstFrame_lb_sram_odd_AB [63]
);

    //=================================
    // Signal Declaration
    //=================================

    //=================================
    // Combinational Logic
    //=================================
    //Feature_based
    generate
        for(genvar s = 0; s < 6; s = s+1) begin
            sram_lb_FAST uut1 (
                // clock signal
                .CLKA(i_clk),
                .CLKB(i_clk),

                // sync clock (active high)
                .STOVA(1'b1),
                .STOVB(1'b1),

                // setting
                // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
                // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
                // if the read row address and write row address match.
                .COLLDISN(1'b0),

                // address
                .AA(bus1_sram_AA[s]),
                .AB(bus1_sram_AB[s]),
                // data 
                .DA(bus1_sram_DA[s]),
                .DB(bus1_sram_DB[s]),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b0),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(bus1_sram_WENA[s]),
                .WENB(bus1_sram_WENB[s]),

                // data output bus
                .QA(bus1_sram_QA[s]),
                .QB(bus1_sram_QB[s]),

                // test mode (active low, 1 for regular operation)
                .TENA(1'b1),
                .TENB(1'b1),

                // bypass
                .BENA(1'b1),
                .BENB(1'b1),

                // useless
                .EMAA(3'd0),
                .EMAB(3'd0),
                .EMAWA(2'd0),
                .EMAWB(2'd0),
                .EMASA(1'b0),
                .EMASB(1'b0),
                .TCENA(1'b1),
                .TWENA(1'b1),
                .TAA(10'd0),
                .TDA(24'd0),
                .TQA(24'd0),
                .TCENB(1'b1),
                .TWENB(1'b1),
                .TAB(10'd0),
                .TDB(24'd0),
                .TQB(24'd0),
                .RET1N(1'b1)
            );
        end
    endgenerate

    generate
        for(genvar s = 0; s < 2; s = s+1) begin
            sram_dp_sincos uut2 (
                // clock signal
                .CLKA(i_clk),
                .CLKB(i_clk),

                // sync clock (active high)
                .STOVA(1'b1),
                .STOVB(1'b1),

                // setting
                // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
                // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
                // if the read row address and write row address match.
                .COLLDISN(1'b0),

                // address
                .AA(bus2_sram_AA[s]),
                .AB(bus2_sram_AB[s]),
                // data 
                .DA(bus2_sram_DA[s]),
                .DB(bus2_sram_DB[s]),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b0),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(bus2_sram_WENA[s]),
                .WENB(bus2_sram_WENB[s]),

                // data output bus
                .QA(bus2_sram_QA[s]),
                .QB(bus2_sram_QB[s]),

                // test mode (active low, 1 for regular operation)
                .TENA(1'b1),
                .TENB(1'b1),

                // bypass
                .BENA(1'b1),
                .BENB(1'b1),

                // useless
                .EMAA(3'd0),
                .EMAB(3'd0),
                .EMAWA(2'd0),
                .EMAWB(2'd0),
                .EMASA(1'b0),
                .EMASB(1'b0),
                .TCENA(1'b1),
                .TWENA(1'b1),
                .TAA(10'd0),
                .TDA(12'd0),
                .TQA(12'd0),
                .TCENB(1'b1),
                .TWENB(1'b1),
                .TAB(10'd0),
                .TDB(12'd0),
                .TQB(12'd0),
                .RET1N(1'b1)
            );
        end
    endgenerate

    sram_FIFO_NMS uut3 (
        // clock signal
        .CLKA(i_clk),
        .CLKB(i_clk),

        // sync clock (active high)
        .STOVA(1'b1),
        .STOVB(1'b1),

        // setting
        // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
        // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
        // if the read row address and write row address match.
        .COLLDISN(1'b0),

        // address
        .AA(bus3_sram_AA),
        .AB(bus3_sram_AB),
        // data 
        .DA(bus3_sram_DA),
        .DB(bus3_sram_DB),

        // chip enable (active low, 0 for ON and 1 for OFF)
        // .CENA(1'b1),
        // .CENB(1'b1),
        .CENA(1'b0),
        .CENB(1'b0),

        // write enable (active low, 0 for WRITE and 1 for READ)
        .WENA(bus3_sram_WENA),
        .WENB(bus3_sram_WENB),

        // data output bus
        .QA(bus3_sram_QA),
        .QB(bus3_sram_QB),

        // test mode (active low, 1 for regular operation)
        .TENA(1'b1),
        .TENB(1'b1),

        // bypass
        .BENA(1'b1),
        .BENB(1'b1),

        // useless
        .EMAA(3'd0),
        .EMAB(3'd0),
        .EMAWA(2'd0),
        .EMAWB(2'd0),
        .EMASA(1'b0),
        .EMASB(1'b0),
        .TCENA(1'b1),
        .TWENA(1'b1),
        .TAA(10'd0),
        .TDA(26'd0),
        .TQA(26'd0),
        .TCENB(1'b1),
        .TWENB(1'b1),
        .TAB(10'd0),
        .TDB(26'd0),
        .TQB(26'd0),
        .RET1N(1'b1)
    );

    generate
        for(genvar s = 0; s < 30; s = s+1) begin
            sram_BRIEF_lb uut4 (
                // clock signal
                .CLKA(i_clk),
                .CLKB(i_clk),

                // sync clock (active high)
                .STOVA(1'b1),
                .STOVB(1'b1),

                // setting
                // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
                // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
                // if the read row address and write row address match.
                .COLLDISN(1'b0),

                // address
                .AA(bus4_sram_AA[s]),
                .AB(bus4_sram_AB[s]),
                // data 
                .DA(bus4_sram_DA[s]),
                .DB(bus4_sram_DB[s]),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b0),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(bus4_sram_WENA[s]),
                .WENB(bus4_sram_WENB[s]),

                // data output bus
                .QA(bus4_sram_QA[s]),
                .QB(bus4_sram_QB[s]),

                // test mode (active low, 1 for regular operation)
                .TENA(1'b1),
                .TENB(1'b1),

                // bypass
                .BENA(1'b1),
                .BENB(1'b1),

                // useless
                .EMAA(3'd0),
                .EMAB(3'd0),
                .EMAWA(2'd0),
                .EMAWB(2'd0),
                .EMASA(1'b0),
                .EMASB(1'b0),
                .TCENA(1'b1),
                .TWENA(1'b1),
                .TAA(10'd0),
                .TDA(8'd0),
                .TQA(8'd0),
                .TCENB(1'b1),
                .TWENB(1'b1),
                .TAB(10'd0),
                .TDB(8'd0),
                .TQB(8'd0),
                .RET1N(1'b1)
            );
        end
    endgenerate

    generate
        for(genvar s = 0; s < 8; s = s+1) begin
            sram_dp_desc uut5 (
                // clock signal
                .CLKA(i_clk),
                .CLKB(i_clk),

                // sync clock (active high)
                .STOVA(1'b1),
                .STOVB(1'b1),

                // setting
                // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
                // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
                // if the read row address and write row address match.
                .COLLDISN(1'b0),

                // address
                .AA(bus5_sram_AA[s]),
                .AB(9'd0),
                // data 
                .DA(bus5_sram_DA[s]),
                .DB(32'd0),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b1),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(bus5_sram_WENA[s]),
                .WENB(1'b1),

                // data output bus
                .QA(bus5_sram_QA[s]),
                .QB(),

                // test mode (active low, 1 for regular operation)
                .TENA(1'b1),
                .TENB(1'b1),

                // bypass
                .BENA(1'b1),
                .BENB(1'b1),

                // useless
                .EMAA(3'd0),
                .EMAB(3'd0),
                .EMAWA(2'd0),
                .EMAWB(2'd0),
                .EMASA(1'b0),
                .EMASB(1'b0),
                .TCENA(1'b1),
                .TWENA(1'b1),
                .TAA(9'd0),
                .TDA(32'd0),
                .TQA(32'd0),
                .TCENB(1'b1),
                .TWENB(1'b1),
                .TAB(9'd0),
                .TDB(32'd0),
                .TQB(32'd0),
                .RET1N(1'b1)
            );
        end
    endgenerate

    generate
        for(genvar s = 0; s < 8; s = s+1) begin
            sram_dp_desc uut6 (
                // clock signal
                .CLKA(i_clk),
                .CLKB(i_clk),

                // sync clock (active high)
                .STOVA(1'b1),
                .STOVB(1'b1),

                // setting
                // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
                // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
                // if the read row address and write row address match.
                .COLLDISN(1'b0),

                // address
                .AA(bus6_sram_AA[s]),
                .AB(9'd0),
                // data 
                .DA(bus6_sram_DA[s]),
                .DB(32'd0),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b1),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(bus6_sram_WENA[s]),
                .WENB(1'b1),

                // data output bus
                .QA(bus6_sram_QA[s]),
                .QB(),

                // test mode (active low, 1 for regular operation)
                .TENA(1'b1),
                .TENB(1'b1),

                // bypass
                .BENA(1'b1),
                .BENB(1'b1),

                // useless
                .EMAA(3'd0),
                .EMAB(3'd0),
                .EMAWA(2'd0),
                .EMAWB(2'd0),
                .EMASA(1'b0),
                .EMASB(1'b0),
                .TCENA(1'b1),
                .TWENA(1'b1),
                .TAA(9'd0),
                .TDA(32'd0),
                .TQA(32'd0),
                .TCENB(1'b1),
                .TWENB(1'b1),
                .TAB(9'd0),
                .TDB(32'd0),
                .TQB(32'd0),
                .RET1N(1'b1)
            );
        end
    endgenerate

    sram_dp_point uut7 (
        // clock signal
        .CLKA(i_clk),
        .CLKB(i_clk),

        // sync clock (active high)
        .STOVA(1'b1),
        .STOVB(1'b1),

        // setting
        // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
        // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
        // if the read row address and write row address match.
        .COLLDISN(1'b0),

        // address
        .AA(bus7_sram_AA),
        .AB(9'd0),
        // data 
        .DA(bus7_sram_DA),
        .DB(20'd0),

        // chip enable (active low, 0 for ON and 1 for OFF)
        // .CENA(1'b1),
        // .CENB(1'b1),
        .CENA(1'b0),
        .CENB(1'b1),

        // write enable (active low, 0 for WRITE and 1 for READ)
        .WENA(bus7_sram_WENA),
        .WENB(1'b1),

        // data output bus
        .QA(bus7_sram_QA),
        .QB(),

        // test mode (active low, 1 for regular operation)
        .TENA(1'b1),
        .TENB(1'b1),

        // bypass
        .BENA(1'b1),
        .BENB(1'b1),

        // useless
        .EMAA(3'd0),
        .EMAB(3'd0),
        .EMAWA(2'd0),
        .EMAWB(2'd0),
        .EMASA(1'b0),
        .EMASB(1'b0),
        .TCENA(1'b1),
        .TWENA(1'b1),
        .TAA(9'd0),
        .TDA(20'd0),
        .TQA(20'd0),
        .TCENB(1'b1),
        .TWENB(1'b1),
        .TAB(9'd0),
        .TDB(20'd0),
        .TQB(20'd0),
        .RET1N(1'b1)
    );

    sram_dp_point uut8 (
        // clock signal
        .CLKA(i_clk),
        .CLKB(i_clk),

        // sync clock (active high)
        .STOVA(1'b1),
        .STOVB(1'b1),

        // setting
        // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
        // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
        // if the read row address and write row address match.
        .COLLDISN(1'b0),

        // address
        .AA(bus8_sram_AA),
        .AB(9'd0),
        // data 
        .DA(bus8_sram_DA),
        .DB(20'd0),

        // chip enable (active low, 0 for ON and 1 for OFF)
        // .CENA(1'b1),
        // .CENB(1'b1),
        .CENA(1'b0),
        .CENB(1'b1),

        // write enable (active low, 0 for WRITE and 1 for READ)
        .WENA(bus8_sram_WENA),
        .WENB(1'b1),

        // data output bus
        .QA(bus8_sram_QA),
        .QB(),

        // test mode (active low, 1 for regular operation)
        .TENA(1'b1),
        .TENB(1'b1),

        // bypass
        .BENA(1'b1),
        .BENB(1'b1),

        // useless
        .EMAA(3'd0),
        .EMAB(3'd0),
        .EMAWA(2'd0),
        .EMAWB(2'd0),
        .EMASA(1'b0),
        .EMASB(1'b0),
        .TCENA(1'b1),
        .TWENA(1'b1),
        .TAA(9'd0),
        .TDA(20'd0),
        .TQA(20'd0),
        .TCENB(1'b1),
        .TWENB(1'b1),
        .TAB(9'd0),
        .TDB(20'd0),
        .TQB(20'd0),
        .RET1N(1'b1)
    );

    sram_dp_depth uut9 (
        // clock signal
        .CLKA(i_clk),
        .CLKB(i_clk),

        // sync clock (active high)
        .STOVA(1'b1),
        .STOVB(1'b1),

        // setting
        // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
        // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
        // if the read row address and write row address match.
        .COLLDISN(1'b0),

        // address
        .AA(bus9_sram_AA),
        .AB(9'd0),
        // data 
        .DA(bus9_sram_DA),
        .DB(16'd0),

        // chip enable (active low, 0 for ON and 1 for OFF)
        // .CENA(1'b1),
        // .CENB(1'b1),
        .CENA(1'b0),
        .CENB(1'b1),

        // write enable (active low, 0 for WRITE and 1 for READ)
        .WENA(bus9_sram_WENA),
        .WENB(1'b1),

        // data output bus
        .QA(bus9_sram_QA),
        .QB(),

        // test mode (active low, 1 for regular operation)
        .TENA(1'b1),
        .TENB(1'b1),

        // bypass
        .BENA(1'b1),
        .BENB(1'b1),

        // useless
        .EMAA(3'd0),
        .EMAB(3'd0),
        .EMAWA(2'd0),
        .EMAWB(2'd0),
        .EMASA(1'b0),
        .EMASB(1'b0),
        .TCENA(1'b1),
        .TWENA(1'b1),
        .TAA(9'd0),
        .TDA(16'd0),
        .TQA(16'd0),
        .TCENB(1'b1),
        .TWENB(1'b1),
        .TAB(9'd0),
        .TDB(16'd0),
        .TQB(16'd0),
        .RET1N(1'b1)
    );

    sram_dp_depth uut10 (
        // clock signal
        .CLKA(i_clk),
        .CLKB(i_clk),

        // sync clock (active high)
        .STOVA(1'b1),
        .STOVB(1'b1),

        // setting
        // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
        // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
        // if the read row address and write row address match.
        .COLLDISN(1'b0),

        // address
        .AA(bus10_sram_AA),
        .AB(9'd0),
        // data 
        .DA(bus10_sram_DA),
        .DB(16'd0),

        // chip enable (active low, 0 for ON and 1 for OFF)
        // .CENA(1'b1),
        // .CENB(1'b1),
        .CENA(1'b0),
        .CENB(1'b1),

        // write enable (active low, 0 for WRITE and 1 for READ)
        .WENA(bus10_sram_WENA),
        .WENB(1'b1),

        // data output bus
        .QA(bus10_sram_QA),
        .QB(),

        // test mode (active low, 1 for regular operation)
        .TENA(1'b1),
        .TENB(1'b1),

        // bypass
        .BENA(1'b1),
        .BENB(1'b1),

        // useless
        .EMAA(3'd0),
        .EMAB(3'd0),
        .EMAWA(2'd0),
        .EMAWB(2'd0),
        .EMASA(1'b0),
        .EMASB(1'b0),
        .TCENA(1'b1),
        .TWENA(1'b1),
        .TAA(9'd0),
        .TDA(16'd0),
        .TQA(16'd0),
        .TCENB(1'b1),
        .TWENB(1'b1),
        .TAB(9'd0),
        .TDB(16'd0),
        .TQB(16'd0),
        .RET1N(1'b1)
    );

    //Direct
    generate
        sram_lb_FAST uut11 (
            // clock signal
            .CLKA(i_clk),
            .CLKB(i_clk),
            // sync clock (active high)
            .STOVA(1'b1),
            .STOVB(1'b1),
            // setting
            // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
            // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
            // if the read row address and write row address match.
            .COLLDISN(1'b0),
            // address
            .AA(srcFrame_lb_sram_AA),
            .AB(srcFrame_lb_sram_AB),
            // data 
            .DA(srcFrame_lb_sram_DA),
            .DB(srcFrame_lb_sram_DB),
            // chip enable (active low, 0 for ON and 1 for OFF)
            // .CENA(1'b1),
            // .CENB(1'b1),
            .CENA(1'b0),
            .CENB(1'b0),
            // write enable (active low, 0 for WRITE and 1 for READ)
            .WENA(srcFrame_lb_sram_WENA),
            .WENB(srcFrame_lb_sram_WENB),
            // data output bus
            .QA(srcFrame_lb_sram_QA),
            .QB(srcFrame_lb_sram_QB),
            // test mode (active low, 1 for regular operation)
            .TENA(1'b1),
            .TENB(1'b1),
            // bypass
            .BENA(1'b1),
            .BENB(1'b1),
            // useless
            .EMAA(3'd0),
            .EMAB(3'd0),
            .EMAWA(2'd0),
            .EMAWB(2'd0),
            .EMASA(1'b0),
            .EMASB(1'b0),
            .TCENA(1'b1),
            .TWENA(1'b1),
            .TAA(10'd0),
            .TDA(24'd0),
            .TQA(24'd0),
            .TCENB(1'b1),
            .TWENB(1'b1),
            .TAB(10'd0),
            .TDB(24'd0),
            .TQB(24'd0),
            .RET1N(1'b1)
        );
        for(genvar s = 0; s < 63; s = s+1) begin
            sram_dp_dstFrame uut12 (
                // clock signal
                .CLKA(i_clk),
                .CLKB(i_clk),

                // sync clock (active high)
                .STOVA(1'b1),
                .STOVB(1'b1),

                // setting
                // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
                // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
                // if the read row address and write row address match.
                .COLLDISN(1'b0),

                // address
                .AA(dstFrame_lb_sram_even_AA[s]),
                .AB(dstFrame_lb_sram_even_AB[s]),
                // data 
                .DA(dstFrame_lb_sram_even_DA[s]),
                .DB(dstFrame_lb_sram_even_DB[s]),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b0),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(dstFrame_lb_sram_even_WENA[s]),
                .WENB(dstFrame_lb_sram_even_WENB[s]),

                // data output bus
                .QA(dstFrame_lb_sram_even_QA[s]),
                .QB(dstFrame_lb_sram_even_QB[s]),

                // test mode (active low, 1 for regular operation)
                .TENA(1'b1),
                .TENB(1'b1),

                // bypass
                .BENA(1'b1),
                .BENB(1'b1),

                // useless
                .EMAA(3'd0),
                .EMAB(3'd0),
                .EMAWA(2'd0),
                .EMAWB(2'd0),
                .EMASA(1'b0),
                .EMASB(1'b0),
                .TCENA(1'b1),
                .TWENA(1'b1),
                .TAA(9'd0),
                .TDA(24'd0),
                .TQA(24'd0),
                .TCENB(1'b1),
                .TWENB(1'b1),
                .TAB(9'd0),
                .TDB(24'd0),
                .TQB(24'd0),
                .RET1N(1'b1)
            );
        end
        for(genvar s = 0; s < 63; s = s+1) begin
            sram_dp_dstFrame uut13 (
                // clock signal
                .CLKA(i_clk),
                .CLKB(i_clk),

                // sync clock (active high)
                .STOVA(1'b1),
                .STOVB(1'b1),

                // setting
                // In the event of a write/read collision, if COLLDISN is disabled, then the write is guaranteed and
                // the read data is undefined. However, if COLLDISN is enabled, then the write is not guaranteed
                // if the read row address and write row address match.
                .COLLDISN(1'b0),

                // address
                .AA(dstFrame_lb_sram_odd_AA[s]),
                .AB(dstFrame_lb_sram_odd_AB[s]),
                // data 
                .DA(dstFrame_lb_sram_odd_DA[s]),
                .DB(dstFrame_lb_sram_odd_DB[s]),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b0),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(dstFrame_lb_sram_odd_WENA[s]),
                .WENB(dstFrame_lb_sram_odd_WENB[s]),

                // data output bus
                .QA(dstFrame_lb_sram_odd_QA[s]),
                .QB(dstFrame_lb_sram_odd_QB[s]),

                // test mode (active low, 1 for regular operation)
                .TENA(1'b1),
                .TENB(1'b1),

                // bypass
                .BENA(1'b1),
                .BENB(1'b1),

                // useless
                .EMAA(3'd0),
                .EMAB(3'd0),
                .EMAWA(2'd0),
                .EMAWB(2'd0),
                .EMASA(1'b0),
                .EMASB(1'b0),
                .TCENA(1'b1),
                .TWENA(1'b1),
                .TAA(9'd0),
                .TDA(24'd0),
                .TQA(24'd0),
                .TCENB(1'b1),
                .TWENB(1'b1),
                .TAB(9'd0),
                .TDB(24'd0),
                .TQB(24'd0),
                .RET1N(1'b1)
            );
        end
    endgenerate

    //===================
    //    Sequential
    //===================


endmodule