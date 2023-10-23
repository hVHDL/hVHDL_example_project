// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
// Copyright (c) 2018 by Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// --------------------------------------------------------------------
//
// Permission:
//
// Lattice SG Pte. Ltd. grants permission to use this code
// pursuant to the terms of the Lattice Reference Design License Agreement.
//
//
// Disclaimer:
//
// This VHDL or Verilog source code is intended as a design reference
// which illustrates how these types of functions can be implemented.
// It is the user's responsibility to verify their design for
// consistency and functionality through the use of formal
// verification methods. Lattice provides no warranty
// regarding the use or functionality of this code.
//
// -----------------------------------------------------------------------------
//
//                     Lattice SG Pte. Ltd.
//                     101 Thomson Road, United Square #07-02
//                     Singapore 307591
//
//
//                     TEL: 1-800-Lattice (USA and Canada)
//                     +65-6631-2000 (Singapore)
//                     +1-503-268-8001 (other locations)
//
//                     web: http://www.latticesemi.com/
//                     email: techsupport@latticesemi.com
//
// -----------------------------------------------------------------------------
//
// =============================================================================
// FILE DETAILS
// Project      : <>
// File         : tb_top.v
// Title        : Testbench for Oscillator.
// Dependencies :
// Description  :
// =============================================================================
// REVISION HISTORY
// Version      : 1.0
// Author(s)    :
// Mod. Date    :
// Changes Made : Initial version
// =============================================================================

`ifndef __TB_TOP__
`define __TB_TOP__

`timescale 10ps/10ps

module tb_top();
`include "dut_params.v"
//--------------------------------------------------------------------------
//--- Local Parameters/Defines ---
//--------------------------------------------------------------------------
localparam              SYS_PERIOD        = 500;

// -----------------------------------------------------------------------------
// Register Declarations
// -----------------------------------------------------------------------------
reg        hf_out_en_i;
reg        hf_switch_i;
reg        sedc_clk_en_i;
reg        sedc_rst_n_i;
reg        reboot_i;
reg        lmmi_resetn_i;
reg        lmmi_clk_i;

reg        done_r; 
reg        test_sts;

reg        lfclk_test_done; 
reg [31:0] lclk_check_cnt;
reg        hclk_test_done;
reg [31:0] hclk_check_cnt;
reg [31:0] exp_clk_freq_hclk;
reg [31:0] exp_clk_period_hclk;
reg        hsedclk_test_done;
reg [31:0] hsedclk_check_cnt;
reg [31:0] exp_clk_freq_hsedclk;
reg [31:0] exp_clk_period_hsedclk;

// -----------------------------------------------------------------------------
// Wire Declarations
// -----------------------------------------------------------------------------
wire lmmi_clk_o; 
wire lmmi_resetn_o; 
wire lf_clk_out_o; 
wire hf_clk_out_o;
wire hf_sed_sec_out_o;

// -----------------------------------------------------------------------------
// Time/Real Declarations
// -----------------------------------------------------------------------------
time time_lf_prev;
time time_lf_nxt;
time time_hf_prev;
time time_hf_nxt;
time actual_clk_period_lfclk;
time actual_clk_period_hfclk;   
time time_sedsec_prev;
time time_sedsec_nxt;
time actual_clk_period_hsedclk;

real exp_clk_period_lclk;
real exp_clk_freq_lclk;
real actual_clk_freq_lfclk;
real actual_clk_freq_lfclk_tol;
real actual_clk_freq_hfclk;
real actual_clk_freq_hsedclk;

//--------------------------------------------------------------------------
// Clock Divider
//--------------------------------------------------------------------------
always #(SYS_PERIOD/2.0000) lmmi_clk_i    = ~lmmi_clk_i;

