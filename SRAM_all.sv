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
    ,input                                           i_rst_n
    ,input                                           i_f_or_d

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

    ,input                                           Feature_dstFrame_lb_sram_even_WENA [5]
    ,input                                           Feature_dstFrame_lb_sram_even_WENB [5]
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    Feature_dstFrame_lb_sram_even_DA [5]
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    Feature_dstFrame_lb_sram_even_DB [5]
    ,input        [H_SIZE_BW-2:0]                    Feature_dstFrame_lb_sram_even_AA [5]
    ,input        [H_SIZE_BW-2:0]                    Feature_dstFrame_lb_sram_even_AB [5]

    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    srcFrame_lb_sram_QA
    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    srcFrame_lb_sram_QB
    ,input                                           Corr_srcFrame_lb_sram_WENA
    ,input                                           Corr_srcFrame_lb_sram_WENB
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    Corr_srcFrame_lb_sram_DA
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    Corr_srcFrame_lb_sram_DB
    ,input        [H_SIZE_BW-1:0]                    Corr_srcFrame_lb_sram_AA
    ,input        [H_SIZE_BW-1:0]                    Corr_srcFrame_lb_sram_AB

    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    dstFrame_lb_sram_even_QA [63]
    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    dstFrame_lb_sram_even_QB [63]
    ,input                                           Corr_dstFrame_lb_sram_even_WENA [63]
    ,input                                           Corr_dstFrame_lb_sram_even_WENB [63]
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    Corr_dstFrame_lb_sram_even_DA [63]
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    Corr_dstFrame_lb_sram_even_DB [63]
    ,input        [H_SIZE_BW-2:0]                    Corr_dstFrame_lb_sram_even_AA [63]
    ,input        [H_SIZE_BW-2:0]                    Corr_dstFrame_lb_sram_even_AB [63]

    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    dstFrame_lb_sram_odd_QA [63]
    ,output logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    dstFrame_lb_sram_odd_QB [63]
    ,input                                           Corr_dstFrame_lb_sram_odd_WENA [63]
    ,input                                           Corr_dstFrame_lb_sram_odd_WENB [63]
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    Corr_dstFrame_lb_sram_odd_DA [63]
    ,input        [DATA_RGB_BW+DATA_DEPTH_BW-1:0]    Corr_dstFrame_lb_sram_odd_DB [63]
    ,input        [H_SIZE_BW-2:0]                    Corr_dstFrame_lb_sram_odd_AA [63]
    ,input        [H_SIZE_BW-2:0]                    Corr_dstFrame_lb_sram_odd_AB [63]
);

    //=================================
    // Signal Declaration
    //=================================
    logic                                 bus1_sram_AA_0[0:5];
    logic                                 bus1_sram_AB_0[0:5];

    logic                                 bus2_sram_AA_0[0:1];
    logic                                 bus2_sram_AB_0[0:1];

    logic                                 bus3_sram_AA_0;
    logic                                 bus3_sram_AB_0;

    logic                                 bus4_sram_AA_0[0:29];
    logic                                 bus4_sram_AB_0[0:29];

    logic                                 bus5_sram_AA_0[0:7];

    logic [7:0]                           bus5_sram_QA_8 [0:7];

    logic                                 bus6_sram_AA_0[0:7];

    logic [7:0]                           bus6_sram_QA_8 [0:7];

    logic                                 bus7_sram_AA_0;

    logic                                 bus8_sram_AA_0;

    logic                                 bus9_sram_AA_0;

    logic                                 bus10_sram_AA_0;

    logic                                 srcFrame_lb_sram_WENA;
    logic                                 srcFrame_lb_sram_WENB;
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] srcFrame_lb_sram_DA;
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] srcFrame_lb_sram_DB;
    logic [H_SIZE_BW-1:0]                 srcFrame_lb_sram_AA;
    logic [H_SIZE_BW-1:0]                 srcFrame_lb_sram_AB;

    logic                                 dstFrame_lb_sram_even_WENA[0:62];
    logic                                 dstFrame_lb_sram_even_WENB[0:62];
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] dstFrame_lb_sram_even_DA[0:62];
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] dstFrame_lb_sram_even_DB[0:62];
    logic [H_SIZE_BW-2:0]                 dstFrame_lb_sram_even_AA[0:62];
    logic [H_SIZE_BW-2:0]                 dstFrame_lb_sram_even_AB[0:62];

    logic                                 dstFrame_lb_sram_odd_WENA[0:62];
    logic                                 dstFrame_lb_sram_odd_WENB[0:62];
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] dstFrame_lb_sram_odd_DA[0:62];
    logic [DATA_RGB_BW+DATA_DEPTH_BW-1:0] dstFrame_lb_sram_odd_DB[0:62];
    logic [H_SIZE_BW-2:0]                 dstFrame_lb_sram_odd_AA[0:62];
    logic [H_SIZE_BW-2:0]                 dstFrame_lb_sram_odd_AB[0:62];

    //=================================
    // Combinational Logic
    //=================================

    always_comb begin
    //Corresps_points (even 0-4)
        for(int i = 0; i <= 4; i = i + 1)begin
            dstFrame_lb_sram_even_WENA[i] = (!i_f_or_d) ? Feature_dstFrame_lb_sram_even_WENA[i] : Corr_dstFrame_lb_sram_even_WENA[i];
            dstFrame_lb_sram_even_WENB[i] = (!i_f_or_d) ? Feature_dstFrame_lb_sram_even_WENB[i] : Corr_dstFrame_lb_sram_even_WENB[i];
            dstFrame_lb_sram_even_DA[i]   = (!i_f_or_d) ? Feature_dstFrame_lb_sram_even_DA[i]   : Corr_dstFrame_lb_sram_even_DA[i]  ;
            dstFrame_lb_sram_even_DB[i]   = (!i_f_or_d) ? Feature_dstFrame_lb_sram_even_DB[i]   : Corr_dstFrame_lb_sram_even_DB[i]  ;
            dstFrame_lb_sram_even_AA[i]   = (!i_f_or_d) ? Feature_dstFrame_lb_sram_even_AA[i]   : Corr_dstFrame_lb_sram_even_AA[i]  ;
            dstFrame_lb_sram_even_AB[i]   = (!i_f_or_d) ? Feature_dstFrame_lb_sram_even_AB[i]   : Corr_dstFrame_lb_sram_even_AB[i]  ;
        end

    //line buffer for FAST (bus1 - 6*640words/24bits) (even 5-16)
        for(int i = 5; i <= 10; i = i + 1)begin
            dstFrame_lb_sram_even_WENA[i] = (!i_f_or_d) ? ((bus1_sram_AA[i-5][0] == 0) ? bus1_sram_WENA[i-5] : 1) : Corr_dstFrame_lb_sram_even_WENA[i];
            dstFrame_lb_sram_even_WENB[i] = (!i_f_or_d) ? ((bus1_sram_AB[i-5][0] == 0) ? bus1_sram_WENB[i-5] : 1) : Corr_dstFrame_lb_sram_even_WENB[i];
            dstFrame_lb_sram_even_DA[i]   = (!i_f_or_d) ? bus1_sram_DA[i-5]                                       : Corr_dstFrame_lb_sram_even_DA[i]  ;
            dstFrame_lb_sram_even_DB[i]   = (!i_f_or_d) ? bus1_sram_DB[i-5]                                       : Corr_dstFrame_lb_sram_even_DB[i]  ;
            dstFrame_lb_sram_even_AA[i]   = (!i_f_or_d) ? bus1_sram_AA[i-5][H_SIZE_BW-1:1]                        : Corr_dstFrame_lb_sram_even_AA[i]  ;
            dstFrame_lb_sram_even_AB[i]   = (!i_f_or_d) ? bus1_sram_AB[i-5][H_SIZE_BW-1:1]                        : Corr_dstFrame_lb_sram_even_AB[i]  ;
        end
        for(int i = 11; i <= 16; i = i + 1)begin
            dstFrame_lb_sram_even_WENA[i] = (!i_f_or_d) ? ((bus1_sram_AA[i-11][0] == 1) ? bus1_sram_WENA[i-11] : 1) : Corr_dstFrame_lb_sram_even_WENA[i];
            dstFrame_lb_sram_even_WENB[i] = (!i_f_or_d) ? ((bus1_sram_AB[i-11][0] == 1) ? bus1_sram_WENB[i-11] : 1) : Corr_dstFrame_lb_sram_even_WENB[i];
            dstFrame_lb_sram_even_DA[i]   = (!i_f_or_d) ? bus1_sram_DA[i-11]                                        : Corr_dstFrame_lb_sram_even_DA[i]  ;
            dstFrame_lb_sram_even_DB[i]   = (!i_f_or_d) ? bus1_sram_DB[i-11]                                        : Corr_dstFrame_lb_sram_even_DB[i]  ;
            dstFrame_lb_sram_even_AA[i]   = (!i_f_or_d) ? bus1_sram_AA[i-11][H_SIZE_BW-1:1]                         : Corr_dstFrame_lb_sram_even_AA[i]  ;
            dstFrame_lb_sram_even_AB[i]   = (!i_f_or_d) ? bus1_sram_AB[i-11][H_SIZE_BW-1:1]                         : Corr_dstFrame_lb_sram_even_AB[i]  ;
        end
        for(int i = 0; i <= 5; i = i + 1)begin
            bus1_sram_QA[i] = (!i_f_or_d) ? ((bus1_sram_AA_0[i] == 0) ? dstFrame_lb_sram_even_QA[i+5] : dstFrame_lb_sram_even_QA[i+11]) : 0;
            bus1_sram_QB[i] = (!i_f_or_d) ? ((bus1_sram_AB_0[i] == 0) ? dstFrame_lb_sram_even_QB[i+5] : dstFrame_lb_sram_even_QB[i+11]) : 0;
        end

    //FIFO for sin, cos (bus2 - 2*640words/12bits) (even 17-20)
        for(int i = 17; i <= 18; i = i + 1)begin
            dstFrame_lb_sram_even_WENA[i] = (!i_f_or_d) ? ((bus2_sram_AA[i-17][0] == 0) ? bus2_sram_WENA[i-17] : 1) : Corr_dstFrame_lb_sram_even_WENA[i];
            dstFrame_lb_sram_even_WENB[i] = (!i_f_or_d) ? ((bus2_sram_AB[i-17][0] == 0) ? bus2_sram_WENB[i-17] : 1) : Corr_dstFrame_lb_sram_even_WENB[i];
            dstFrame_lb_sram_even_DA[i]   = (!i_f_or_d) ? {{12{1'b0}},{bus2_sram_DA[i-17]}}                         : Corr_dstFrame_lb_sram_even_DA[i]  ;
            dstFrame_lb_sram_even_DB[i]   = (!i_f_or_d) ? {{12{1'b0}},{bus2_sram_DB[i-17]}}                         : Corr_dstFrame_lb_sram_even_DB[i]  ;
            dstFrame_lb_sram_even_AA[i]   = (!i_f_or_d) ? bus2_sram_AA[i-17][H_SIZE_BW-1:1]                         : Corr_dstFrame_lb_sram_even_AA[i]  ;
            dstFrame_lb_sram_even_AB[i]   = (!i_f_or_d) ? bus2_sram_AB[i-17][H_SIZE_BW-1:1]                         : Corr_dstFrame_lb_sram_even_AB[i]  ;
        end
        for(int i = 19; i <= 20; i = i + 1)begin
            dstFrame_lb_sram_even_WENA[i] = (!i_f_or_d) ? ((bus2_sram_AA[i-19][0] == 1) ? bus2_sram_WENA[i-19] : 1) : Corr_dstFrame_lb_sram_even_WENA[i];
            dstFrame_lb_sram_even_WENB[i] = (!i_f_or_d) ? ((bus2_sram_AB[i-19][0] == 1) ? bus2_sram_WENB[i-19] : 1) : Corr_dstFrame_lb_sram_even_WENB[i];
            dstFrame_lb_sram_even_DA[i]   = (!i_f_or_d) ? {{12{1'b0}},{bus2_sram_DA[i-19]}}                         : Corr_dstFrame_lb_sram_even_DA[i]  ;
            dstFrame_lb_sram_even_DB[i]   = (!i_f_or_d) ? {{12{1'b0}},{bus2_sram_DB[i-19]}}                         : Corr_dstFrame_lb_sram_even_DB[i]  ;
            dstFrame_lb_sram_even_AA[i]   = (!i_f_or_d) ? bus2_sram_AA[i-19][H_SIZE_BW-1:1]                         : Corr_dstFrame_lb_sram_even_AA[i]  ;
            dstFrame_lb_sram_even_AB[i]   = (!i_f_or_d) ? bus2_sram_AB[i-19][H_SIZE_BW-1:1]                         : Corr_dstFrame_lb_sram_even_AB[i]  ;
        end
        for(int i = 0; i <= 1; i = i + 1)begin
            bus2_sram_QA[i] = (!i_f_or_d) ? ((bus2_sram_AA_0[i] == 0) ? dstFrame_lb_sram_even_QA[i+17][11:0] : dstFrame_lb_sram_even_QA[i+19][11:0]) : 0;
            bus2_sram_QB[i] = (!i_f_or_d) ? ((bus2_sram_AB_0[i] == 0) ? dstFrame_lb_sram_even_QB[i+17][11:0] : dstFrame_lb_sram_even_QB[i+19][11:0]) : 0;
        end

    //FIFO for NMS (bus3 - 1*640words/26bits) (even 21-24)
        dstFrame_lb_sram_even_WENA[21] = (!i_f_or_d) ? ((bus3_sram_AA[0] == 0) ? bus3_sram_WENA : 1) : Corr_dstFrame_lb_sram_even_WENA[21];
        dstFrame_lb_sram_even_WENB[21] = (!i_f_or_d) ? ((bus3_sram_AB[0] == 0) ? bus3_sram_WENB : 1) : Corr_dstFrame_lb_sram_even_WENB[21];
        dstFrame_lb_sram_even_DA[21]   = (!i_f_or_d) ? {{11{1'b0}},{bus3_sram_DA[25:13]}}            : Corr_dstFrame_lb_sram_even_DA[21]  ;
        dstFrame_lb_sram_even_DB[21]   = (!i_f_or_d) ? {{11{1'b0}},{bus3_sram_DB[25:13]}}            : Corr_dstFrame_lb_sram_even_DB[21]  ;
        dstFrame_lb_sram_even_AA[21]   = (!i_f_or_d) ? bus3_sram_AA[H_SIZE_BW-1:1]                   : Corr_dstFrame_lb_sram_even_AA[21]  ;
        dstFrame_lb_sram_even_AB[21]   = (!i_f_or_d) ? bus3_sram_AB[H_SIZE_BW-1:1]                   : Corr_dstFrame_lb_sram_even_AB[21]  ;
        dstFrame_lb_sram_even_WENA[22] = (!i_f_or_d) ? ((bus3_sram_AA[0] == 0) ? bus3_sram_WENA : 1) : Corr_dstFrame_lb_sram_even_WENA[22];
        dstFrame_lb_sram_even_WENB[22] = (!i_f_or_d) ? ((bus3_sram_AB[0] == 0) ? bus3_sram_WENB : 1) : Corr_dstFrame_lb_sram_even_WENB[22];
        dstFrame_lb_sram_even_DA[22]   = (!i_f_or_d) ? {{11{1'b0}},{bus3_sram_DA[12:0]}}             : Corr_dstFrame_lb_sram_even_DA[22]  ;
        dstFrame_lb_sram_even_DB[22]   = (!i_f_or_d) ? {{11{1'b0}},{bus3_sram_DB[12:0]}}             : Corr_dstFrame_lb_sram_even_DB[22]  ;
        dstFrame_lb_sram_even_AA[22]   = (!i_f_or_d) ? bus3_sram_AA[H_SIZE_BW-1:1]                   : Corr_dstFrame_lb_sram_even_AA[22]  ;
        dstFrame_lb_sram_even_AB[22]   = (!i_f_or_d) ? bus3_sram_AB[H_SIZE_BW-1:1]                   : Corr_dstFrame_lb_sram_even_AB[22]  ;
        dstFrame_lb_sram_even_WENA[23] = (!i_f_or_d) ? ((bus3_sram_AA[0] == 1) ? bus3_sram_WENA : 1) : Corr_dstFrame_lb_sram_even_WENA[23];
        dstFrame_lb_sram_even_WENB[23] = (!i_f_or_d) ? ((bus3_sram_AB[0] == 1) ? bus3_sram_WENB : 1) : Corr_dstFrame_lb_sram_even_WENB[23];
        dstFrame_lb_sram_even_DA[23]   = (!i_f_or_d) ? {{11{1'b0}},{bus3_sram_DA[25:13]}}            : Corr_dstFrame_lb_sram_even_DA[23]  ;
        dstFrame_lb_sram_even_DB[23]   = (!i_f_or_d) ? {{11{1'b0}},{bus3_sram_DB[25:13]}}            : Corr_dstFrame_lb_sram_even_DB[23]  ;
        dstFrame_lb_sram_even_AA[23]   = (!i_f_or_d) ? bus3_sram_AA[H_SIZE_BW-1:1]                   : Corr_dstFrame_lb_sram_even_AA[23]  ;
        dstFrame_lb_sram_even_AB[23]   = (!i_f_or_d) ? bus3_sram_AB[H_SIZE_BW-1:1]                   : Corr_dstFrame_lb_sram_even_AB[23]  ;
        dstFrame_lb_sram_even_WENA[24] = (!i_f_or_d) ? ((bus3_sram_AA[0] == 1) ? bus3_sram_WENA : 1) : Corr_dstFrame_lb_sram_even_WENA[24];
        dstFrame_lb_sram_even_WENB[24] = (!i_f_or_d) ? ((bus3_sram_AB[0] == 1) ? bus3_sram_WENB : 1) : Corr_dstFrame_lb_sram_even_WENB[24];
        dstFrame_lb_sram_even_DA[24]   = (!i_f_or_d) ? {{11{1'b0}},{bus3_sram_DA[12:0]}}             : Corr_dstFrame_lb_sram_even_DA[24]  ;
        dstFrame_lb_sram_even_DB[24]   = (!i_f_or_d) ? {{11{1'b0}},{bus3_sram_DB[12:0]}}             : Corr_dstFrame_lb_sram_even_DB[24]  ;
        dstFrame_lb_sram_even_AA[24]   = (!i_f_or_d) ? bus3_sram_AA[H_SIZE_BW-1:1]                   : Corr_dstFrame_lb_sram_even_AA[24]  ;
        dstFrame_lb_sram_even_AB[24]   = (!i_f_or_d) ? bus3_sram_AB[H_SIZE_BW-1:1]                   : Corr_dstFrame_lb_sram_even_AB[24]  ;
        bus3_sram_QA = (!i_f_or_d) ? ((bus3_sram_AA_0 == 0) ? {{dstFrame_lb_sram_even_QA[21][12:0]},{dstFrame_lb_sram_even_QA[22][12:0]}} : {{dstFrame_lb_sram_even_QA[23][12:0]},{dstFrame_lb_sram_even_QA[24][12:0]}}) : 0;
        bus3_sram_QB = (!i_f_or_d) ? ((bus3_sram_AB_0 == 0) ? {{dstFrame_lb_sram_even_QB[21][12:0]},{dstFrame_lb_sram_even_QB[22][12:0]}} : {{dstFrame_lb_sram_even_QB[23][12:0]},{dstFrame_lb_sram_even_QB[24][12:0]}}) : 0;

    //line buffer for BRIEF (bus4 - 30*640words/8bits) (odd 0-59)
        for(int i = 0; i <= 29; i = i + 1)begin
            dstFrame_lb_sram_odd_WENA[i] = (!i_f_or_d) ? ((bus4_sram_AA[i][0] == 0) ? bus4_sram_WENA[i] : 1) : Corr_dstFrame_lb_sram_odd_WENA[i];
            dstFrame_lb_sram_odd_WENB[i] = (!i_f_or_d) ? ((bus4_sram_AB[i][0] == 0) ? bus4_sram_WENB[i] : 1) : Corr_dstFrame_lb_sram_odd_WENB[i];
            dstFrame_lb_sram_odd_DA[i]   = (!i_f_or_d) ? {{16{1'b0}},{bus4_sram_DA[i]}}                      : Corr_dstFrame_lb_sram_odd_DA[i]  ;
            dstFrame_lb_sram_odd_DB[i]   = (!i_f_or_d) ? {{16{1'b0}},{bus4_sram_DB[i]}}                      : Corr_dstFrame_lb_sram_odd_DB[i]  ;
            dstFrame_lb_sram_odd_AA[i]   = (!i_f_or_d) ? bus4_sram_AA[i][H_SIZE_BW-1:1]                      : Corr_dstFrame_lb_sram_odd_AA[i]  ;
            dstFrame_lb_sram_odd_AB[i]   = (!i_f_or_d) ? bus4_sram_AB[i][H_SIZE_BW-1:1]                      : Corr_dstFrame_lb_sram_odd_AB[i]  ;
        end
        for(int i = 30; i <= 59; i = i + 1)begin
            dstFrame_lb_sram_odd_WENA[i] = (!i_f_or_d) ? ((bus4_sram_AA[i-30][0] == 1) ? bus4_sram_WENA[i-30] : 1) : Corr_dstFrame_lb_sram_odd_WENA[i];
            dstFrame_lb_sram_odd_WENB[i] = (!i_f_or_d) ? ((bus4_sram_AB[i-30][0] == 1) ? bus4_sram_WENB[i-30] : 1) : Corr_dstFrame_lb_sram_odd_WENB[i];
            dstFrame_lb_sram_odd_DA[i]   = (!i_f_or_d) ? {{16{1'b0}},{bus4_sram_DA[i-30]}}                         : Corr_dstFrame_lb_sram_odd_DA[i]  ;
            dstFrame_lb_sram_odd_DB[i]   = (!i_f_or_d) ? {{16{1'b0}},{bus4_sram_DB[i-30]}}                         : Corr_dstFrame_lb_sram_odd_DB[i]  ;
            dstFrame_lb_sram_odd_AA[i]   = (!i_f_or_d) ? bus4_sram_AA[i-30][H_SIZE_BW-1:1]                         : Corr_dstFrame_lb_sram_odd_AA[i]  ;
            dstFrame_lb_sram_odd_AB[i]   = (!i_f_or_d) ? bus4_sram_AB[i-30][H_SIZE_BW-1:1]                         : Corr_dstFrame_lb_sram_odd_AB[i]  ;
        end
        for(int i = 0; i <= 29; i = i + 1)begin
            bus4_sram_QA[i] = (!i_f_or_d) ? ((bus4_sram_AA_0[i] == 0) ? dstFrame_lb_sram_odd_QA[i][7:0] : dstFrame_lb_sram_odd_QA[i+30][7:0]) : 0;
            bus4_sram_QB[i] = (!i_f_or_d) ? ((bus4_sram_AB_0[i] == 0) ? dstFrame_lb_sram_odd_QB[i][7:0] : dstFrame_lb_sram_odd_QB[i+30][7:0]) : 0;
        end

    //desc in MATCH 1 (bus5 - 8*512words/32bits) (even 25-40)
        for(int i = 25; i <= 32; i = i + 1)begin
            dstFrame_lb_sram_even_WENA[i] = (!i_f_or_d) ? ((bus5_sram_AA[i-25][0] == 0) ? bus5_sram_WENA[i-25] : 1) : Corr_dstFrame_lb_sram_even_WENA[i];
            dstFrame_lb_sram_even_WENB[i] = (!i_f_or_d) ? 1                                                         : Corr_dstFrame_lb_sram_even_WENB[i];
            dstFrame_lb_sram_even_DA[i]   = (!i_f_or_d) ? bus5_sram_DA[i-25][23:0]                                  : Corr_dstFrame_lb_sram_even_DA[i]  ;
            dstFrame_lb_sram_even_DB[i]   = (!i_f_or_d) ? 0                                                         : Corr_dstFrame_lb_sram_even_DB[i]  ;
            dstFrame_lb_sram_even_AA[i]   = (!i_f_or_d) ? {{1'b0},{bus5_sram_AA[i-25][8:1]}}                        : Corr_dstFrame_lb_sram_even_AA[i]  ;
            dstFrame_lb_sram_even_AB[i]   = (!i_f_or_d) ? {{1'b0},{bus5_sram_AA[i-25][8:1]}} + 20                   : Corr_dstFrame_lb_sram_even_AB[i]  ;
        end
        for(int i = 33; i <= 40; i = i + 1)begin
            dstFrame_lb_sram_even_WENA[i] = (!i_f_or_d) ? ((bus5_sram_AA[i-33][0] == 1) ? bus5_sram_WENA[i-33] : 1) : Corr_dstFrame_lb_sram_even_WENA[i];
            dstFrame_lb_sram_even_WENB[i] = (!i_f_or_d) ? 1                                                         : Corr_dstFrame_lb_sram_even_WENB[i];
            dstFrame_lb_sram_even_DA[i]   = (!i_f_or_d) ? bus5_sram_DA[i-33][23:0]                                  : Corr_dstFrame_lb_sram_even_DA[i]  ;
            dstFrame_lb_sram_even_DB[i]   = (!i_f_or_d) ? 0                                                         : Corr_dstFrame_lb_sram_even_DB[i]  ;
            dstFrame_lb_sram_even_AA[i]   = (!i_f_or_d) ? {{1'b0},{bus5_sram_AA[i-33][8:1]}}                        : Corr_dstFrame_lb_sram_even_AA[i]  ;
            dstFrame_lb_sram_even_AB[i]   = (!i_f_or_d) ? {{1'b0},{bus5_sram_AA[i-33][8:1]}} + 20                   : Corr_dstFrame_lb_sram_even_AB[i]  ;
        end
        for(int i = 0; i <= 7; i = i + 1)begin
            bus5_sram_QA[i] = (!i_f_or_d) ? ((bus5_sram_AA_0[i] == 0) ? {{bus5_sram_QA_8[i]},{dstFrame_lb_sram_even_QA[i+25]}} : {{bus5_sram_QA_8[i]},{dstFrame_lb_sram_even_QA[i+33]}}) : 0;
        end

    //desc in MATCH 2 (bus6 - 8*512words/32bits) (even 41-56)
        for(int i = 41; i <= 48; i = i + 1)begin
            dstFrame_lb_sram_even_WENA[i] = (!i_f_or_d) ? ((bus6_sram_AA[i-41][0] == 0) ? bus6_sram_WENA[i-41] : 1) : Corr_dstFrame_lb_sram_even_WENA[i];
            dstFrame_lb_sram_even_WENB[i] = (!i_f_or_d) ? 1                                                         : Corr_dstFrame_lb_sram_even_WENB[i];
            dstFrame_lb_sram_even_DA[i]   = (!i_f_or_d) ? bus6_sram_DA[i-41][23:0]                                  : Corr_dstFrame_lb_sram_even_DA[i]  ;
            dstFrame_lb_sram_even_DB[i]   = (!i_f_or_d) ? 0                                                         : Corr_dstFrame_lb_sram_even_DB[i]  ;
            dstFrame_lb_sram_even_AA[i]   = (!i_f_or_d) ? {{1'b0},{bus6_sram_AA[i-41][8:1]}}                        : Corr_dstFrame_lb_sram_even_AA[i]  ;
            dstFrame_lb_sram_even_AB[i]   = (!i_f_or_d) ? {{1'b0},{bus6_sram_AA[i-41][8:1]}} + 20                   : Corr_dstFrame_lb_sram_even_AB[i]  ;
        end
        for(int i = 49; i <= 56; i = i + 1)begin
            dstFrame_lb_sram_even_WENA[i] = (!i_f_or_d) ? ((bus6_sram_AA[i-49][0] == 1) ? bus6_sram_WENA[i-49] : 1) : Corr_dstFrame_lb_sram_even_WENA[i];
            dstFrame_lb_sram_even_WENB[i] = (!i_f_or_d) ? 1                                                         : Corr_dstFrame_lb_sram_even_WENB[i];
            dstFrame_lb_sram_even_DA[i]   = (!i_f_or_d) ? bus6_sram_DA[i-49][23:0]                                  : Corr_dstFrame_lb_sram_even_DA[i]  ;
            dstFrame_lb_sram_even_DB[i]   = (!i_f_or_d) ? 0                                                         : Corr_dstFrame_lb_sram_even_DB[i]  ;
            dstFrame_lb_sram_even_AA[i]   = (!i_f_or_d) ? {{1'b0},{bus6_sram_AA[i-49][8:1]}}                        : Corr_dstFrame_lb_sram_even_AA[i]  ;
            dstFrame_lb_sram_even_AB[i]   = (!i_f_or_d) ? {{1'b0},{bus6_sram_AA[i-49][8:1]}} + 20                   : Corr_dstFrame_lb_sram_even_AB[i]  ;
        end
        for(int i = 0; i <= 7; i = i + 1)begin
            bus6_sram_QA[i] = (!i_f_or_d) ? ((bus6_sram_AA_0[i] == 0) ? {{bus6_sram_QA_8[i]},{dstFrame_lb_sram_even_QA[i+41]}} : {{bus6_sram_QA_8[i]},{dstFrame_lb_sram_even_QA[i+49]}}) : 0;
        end

    //point in MATCH 1 (bus7 - 1*512words/20bits) (even 57-58)
        dstFrame_lb_sram_even_WENA[57] = (!i_f_or_d) ? ((bus7_sram_AA[0] == 0) ? bus7_sram_WENA : 1) : Corr_dstFrame_lb_sram_even_WENA[57];
        dstFrame_lb_sram_even_WENB[57] = (!i_f_or_d) ? 1                                             : Corr_dstFrame_lb_sram_even_WENB[57];
        dstFrame_lb_sram_even_DA[57]   = (!i_f_or_d) ? {{4{1'b0}},{bus7_sram_DA}}                    : Corr_dstFrame_lb_sram_even_DA[57]  ;
        dstFrame_lb_sram_even_DB[57]   = (!i_f_or_d) ? 0                                             : Corr_dstFrame_lb_sram_even_DB[57]  ;
        dstFrame_lb_sram_even_AA[57]   = (!i_f_or_d) ? {{1'b0},{bus7_sram_AA[8:1]}}                  : Corr_dstFrame_lb_sram_even_AA[57]  ;
        dstFrame_lb_sram_even_AB[57]   = (!i_f_or_d) ? {{1'b0},{bus7_sram_AA[8:1]}} + 20             : Corr_dstFrame_lb_sram_even_AB[57]  ;
        dstFrame_lb_sram_even_WENA[58] = (!i_f_or_d) ? ((bus7_sram_AA[0] == 1) ? bus7_sram_WENA : 1) : Corr_dstFrame_lb_sram_even_WENA[58];
        dstFrame_lb_sram_even_WENB[58] = (!i_f_or_d) ? 1                                             : Corr_dstFrame_lb_sram_even_WENB[58];
        dstFrame_lb_sram_even_DA[58]   = (!i_f_or_d) ? {{4{1'b0}},{bus7_sram_DA}}                    : Corr_dstFrame_lb_sram_even_DA[58]  ;
        dstFrame_lb_sram_even_DB[58]   = (!i_f_or_d) ? 0                                             : Corr_dstFrame_lb_sram_even_DB[58]  ;
        dstFrame_lb_sram_even_AA[58]   = (!i_f_or_d) ? {{1'b0},{bus7_sram_AA[8:1]}}                  : Corr_dstFrame_lb_sram_even_AA[58]  ;
        dstFrame_lb_sram_even_AB[58]   = (!i_f_or_d) ? {{1'b0},{bus7_sram_AA[8:1]}} + 20             : Corr_dstFrame_lb_sram_even_AB[58]  ;
        bus7_sram_QA = (!i_f_or_d) ? ((bus7_sram_AA_0 == 0) ? dstFrame_lb_sram_even_QA[57][19:0] : dstFrame_lb_sram_even_QA[58][19:0]) : 0;

    //point in MATCH 2 (bus8 - 1*512words/20bits) (even 59-60)
        dstFrame_lb_sram_even_WENA[59] = (!i_f_or_d) ? ((bus8_sram_AA[0] == 0) ? bus8_sram_WENA : 1) : Corr_dstFrame_lb_sram_even_WENA[59];
        dstFrame_lb_sram_even_WENB[59] = (!i_f_or_d) ? 1                                             : Corr_dstFrame_lb_sram_even_WENB[59];
        dstFrame_lb_sram_even_DA[59]   = (!i_f_or_d) ? {{4{1'b0}},{bus8_sram_DA}}                    : Corr_dstFrame_lb_sram_even_DA[59]  ;
        dstFrame_lb_sram_even_DB[59]   = (!i_f_or_d) ? 0                                             : Corr_dstFrame_lb_sram_even_DB[59]  ;
        dstFrame_lb_sram_even_AA[59]   = (!i_f_or_d) ? {{1'b0},{bus8_sram_AA[8:1]}}                  : Corr_dstFrame_lb_sram_even_AA[59]  ;
        dstFrame_lb_sram_even_AB[59]   = (!i_f_or_d) ? {{1'b0},{bus8_sram_AA[8:1]}} + 20             : Corr_dstFrame_lb_sram_even_AB[59]  ;
        dstFrame_lb_sram_even_WENA[60] = (!i_f_or_d) ? ((bus8_sram_AA[0] == 1) ? bus8_sram_WENA : 1) : Corr_dstFrame_lb_sram_even_WENA[60];
        dstFrame_lb_sram_even_WENB[60] = (!i_f_or_d) ? 1                                             : Corr_dstFrame_lb_sram_even_WENB[60];
        dstFrame_lb_sram_even_DA[60]   = (!i_f_or_d) ? {{4{1'b0}},{bus8_sram_DA}}                    : Corr_dstFrame_lb_sram_even_DA[60]  ;
        dstFrame_lb_sram_even_DB[60]   = (!i_f_or_d) ? 0                                             : Corr_dstFrame_lb_sram_even_DB[60]  ;
        dstFrame_lb_sram_even_AA[60]   = (!i_f_or_d) ? {{1'b0},{bus8_sram_AA[8:1]}}                  : Corr_dstFrame_lb_sram_even_AA[60]  ;
        dstFrame_lb_sram_even_AB[60]   = (!i_f_or_d) ? {{1'b0},{bus8_sram_AA[8:1]}} + 20             : Corr_dstFrame_lb_sram_even_AB[60]  ;
        bus8_sram_QA = (!i_f_or_d) ? ((bus8_sram_AA_0 == 0) ? dstFrame_lb_sram_even_QA[59][19:0] : dstFrame_lb_sram_even_QA[60][19:0]) : 0;

    //depth in MATCH 1 (bus9 - 1*512words/16bits) (even 61-62)
        dstFrame_lb_sram_even_WENA[61] = (!i_f_or_d) ? ((bus9_sram_AA[0] == 0) ? bus9_sram_WENA : 1) : Corr_dstFrame_lb_sram_even_WENA[61];
        dstFrame_lb_sram_even_WENB[61] = (!i_f_or_d) ? 1                                             : Corr_dstFrame_lb_sram_even_WENB[61];
        dstFrame_lb_sram_even_DA[61]   = (!i_f_or_d) ? {{8{1'b0}},{bus9_sram_DA}}                    : Corr_dstFrame_lb_sram_even_DA[61]  ;
        dstFrame_lb_sram_even_DB[61]   = (!i_f_or_d) ? 0                                             : Corr_dstFrame_lb_sram_even_DB[61]  ;
        dstFrame_lb_sram_even_AA[61]   = (!i_f_or_d) ? {{1'b0},{bus9_sram_AA[8:1]}}                  : Corr_dstFrame_lb_sram_even_AA[61]  ;
        dstFrame_lb_sram_even_AB[61]   = (!i_f_or_d) ? {{1'b0},{bus9_sram_AA[8:1]}} + 20             : Corr_dstFrame_lb_sram_even_AB[61]  ;
        dstFrame_lb_sram_even_WENA[62] = (!i_f_or_d) ? ((bus9_sram_AA[0] == 1) ? bus9_sram_WENA : 1) : Corr_dstFrame_lb_sram_even_WENA[62];
        dstFrame_lb_sram_even_WENB[62] = (!i_f_or_d) ? 1                                             : Corr_dstFrame_lb_sram_even_WENB[62];
        dstFrame_lb_sram_even_DA[62]   = (!i_f_or_d) ? {{8{1'b0}},{bus9_sram_DA}}                    : Corr_dstFrame_lb_sram_even_DA[62]  ;
        dstFrame_lb_sram_even_DB[62]   = (!i_f_or_d) ? 0                                             : Corr_dstFrame_lb_sram_even_DB[62]  ;
        dstFrame_lb_sram_even_AA[62]   = (!i_f_or_d) ? {{1'b0},{bus9_sram_AA[8:1]}}                  : Corr_dstFrame_lb_sram_even_AA[62]  ;
        dstFrame_lb_sram_even_AB[62]   = (!i_f_or_d) ? {{1'b0},{bus9_sram_AA[8:1]}} + 20             : Corr_dstFrame_lb_sram_even_AB[62]  ;
        bus9_sram_QA = (!i_f_or_d) ? ((bus9_sram_AA_0 == 0) ? dstFrame_lb_sram_even_QA[61][15:0] : dstFrame_lb_sram_even_QA[62][15:0]) : 0;

    //depth in MATCH 2 (bus10 - 1*512words/16bits) (odd 60-61)
        dstFrame_lb_sram_odd_WENA[60] = (!i_f_or_d) ? ((bus10_sram_AA[0] == 0) ? bus10_sram_WENA : 1) : Corr_dstFrame_lb_sram_odd_WENA[60];
        dstFrame_lb_sram_odd_WENB[60] = (!i_f_or_d) ? 1                                               : Corr_dstFrame_lb_sram_odd_WENB[60];
        dstFrame_lb_sram_odd_DA[60]   = (!i_f_or_d) ? {{8{1'b0}},{bus10_sram_DA}}                     : Corr_dstFrame_lb_sram_odd_DA[60]  ;
        dstFrame_lb_sram_odd_DB[60]   = (!i_f_or_d) ? 0                                               : Corr_dstFrame_lb_sram_odd_DB[60]  ;
        dstFrame_lb_sram_odd_AA[60]   = (!i_f_or_d) ? {{1'b0},{bus10_sram_AA[8:1]}}                   : Corr_dstFrame_lb_sram_odd_AA[60]  ;
        dstFrame_lb_sram_odd_AB[60]   = (!i_f_or_d) ? {{1'b0},{bus10_sram_AA[8:1]}} + 20              : Corr_dstFrame_lb_sram_odd_AB[60]  ;
        dstFrame_lb_sram_odd_WENA[61] = (!i_f_or_d) ? ((bus10_sram_AA[0] == 1) ? bus10_sram_WENA : 1) : Corr_dstFrame_lb_sram_odd_WENA[61];
        dstFrame_lb_sram_odd_WENB[61] = (!i_f_or_d) ? 1                                               : Corr_dstFrame_lb_sram_odd_WENB[61];
        dstFrame_lb_sram_odd_DA[61]   = (!i_f_or_d) ? {{8{1'b0}},{bus10_sram_DA}}                     : Corr_dstFrame_lb_sram_odd_DA[61]  ;
        dstFrame_lb_sram_odd_DB[61]   = (!i_f_or_d) ? 0                                               : Corr_dstFrame_lb_sram_odd_DB[61]  ;
        dstFrame_lb_sram_odd_AA[61]   = (!i_f_or_d) ? {{1'b0},{bus10_sram_AA[8:1]}}                   : Corr_dstFrame_lb_sram_odd_AA[61]  ;
        dstFrame_lb_sram_odd_AB[61]   = (!i_f_or_d) ? {{1'b0},{bus10_sram_AA[8:1]}} + 20              : Corr_dstFrame_lb_sram_odd_AB[61]  ;
        bus10_sram_QA = (!i_f_or_d) ? ((bus10_sram_AA_0 == 0) ? dstFrame_lb_sram_odd_QA[60][15:0] : dstFrame_lb_sram_odd_QA[61][15:0]) : 0;
    
    // (odd 62)
        dstFrame_lb_sram_odd_WENA[62] = (!i_f_or_d) ? 1  : Corr_dstFrame_lb_sram_odd_WENA[62];
        dstFrame_lb_sram_odd_WENB[62] = (!i_f_or_d) ? 1  : Corr_dstFrame_lb_sram_odd_WENB[62];
        dstFrame_lb_sram_odd_DA[62]   = (!i_f_or_d) ? 0  : Corr_dstFrame_lb_sram_odd_DA[62]  ;
        dstFrame_lb_sram_odd_DB[62]   = (!i_f_or_d) ? 0  : Corr_dstFrame_lb_sram_odd_DB[62]  ;
        dstFrame_lb_sram_odd_AA[62]   = (!i_f_or_d) ? 0  : Corr_dstFrame_lb_sram_odd_AA[62]  ;
        dstFrame_lb_sram_odd_AB[62]   = (!i_f_or_d) ? 20 : Corr_dstFrame_lb_sram_odd_AB[62]  ;
    end

    generate
        for(genvar s = 0; s < 6; s = s+1) begin
            DataDelay
            #(
                .DATA_BW(1)
               ,.STAGE(1)
            ) u_bus1_sram_AA_0 (
                // input
                 .i_clk(i_clk)
                ,.i_rst_n(i_rst_n)
                ,.i_data(bus1_sram_AA[s][0])
                // Output
                ,.o_data(bus1_sram_AA_0[s])
            );
            DataDelay
            #(
                .DATA_BW(1)
               ,.STAGE(1)
            ) u_bus1_sram_AB_0 (
                // input
                 .i_clk(i_clk)
                ,.i_rst_n(i_rst_n)
                ,.i_data(bus1_sram_AB[s][0])
                // Output
                ,.o_data(bus1_sram_AB_0[s])
            );
        end
    endgenerate
    generate
        for(genvar s = 0; s < 2; s = s+1) begin
            DataDelay
            #(
                .DATA_BW(1)
               ,.STAGE(1)
            ) u_bus2_sram_AA_0 (
                // input
                 .i_clk(i_clk)
                ,.i_rst_n(i_rst_n)
                ,.i_data(bus2_sram_AA[s][0])
                // Output
                ,.o_data(bus2_sram_AA_0[s])
            );
            DataDelay
            #(
                .DATA_BW(1)
               ,.STAGE(1)
            ) u_bus2_sram_AB_0 (
                // input
                 .i_clk(i_clk)
                ,.i_rst_n(i_rst_n)
                ,.i_data(bus2_sram_AB[s][0])
                // Output
                ,.o_data(bus2_sram_AB_0[s])
            );
        end
    endgenerate
    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(1)
    ) u_bus3_sram_AA_0 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(bus3_sram_AA[0])
        // Output
        ,.o_data(bus3_sram_AA_0)
    );
    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(1)
    ) u_bus3_sram_AB_0 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(bus3_sram_AB[0])
        // Output
        ,.o_data(bus3_sram_AB_0)
    );
    generate
        for(genvar s = 0; s < 30; s = s+1) begin
            DataDelay
            #(
                .DATA_BW(1)
               ,.STAGE(1)
            ) u_bus4_sram_AA_0 (
                // input
                 .i_clk(i_clk)
                ,.i_rst_n(i_rst_n)
                ,.i_data(bus4_sram_AA[s][0])
                // Output
                ,.o_data(bus4_sram_AA_0[s])
            );
            DataDelay
            #(
                .DATA_BW(1)
               ,.STAGE(1)
            ) u_bus4_sram_AB_0 (
                // input
                 .i_clk(i_clk)
                ,.i_rst_n(i_rst_n)
                ,.i_data(bus4_sram_AB[s][0])
                // Output
                ,.o_data(bus4_sram_AB_0[s])
            );
        end
    endgenerate
    generate
        for(genvar s = 0; s < 8; s = s+1) begin
            DataDelay
            #(
                .DATA_BW(1)
               ,.STAGE(1)
            ) u_bus5_sram_AA_0 (
                // input
                 .i_clk(i_clk)
                ,.i_rst_n(i_rst_n)
                ,.i_data(bus5_sram_AA[s][0])
                // Output
                ,.o_data(bus5_sram_AA_0[s])
            );
        end
    endgenerate
    generate
        for(genvar s = 0; s < 8; s = s+1) begin
            DataDelay
            #(
                .DATA_BW(1)
               ,.STAGE(1)
            ) u_bus6_sram_AA_0 (
                // input
                 .i_clk(i_clk)
                ,.i_rst_n(i_rst_n)
                ,.i_data(bus6_sram_AA[s][0])
                // Output
                ,.o_data(bus6_sram_AA_0[s])
            );
        end
    endgenerate
    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(1)
    ) u_bus7_sram_AA_0 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(bus7_sram_AA[0])
        // Output
        ,.o_data(bus7_sram_AA_0)
    );
    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(1)
    ) u_bus8_sram_AA_0 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(bus8_sram_AA[0])
        // Output
        ,.o_data(bus8_sram_AA_0)
    );
    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(1)
    ) u_bus9_sram_AA_0 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(bus9_sram_AA[0])
        // Output
        ,.o_data(bus9_sram_AA_0)
    );
    DataDelay
    #(
        .DATA_BW(1)
       ,.STAGE(1)
    ) u_bus10_sram_AA_0 (
        // input
         .i_clk(i_clk)
        ,.i_rst_n(i_rst_n)
        ,.i_data(bus10_sram_AA[0])
        // Output
        ,.o_data(bus10_sram_AA_0)
    );

    always_comb begin
        srcFrame_lb_sram_WENA = (!i_f_or_d) ? 1  : Corr_srcFrame_lb_sram_WENA;
        srcFrame_lb_sram_WENB = (!i_f_or_d) ? 1  : Corr_srcFrame_lb_sram_WENB;
        srcFrame_lb_sram_DA   = (!i_f_or_d) ? 0  : Corr_srcFrame_lb_sram_DA;
        srcFrame_lb_sram_DB   = (!i_f_or_d) ? 0  : Corr_srcFrame_lb_sram_DB;
        srcFrame_lb_sram_AA   = (!i_f_or_d) ? 0  : Corr_srcFrame_lb_sram_AA;
        srcFrame_lb_sram_AB   = (!i_f_or_d) ? 20 : Corr_srcFrame_lb_sram_AB;
    end

    generate
        for(genvar s = 0; s < 8; s = s+1) begin
            sram_dp_desc_8 uut5 (
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
                .DA(bus5_sram_DA[s][31:24]),
                .DB(8'd0),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b1),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(bus5_sram_WENA[s]),
                .WENB(1'b1),

                // data output bus
                .QA(bus5_sram_QA_8[s]),
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
                .TDA(8'd0),
                .TQA(8'd0),
                .TCENB(1'b1),
                .TWENB(1'b1),
                .TAB(9'd0),
                .TDB(8'd0),
                .TQB(8'd0),
                .RET1N(1'b1)
            );
        end
    endgenerate

    generate
        for(genvar s = 0; s < 8; s = s+1) begin
            sram_dp_desc_8 uut6 (
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
                .DA(bus6_sram_DA[s][31:24]),
                .DB(8'd0),

                // chip enable (active low, 0 for ON and 1 for OFF)
                // .CENA(1'b1),
                // .CENB(1'b1),
                .CENA(1'b0),
                .CENB(1'b1),

                // write enable (active low, 0 for WRITE and 1 for READ)
                .WENA(bus6_sram_WENA[s]),
                .WENB(1'b1),

                // data output bus
                .QA(bus6_sram_QA_8[s]),
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
                .TDA(8'd0),
                .TQA(8'd0),
                .TCENB(1'b1),
                .TWENB(1'b1),
                .TAB(9'd0),
                .TDB(8'd0),
                .TQB(8'd0),
                .RET1N(1'b1)
            );
        end
    endgenerate

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