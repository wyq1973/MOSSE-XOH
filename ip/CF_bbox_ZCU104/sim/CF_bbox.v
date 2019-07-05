`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2019 11:31:30 AM
// Design Name: 
// Module Name: CF_bbox
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CF_bbox
  #(
    parameter NPPC = 4,
    parameter DATA_WIDTH = 8,
    parameter POSITION_WIDTH = 12,
    parameter FFT_LENGTH = 64,
    parameter HEIGHT = 2160
    )
   (
    input [NPPC * DATA_WIDTH-1:0]      VIDEO_IN_tdata,
    input 			       VIDEO_IN_tvalid,
    input 			       VIDEO_IN_tuser,
    input 			       VIDEO_IN_tlast,
    output 			       VIDEO_IN_tready,
    input [POSITION_WIDTH - 1 : 0]     xStart,
    input [POSITION_WIDTH - 1 : 0]     yStart,
    output [3 * NPPC * DATA_WIDTH-1:0] VIDEO_OUT_tdata,
    output 			       VIDEO_OUT_tvalid,
    output 			       VIDEO_OUT_tuser,
    output 			       VIDEO_OUT_tlast,
    input 			       VIDEO_OUT_tready,
    input 			       s_axis_video_aclk
    );

   wire 			       PixelValid = VIDEO_IN_tvalid && VIDEO_IN_tready;
   wire 			       LastPixel = VIDEO_IN_tvalid && VIDEO_IN_tready && VIDEO_IN_tlast;

   wire 			       yLeftBorder;
   wire 			       yRightBorder;
   wire 			       xBorder;

   wire [3 * DATA_WIDTH - 1 : 0]       IN_PX3 = {3{VIDEO_IN_tdata[31:24]}};
   wire [3 * DATA_WIDTH - 1 : 0]       IN_PX2 = {3{VIDEO_IN_tdata[23:16]}};
   wire [3 * DATA_WIDTH - 1 : 0]       IN_PX1 = {3{VIDEO_IN_tdata[15:8]}};
   wire [3 * DATA_WIDTH - 1 : 0]       IN_PX0 = {3{VIDEO_IN_tdata[7:0]}};

   wire [3 * DATA_WIDTH - 1 : 0] 	       R = 24'hff0000;
   wire [3 * DATA_WIDTH - 1 : 0] 	       B = 24'h000000;

   reg [POSITION_WIDTH - 1 : 0]        xPos = 12'b0;
   reg [POSITION_WIDTH - 1 : 0]        yPos = 12'b0;

   always @(posedge s_axis_video_aclk)
     begin
	if (PixelValid) xPos <= xPos + 1;
	if (LastPixel)
	  begin
	     xPos <= 12'b0;
	     if (yPos == HEIGHT - 1) yPos <= 12'b0;
	     else yPos <= yPos + 1;
	  end
	if (VIDEO_IN_tuser) yPos <= 12'b0;
     end // always @ (posedge s_axis_video_aclk)

   assign xBorder = (xPos >= xStart/NPPC) && (xPos < xStart/NPPC + FFT_LENGTH/NPPC) && ((yPos == yStart) || (yPos == yStart + FFT_LENGTH - 1));
   assign yLeftBorder = (yPos >= yStart) && (yPos < yStart + FFT_LENGTH) && (xPos == xStart/NPPC);
   assign yRightBorder = (yPos >= yStart) && (yPos < yStart + FFT_LENGTH) && (xPos == xStart/NPPC + FFT_LENGTH/NPPC - 1);

   assign VIDEO_OUT_tdata = xBorder ? {R, R, R, R} :
			    yLeftBorder ? {IN_PX3, IN_PX2, IN_PX1, R}:
			    yRightBorder ? {R, IN_PX2, IN_PX1, IN_PX0} :
			    {IN_PX3, IN_PX2, IN_PX1, IN_PX0};

   assign VIDEO_OUT_tvalid = VIDEO_IN_tvalid;
   assign VIDEO_OUT_tuser = VIDEO_IN_tuser;
   assign VIDEO_OUT_tlast = VIDEO_IN_tlast;
   assign VIDEO_IN_tready = VIDEO_OUT_tready;

endmodule
