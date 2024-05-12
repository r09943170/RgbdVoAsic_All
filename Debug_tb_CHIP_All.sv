`timescale 1ns/10ps
`define CYCLE    10           	         // Modify your clock period here
// `define TIME_OUT 640*1500*10       
`define TIME_OUT 640*3100*10     

// `ifdef RTL
    `include "common/RgbdVoConfigPk.sv"
    `include "CHIP_All.sv"
    `include "CHIP_fea.sv"
    `include "SRAM_all.sv"
    `include "FAST.sv"      //CHIP_fea.sv
    `include "BRIEF_Top.sv" //CHIP_fea.sv
    `include "MATCH_Top.sv" //CHIP_fea.sv
    `include "SMOOTH.sv"        //FAST.sv
    `include "FAST_9.sv"        //FAST.sv
    `include "NMS.sv"           //FAST.sv
    `include "Orientation.sv"   //FAST.sv
    // `include "DW_sqrt.v"         //Orientation.sv
    // `include "DW_div.v"          //Orientation.sv
    `include "Key_Buffer1.sv"   //BRIEF_Top.sv
    `include "BRIEF.sv"         //BRIEF_Top.sv
    `include "LUT.sv"               //BRIEF.sv
    `include "Key_Buffer2.sv"   //MATCH_Top.sv
    `include "MATCH.sv"         //MATCH_Top.sv
    `include "MATCH_mem.sv"     //MATCH_Top.sv
    `include "HAMMING.sv"           //MATCH.sv
    `include "sram_v3/sram_lb_FAST.v"
    `include "sram_v3/sram_FIFO_NMS.v"
    `include "sram_v3/sram_dp_sincos.v"
    `include "sram_v3/sram_BRIEF_lb.v"
    `include "sram_v3/sram_dp_desc.v"
    `include "sram_v3/sram_dp_point.v"
    `include "sram_v3/sram_dp_depth.v"
    `include "sram_v3/sram_dp_dstFrame.v"
    `include "./DW02_mult_2_stage.v"
    `include "./DW_div.v"
    `include "./DW_div_pipe.v"
    `include "./DW02_mult.v"
    `include "./DW_mult_pipe.v"
    `include "./DW_sqrt.v"
    `include "./DW_sqrt_pipe.v" //Rodrigues.sv"
    `include "./DW_sincos.v"    //Rodrigues.sv"
    `include "./Idx2Cloud.sv"
    `include "./TransMat.sv"
    `include "./Proj.sv"
    `include "./DataDelay.sv"
    `include "./IndirectCoe.sv"
    `include "./IndirectCalc.sv"
    `include "./MulAcc.sv"
    `include "./Matrix.sv"
    `include "./LDLT.sv"
    `include "./Solver.sv"
    `include "./Rodrigues.sv"
    `include "./UpdatePose.sv"
    `include "./ComputeCorresps.sv"
    `include "./normalComputer.sv"
    `include "./normalUnitization.sv"
    `include "./OuterProduct.sv"
    `include "./CalcICPLsmMatrices.sv"
    `include "./CalcRgbdLsmMatrices.sv"
    `include "./sigma_icp_generator.sv"
    `include "./sigma_rgbd_generator.sv"
    `include "./AtA_AtB_of_Direct.sv"
    `include "./gradient.sv"
// `endif

// simulation
// RTL: ncverilog Debug_tb_CHIP_All.sv +incdir+/opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver/ -y /opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver +libext+.v+notimingchecks +define+RTL +access+r 