//--------------------------------------------------------------------------
// Initial statement; Reset sequence
//--------------------------------------------------------------------------
initial begin
  hf_out_en_i            = 1'b0;
  hf_switch_i            = 1'b0;
  sedc_clk_en_i          = 1'b0;
  sedc_rst_n_i           = 1'b0;
  reboot_i               = 1'b0;
  
  lmmi_clk_i             = 1'b1;
  lmmi_resetn_i          = 1'b0;
  
  done_r                 = 1'b0;
  test_sts               = 1'b1;
  
  lclk_check_cnt         = 32'd0;
  exp_clk_freq_lclk      = 32'd0;
  exp_clk_period_lclk    = 32'd0;
                         
  hclk_check_cnt         = 32'd0;
  exp_clk_freq_hclk      = 32'd0;
  exp_clk_period_hclk    = 32'd0;
  
  hsedclk_check_cnt      = 32'd0;
  exp_clk_freq_hsedclk   = 32'd0;
  exp_clk_period_hsedclk = 32'd0;
   
  if (LF_OUTPUT_EN == "ENABLED") begin
    //LF Clock Test
    $display("+-----------------------------------------------------------------");
    $display("Test for LF Clock START!                                          ");
    #(100000000) 
    $display("Test for LF Clock END!                                            ");
    $display("+-----------------------------------------------------------------");
  end
  
  if (HF_OSC_EN == "ENABLED") begin
    //HF Enable Test
    #(100000*HF_CLK_DIV_DEC)    hf_out_en_i = 1; 
    $display("+-----------------------------------------------------------------");
    $display("Test for HF Clock START!                                          ");
    $display("HF Clock ENABLED.                                                 ");
    
    #(1000000*HF_CLK_DIV_DEC)  hf_out_en_i = 0; 
    $display("De-asserting hf_out_en_i...                                       "); 
    
    #(100000*HF_CLK_DIV_DEC)    hf_out_en_i = 1;   
    $display("HF Clock ENABLED again.                                           ");
    $display("Test for HF Clock END!                                            ");
    $display("+-----------------------------------------------------------------");
  end
 
  if (SEDCLK_EN == 2) begin //Enabled by signal
   //SEDCLK Enable and Reset Test
    #(10000*HF_SED_SEC_DIV_DEC)  sedc_rst_n_i    = 1; 
    $display("+-----------------------------------------------------------------");
    $display("Released Reset for SEDC                                           ");
    
    #(100000*HF_SED_SEC_DIV_DEC) sedc_clk_en_i   = 1; 
    $display("SEDC Clock ENABLED                                                ");
    $display("Test for SEDC Clock enable START!                                 ");
    
    #(1000000*HF_SED_SEC_DIV_DEC) sedc_clk_en_i = 0; 
    $display("De-asserting sedc_clk_en_i...                                     ");
    
    #(100000*HF_SED_SEC_DIV_DEC) sedc_clk_en_i   = 1;   
    $display("SEDC Clock ENABLED again.                                         ");
    $display("+-----------------------------------------------------------------");
  end
  
  if ((HF_OSC_EN == "DISABLED") && (DEVICE == "LIFCL-33U")) begin
    //HF Switch Test
    #(100000*HF_CLK_DIV_DEC)    hf_switch_i = 1; 
    $display("+-----------------------------------------------------------------");
    $display("Test for HF Clock START!                                          ");
    $display("HF Clock Switched ON.                                             ");
    
    #(1000000*HF_CLK_DIV_DEC)  hf_switch_i = 0; 
    $display("De-asserting hf_switch_i...                                       ");   
    
    #(100000*HF_CLK_DIV_DEC)    hf_switch_i = 1;   
    $display("HF Clock Switched ON again.                                       ");
    $display("Test for HF Clock END!                                            ");
    $display("+-----------------------------------------------------------------");
    //SEDC Reboot Test
    #(10000*HF_SED_SEC_DIV_DEC)  sedc_rst_n_i    = 1; 
    $display("+-----------------------------------------------------------------");
    $display("Released Reset for SEDC                                           ");
    
    #(1000*HF_SED_SEC_DIV_DEC)  reboot_i        = 1; 
    $display("SEDC Clock is always ENABLED                                      ");
    $display("reboot_i asserted!                                                ");
    $display("Check for internal signal u_OSD.HFCLKCFG...                       ");
    
    #(1000000*HF_SED_SEC_DIV_DEC) reboot_i = 0; 
    $display("De-asserting reboot_i...                                          ");
    $display("Test for SEDC Clock END!                                          ");
    $display("+-----------------------------------------------------------------");
  end
  
  wait(done_r)   
  if(test_sts) begin
    $display("               ********* CLOCK MATCHED *********                  ");
    $display("----------------------  SIMULATION PASSED ------------------------");
    $display("+-----------------------------------------------------------------");
   end
   else begin
    $display("               ********* CLOCK MISMATCHED *********               ");
    $display("-------------------!!!  SIMULATION FAILED !!!---------------------");
    $display("+-----------------------------------------------------------------");
   end
  $finish;
end

// -----------------------------
// ----- TEST FOR LFCLK -----
// -----------------------------
generate
   if (LF_OUTPUT_EN == "ENABLED") begin
      always @(posedge lf_clk_out_o) begin
        time_lf_prev <= $time;
        lclk_check_cnt <= lclk_check_cnt + 1;
        lfclk_test_done <= (lclk_check_cnt > 4)? 1'b1 : 1'b0;       
      end
   end
   else begin
      always @(posedge lf_clk_out_o) begin
        time_lf_prev <= time_lf_prev;     
      end
   end
endgenerate     

always @ (posedge lf_clk_out_o)begin
    time_lf_nxt <= time_lf_prev;
end

always @ * begin
 if (lf_clk_out_o)begin
    actual_clk_period_lfclk = (time_lf_prev - time_lf_nxt);  //Actual Period -- 31.25us
 end
end

//Calculating Actual Low Frequency
always @* begin
    actual_clk_freq_lfclk = 0.1/actual_clk_period_lfclk*(1000000);
end


