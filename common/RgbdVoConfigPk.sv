// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//
// Contributors
// ---------------------------
// Li-Yang Huang <lyhuang@media.ee.ntu.edu.tw>, 2022

`ifndef __RGBDVOCONFIGDEFINES_SV__
`define __RGBDVOCONFIGDEFINES_SV__

// Configuration ==============================================================

package RgbdVoConfigPk;

    parameter SHIFT_BIT_NUM = 24;
    parameter MUL = SHIFT_BIT_NUM;

    parameter DATA_RGB_BW = 8;
    parameter DATA_DEPTH_BW = 16;
    //parameter CLOUD_BW = 10+SHIFT_BIT_NUM+DATA_DEPTH_BW; //FX_BW+DATA_DEPTH_BW
    parameter CLOUD_BW = 42;
    parameter POSE_BW = CLOUD_BW; //TBD

    parameter MAX_SRC_WID = 640;
    parameter MAX_SRC_HGT = 480;
    parameter SRC_WID_BW = $clog2(MAX_SRC_WID + 1);
    parameter SRC_HGT_BW = $clog2(MAX_SRC_HGT + 1);

    parameter MIN_DEPTH = 0;
    parameter MAX_DEPTH = 20000;
    parameter MAX_DIFF_DEPTH = 350;
    parameter MAX_DIFF_LINE = 10'd30;

    parameter LB_NUMBER = MAX_DIFF_LINE + MAX_DIFF_LINE + 3;
    parameter LB_STORE_INDEX_BW = $clog2(LB_NUMBER + 1);
    parameter LB_LOAD_INDEX_BW = LB_STORE_INDEX_BW + 2;

    //=================================
    // Register Memory Map Define
    //=================================
    typedef enum logic [31:0] {
         DISABLE                  //R/W
        ,H_SIZE                   //R/W
        ,V_SIZE                   //R/W
        ,FX                       //R/W
        ,FY                       //R/W
        ,CX                       //R/W
        ,CY                       //R/W
        ,DEPTH_MAX                //R/W
        ,DEPTH_MIN                //R/W
        ,RESERVED                 //R/W 
    } RegAddr;

    //=================================
    // Register Bitwidth Define
    //=================================
    
    //parameter H_SIZE_BW           = SRC_WID_BW;
    //parameter V_SIZE_BW           = SRC_HGT_BW;
    parameter H_SIZE_BW           = 10;
    parameter V_SIZE_BW           = 10;
    parameter FX_BW               = 10+SHIFT_BIT_NUM+1; //+1 for sign
    parameter FY_BW               = FX_BW;
    parameter CX_BW               = FX_BW;
    parameter CY_BW               = FX_BW;
    parameter DEPTH_MAX_BW        = DATA_DEPTH_BW;
    parameter DEPTH_MIN_BW        = DATA_DEPTH_BW;
    parameter ID_COE_BW           = 42;
    parameter MATRIX_BW           = 64;

   //=================================
   // Register Default Define
   //=================================


endpackage


`endif // __RGBDVOCONFIGDEFINES_SV__