module Debug_tb_CHIP_All;
    import RgbdVoConfigPk::*;
    
    integer i, j, k, index, time_cnt, display_cnt, display_en;
    integer f_poes;

    // genvar s;
    logic clk, rst_n;

    logic [6:0]  time_per;

    logic [7:0]  pixel_in [0:307199];
    logic [7:0]  pixel_in2 [0:307199];
    logic [7:0]  pixel_in3 [0:307199];
    logic [15:0] depth_in [0:307199];
    logic [15:0] depth_in2 [0:307199];
    logic [15:0] depth_in3 [0:307199];

    logic [3:0]  cnt_of_f_start;
    logic [3:0]  cnt_of_f;
    logic [3:0]  n_of_d;
    logic [3:0]  cnt_of_d;
    logic        valid_0_en;

    logic        start;
    logic        valid_0;
    logic [7:0]  pixel_0;
    logic [15:0] depth_0;
    logic        valid_1;
    logic [7:0]  pixel_1;
    logic [15:0] depth_1;

    logic        f_or_d;
    logic [3:0]  n_of_f;

    logic [41:0] initial_pose [12];
    logic [34:0] r_fx;
    logic [34:0] r_fy;
    logic [34:0] r_cx;
    logic [34:0] r_cy;
    logic [9:0]  hsize;
    logic [9:0]  vsize;
    logic [83:0] sigma_icp;
    logic [8:0]  sigma_rgbd;

    logic                   o_ready;
    logic [2*CLOUD_BW-1:0]  sigma_icp_next;
    logic [DATA_RGB_BW:0]   sigma_rgbd_next;
    logic                   done;
    logic [POSE_BW-1:0]     new_pose [12];
    logic                   update_done;

    initial begin
        f_poes = $fopen("./result/pose.txt","w");

        clk         = 1'b1;
        rst_n       = 1'b1;  
        i           = 0;
        j           = 0;
        k           = 0;
        index       = 0;
        display_en  = 19840;
        n_of_f      = 4'd4;
        n_of_d      = 4'd3;
        $readmemh ("./testfile/pixel_in.txt", pixel_in);
        $readmemh ("./testfile/pixel_in2.txt", pixel_in2);
        $readmemh ("./testfile/pixel_in3.txt", pixel_in3);
        $readmemh ("./testfile/depth_in1.txt", depth_in);
        $readmemh ("./testfile/depth_in2.txt", depth_in2);
        $readmemh ("./testfile/depth_in3.txt", depth_in3);
        $display ("initialize sucessfully");
        $display("finish 0 cycles, 0 percentage");
        #5 rst_n=1'b0;         
        #5 rst_n=1'b1;
    end

    always begin #(`CYCLE/2) clk = ~clk; end

    initial #(`TIME_OUT) begin
        $display("Time_out! AAAAAA");
        $display("⠄⠄⠄⠄⠄⠄⠄⠈⠉⠁⠈⠉⠉⠙⠿⣿⣿⣿⣿⣿");
        $display("⠄⠄⠄⠄⠄⠄⠄⠄⣀⣀⣀⠄⠄⠄⠄⠄⠹⣿⣿⣿");
        $display("⠄⠄⠄⠄⠄⢐⣲⣿⣿⣯⠭⠉⠙⠲⣄⡀⠄⠈⢿⣿");
        $display("⠐⠄⠄⠰⠒⠚⢩⣉⠼⡟⠙⠛⠿⡟⣤⡳⡀⠄⠄⢻");
        $display("⠄⠄⢀⣀⣀⣢⣶⣿⣦⣭⣤⣭⣵⣶⣿⣿⣏⠄⠄⣿");
        $display("⠄⣼⣿⣿⣿⡉⣿⣀⣽⣸⣿⣿⣿⣿⣿⣿⣿⡆⣀⣿");
        $display("⢠⣿⣿⣿⠿⠟⠛⠻⢿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣼");
        $display("⠄⣿⣿⣿⡆⠄⠄⠄⠄⠳⡈⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⠄⢹⣿⣿⡇⠄⠄⠄⠄⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⠄⠄⢿⣿⣷⣨⣽⣭⢁⣡⣿⣿⠟⣩⣿⣿⣿⠿⠿⠟");
        $display("⠄⠄⠈⡍⠻⣿⣿⣿⣿⠟⠋⢁⣼⠿⠋⠉⠄⠄⠄⠄");
        $display("⠄⠄⠄⠈⠴⢬⣙⣛⡥⠴⠂⠄⠄⠄⠄⠄⠄⠄⠄.");
        $finish;
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) time_cnt <= 0;
        else time_cnt <= time_cnt + 1;
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) display_cnt <= 0;
        else if (display_cnt == display_en) display_cnt <= 1;
        else display_cnt <= display_cnt + 1;
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) time_per <= 0;
        else if (display_cnt == (display_en-1)) time_per <= time_per + 1;
        else time_per <= time_per;
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            cnt_of_f_start <= 0;
        end
        else if(!f_or_d && start) begin
            cnt_of_f_start <= cnt_of_f_start + 1;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            cnt_of_f <= 0;
        end
        else if(!f_or_d && update_done) begin
            cnt_of_f <= cnt_of_f + 1;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            cnt_of_d <= 0;
        end
        else if(f_or_d && done && (cnt_of_d <= (n_of_d-1))) begin
            cnt_of_d <= cnt_of_d + 1;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            valid_0_en <= 0;
        end
        else if(done) begin
            valid_0_en <= 0;
        end
        else if(j == 19839) begin
            valid_0_en <= 1;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            start <= 0;
            i <= 0;
            j <= 0;
            k <= 0;
            valid_0 <= 0;
            pixel_0 <= 0;
            depth_0 <= 0;
            valid_1 <= 0;
            pixel_1 <= 0;
            depth_1 <= 0;
        end
        else if(!f_or_d) begin
            if(index == 3) begin
                i <= 0;
                pixel_0 <= 0;
                depth_0 <= 0;
                valid_0 <= 0;
            end
            else if(i < 307200) begin
                if(i == 0) start <= 1;
                else start <= 0;
                case(index)
                    0: pixel_0 <= pixel_in[i];
                    1: pixel_0 <= pixel_in2[i];
                    2: pixel_0 <= pixel_in3[i];
                    default: pixel_0 <= 0;
                endcase
                case(index)
                    0: depth_0 <= depth_in[i];
                    1: depth_0 <= depth_in2[i];
                    2: depth_0 <= depth_in3[i];
                    default: depth_0 <= 0;
                endcase
                case(index)
                    0: valid_0 <= 1;
                    1: valid_0 <= 1;
                    2: valid_0 <= 1;
                    default: valid_0 <= 0;
                endcase
                i <= i+1;      
            end
            else if(o_ready) begin
                i <= 0;
                index <= index + 1;
                valid_0 <= 0;
            end
            else if (i == 307200) begin
                // valid_0 <= 0;
                pixel_0 <= 0;
                depth_0 <= 0;
            end
            valid_1 = 0;
            pixel_1 = 0;
            depth_1 = 0;
        end
        else begin
            if(j < 307200) begin
                if(j == 0) start <= 1;
                else start <= 0;
                valid_1 <= 1;
                pixel_1 <= pixel_in2[j];
                depth_1 <= depth_in2[j];
                j <= j+1;
            end
            else if (done && (cnt_of_d < (n_of_d-1))) begin
                j <= 0;
            end
            else begin
                valid_1 <= 0;
                pixel_1 <= 0;
                depth_1 <= 0;
            end
            if(valid_0_en) begin
                if(k < 307200) begin
                    valid_0 <= 1;
                    pixel_0 <= pixel_in[k];
                    depth_0 <= depth_in[k];
                    k <= k+1;
                end
                else if (done && (cnt_of_d < (n_of_d-1))) begin
                    k <= 0;
                end
                else begin
                    valid_0 <= 0;
                    pixel_0 <= 0;
                    depth_0 <= 0;
                end
            end
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            f_or_d <= 0;
            initial_pose[0]  <= 42'd16777216;
            initial_pose[1]  <= 42'd0;
            initial_pose[2]  <= 42'd0;
            initial_pose[3]  <= 42'd0;
            initial_pose[4]  <= 42'd0;
            initial_pose[5]  <= 42'd16777216;
            initial_pose[6]  <= 42'd0;
            initial_pose[7]  <= 42'd0;
            initial_pose[8]  <= 42'd0;
            initial_pose[9]  <= 42'd0;
            initial_pose[10] <= 42'd16777216;
            initial_pose[11] <= 42'd0;
        end
        else if(done) begin
            initial_pose <= new_pose;
            f_or_d <= 1;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            if (n_of_f == 1) begin
                sigma_icp  <= 84'd8861414002445412;
                sigma_rgbd <= 9'd8;
            end
            else if (n_of_f == 2) begin
                sigma_icp  <= 84'd7774054188783816;
                sigma_rgbd <= 9'd5;
            end
            else if (n_of_f == 3) begin
                sigma_icp  <= 84'd8105605771596010;
                sigma_rgbd <= 9'd5;
            end
            else if (n_of_f == 4) begin
                sigma_icp  <= 84'd8248117036366702;
                sigma_rgbd <= 9'd5;
            end
            else begin
                sigma_icp  <= 84'd7774054188783816;
                sigma_rgbd <= 9'd5;
            end
        end
        if(f_or_d && done) begin
            sigma_icp  <= sigma_icp_next;
            sigma_rgbd <= sigma_rgbd_next;
        end
    end

    assign r_fx = 35'd8678853836;
    assign r_fy = 35'd8665432064;
    assign r_cx = 35'd5345221017;
    assign r_cy = 35'd4283223244;
    assign hsize = 10'd640;
    assign vsize = 10'd480;

    CHIP_All u_CHIP_All(
        // input
         .i_clk                   ( clk )
        ,.i_rst_n                 ( rst_n )
        ,.i_frame_start           ( start )
        ,.i_frame_end             ( frame_end )
        ,.i_f_or_d                ( f_or_d )
        ,.i_n_of_f                ( n_of_f )
        ,.i_valid_0               ( valid_0 )
        ,.i_data0                 ( pixel_0 )
        ,.i_depth0                ( depth_0 )
        ,.i_valid_1               ( valid_1 )
        ,.i_data1                 ( pixel_1 )
        ,.i_depth1                ( depth_1 )
        ,.i_pose                  ( initial_pose )
        // Register  
        ,.r_fx                    ( r_fx )
        ,.r_fy                    ( r_fy )
        ,.r_cx                    ( r_cx )
        ,.r_cy                    ( r_cy )
        ,.r_hsize                 ( hsize )
        ,.r_vsize                 ( vsize )
        ,.sigma_icp               ( sigma_icp )
        ,.sigma_rgbd              ( sigma_rgbd )
        // output
        ,.o_feature_ready         ( o_ready )
        ,.o_done                  ( done )
        ,.o_pose                  ( new_pose )
        ,.o_sigma_icp             ( sigma_icp_next )
        ,.o_sigma_rgbd            ( sigma_rgbd_next )
        //test
        ,.o_update_done           ( update_done )
    );

    // `ifdef SDF
    //     initial $sdf_annotate(`SDFFILE, chip0);
    // `endif

    initial begin
        $fsdbDumpfile("Debug_tb_CHIP_All.fsdb");
        $fsdbDumpvars(3, Debug_tb_CHIP_All, "+mda");
        // $fsdbDumpvars(1, IndirectCalc, "+mda");
    end

    always @(posedge clk)begin
        if (display_cnt == display_en) begin
            $display("finish %d cycles, %d percentage", time_cnt, time_per);
        end
        if(start) begin
            if (!f_or_d) begin
                $display("Feature frame %d start", $unsigned(cnt_of_f_start));
            end
            else begin
                $display("Direct frame %d start", $unsigned(cnt_of_d));
            end
        end
        if(update_done) begin
            if (!f_or_d) begin
                $display("cnt_of_Feature = %d", $unsigned(cnt_of_f));
            end
            else begin
                $display("cnt_of_Direct = %d", $unsigned(cnt_of_d));
            end
            $display("Rt[0] = %d", $signed(new_pose[0]));
            $display("Rt[1] = %d", $signed(new_pose[1]));
            $display("Rt[2] = %d", $signed(new_pose[2]));
            $display("Rt[3] = %d", $signed(new_pose[3]));
            $display("Rt[4] = %d", $signed(new_pose[4]));
            $display("Rt[5] = %d", $signed(new_pose[5]));
            $display("Rt[6] = %d", $signed(new_pose[6]));
            $display("Rt[7] = %d", $signed(new_pose[7]));
            $display("Rt[8] = %d", $signed(new_pose[8]));
            $display("Rt[9] = %d", $signed(new_pose[9]));
            $display("Rt[10] = %d", $signed(new_pose[10]));
            $display("Rt[11] = %d", $signed(new_pose[11]));
            if (!f_or_d) begin
                $display("Feature frame %d end", $unsigned(cnt_of_f));
            end
            else begin
                $display("Direct frame %d end", $unsigned(cnt_of_d));
            end
            if (!f_or_d) begin
                $fwrite(f_poes, "cnt_of_Feature = %d\n", $unsigned(cnt_of_f));
            end
            else begin
                $fwrite(f_poes, "cnt_of_Direct = %d\n", $unsigned(cnt_of_d));
            end
            $fwrite(f_poes, "%d\n", $signed(new_pose[0]));
            $fwrite(f_poes, "%d\n", $signed(new_pose[1]));
            $fwrite(f_poes, "%d\n", $signed(new_pose[2]));
            $fwrite(f_poes, "%d\n", $signed(new_pose[3]));
            $fwrite(f_poes, "%d\n", $signed(new_pose[4]));
            $fwrite(f_poes, "%d\n", $signed(new_pose[5]));
            $fwrite(f_poes, "%d\n", $signed(new_pose[6]));
            $fwrite(f_poes, "%d\n", $signed(new_pose[7]));
            $fwrite(f_poes, "%d\n", $signed(new_pose[8]));
            $fwrite(f_poes, "%d\n", $signed(new_pose[9]));
            $fwrite(f_poes, "%d\n", $signed(new_pose[10]));
            $fwrite(f_poes, "%d\n", $signed(new_pose[11]));
            $fwrite(f_poes, "\n");
        end
    end

endmodule