// -----------------------------
// ----- TEST FOR HFCLK -----
// -----------------------------    
generate
  always @(posedge hf_clk_out_o) begin
    time_hf_prev <= $time;
    hclk_check_cnt <= hclk_check_cnt + 1;
    hclk_test_done <= (hclk_check_cnt > 444)? 1'b1 : 1'b0;      
  end
endgenerate 

always @ (posedge hf_clk_out_o)begin
    time_hf_nxt <= time_hf_prev;
end

always @ * begin
 if (hf_clk_out_o)begin
    actual_clk_period_hfclk = (time_hf_prev - time_hf_nxt);  //Actual Period
 end
end

//Calculating Actual High Frequency
always @* begin
    actual_clk_freq_hfclk = 100000/actual_clk_period_hfclk;
end

// -----------------------------
// ----- TEST FOR SEDCLK -----
// -----------------------------    
generate
   if ((SEDCLK_EN == 1) || (SEDCLK_EN == 2)) begin //0-DISABLED, 1-ALWAYS ENABLED, 2-ENABLED BY SIGNAL
      always @(posedge hf_sed_sec_out_o) begin
        time_sedsec_prev <= $time;
        hsedclk_check_cnt <= hsedclk_check_cnt + 1;
        hsedclk_test_done <= (hsedclk_check_cnt > 444)? 1'b1 : 1'b0;        
      end
   end
   else begin
      always @(posedge hf_sed_sec_out_o) begin
        time_sedsec_prev <= time_sedsec_prev;     
      end
   end
endgenerate 

always @ (posedge hf_sed_sec_out_o)begin
    time_sedsec_nxt <= time_sedsec_prev;
end

always @ * begin
 if (hf_sed_sec_out_o)begin
    actual_clk_period_hsedclk = (time_sedsec_prev - time_sedsec_nxt);  //Actual Period
 end
end

//Calculating Actual High Frequency
always @* begin
    actual_clk_freq_hsedclk = 100000/actual_clk_period_hsedclk;
end

always @* begin
  //LFCLK
  actual_clk_freq_lfclk_tol = (actual_clk_freq_lfclk > 28.8) ? 0.032 :
                              (actual_clk_freq_lfclk < 35.2) ? 0.032 : 0;
  exp_clk_freq_lclk = 0.032;
  exp_clk_period_lclk = 100000/exp_clk_freq_lclk;
  //HFCLK
  exp_clk_freq_hclk = ( 450 / HF_CLK_DIV_DEC );
  exp_clk_period_hclk = 100000/exp_clk_freq_hclk;
  //SEDCLK
  exp_clk_freq_hsedclk = ( 450 / HF_SED_SEC_DIV_DEC );
  exp_clk_period_hsedclk = 100000/exp_clk_freq_hsedclk;
  
  done_r = lfclk_test_done || hclk_test_done || hsedclk_test_done;
    
  if (LF_OUTPUT_EN == "ENABLED") begin
   // done_r = lfclk_test_done;
    test_sts = (exp_clk_freq_lclk ==  actual_clk_freq_lfclk_tol);
  end
  else if (HF_OSC_EN == "ENABLED") begin
   // done_r = hclk_test_done;
    test_sts = (exp_clk_freq_hclk ==  actual_clk_freq_hfclk);
  end
  else if ((SEDCLK_EN == 1) || (SEDCLK_EN == 2)) begin
   // done_r = hsedclk_test_done;
    test_sts = (exp_clk_freq_hsedclk ==  actual_clk_freq_hsedclk);
  end
  else begin//LF,HF and SED enabled
   // done_r = lfclk_test_done & hclk_test_done & hsedclk_test_done;
    test_sts = (exp_clk_freq_lclk ==  actual_clk_freq_lfclk_tol) && (exp_clk_freq_hclk ==  actual_clk_freq_hfclk) && (exp_clk_freq_hsedclk ==  actual_clk_freq_hsedclk) ;
  end
end


//Monitor Display --LF
always @ (lclk_check_cnt > 1)
begin
  if (LF_OUTPUT_EN == "ENABLED") begin
  $monitor("Expected Low Frequency(MHz) : %1.3f, Actual Low Frequency(MHz): %1.3f", exp_clk_freq_lclk, actual_clk_freq_lfclk); 
  end

end

//Monitor Display --HF
always @ (hclk_check_cnt > 1)
begin
  $monitor("Expected High Frequency(MHz) : %d, Actual High Frequency(MHz): %d", exp_clk_freq_hclk, actual_clk_freq_hfclk);
end

//Monitor Display --SEDC
initial
begin
  if ((SEDCLK_EN == 1) || (SEDCLK_EN == 2)) begin
  $monitor("SEDC Frequency cannot be displayed. See OSC IPUG, Appendix A.");
  end
end

// ----------------------------
// GSR instance
// ----------------------------
GSR GSR_INST ( .GSR_N(1'b1), .CLK(1'b0));

`include "dut_inst.v"

endmodule 
`endif