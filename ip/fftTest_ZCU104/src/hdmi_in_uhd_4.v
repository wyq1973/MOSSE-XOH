`timescale 1ns / 1ps
//-----------------------------------------------
// Company: AGH
// Engineer: Marcin Kowalczyk
// Create Date: 23:14:48 04/19/2011 
// Description: Video stream generator from file for UHD 4 pixel stream
//-----------------------------------------------

module hdmi_in_uhd_4
  #(
    parameter no_valid_width = 1,
    parameter valid_step = 10
    )
   (
    output 	  s_axis_video_aclk,
    output 	  s_axis_video_aresetn,
    output [95:0] VIDEO_IN_tdata,
    output 	  VIDEO_IN_tlast,
    input 	  VIDEO_IN_tready,
    output 	  VIDEO_IN_tuser,
    output 	  VIDEO_IN_tvalid
    );

   //-----------------------------------------------

   // Settings for 1280 x 720 image
   //horizontal
   localparam hr=1280/4; //resolution
   localparam hp=120; //porch
   //vertical
   localparam vr=720; //resolution
   localparam vp=200; //porch

   // States
   localparam init_frame = 3'd0;
   localparam read = 3'd1;
   localparam no_valid = 3'd2;
   localparam end_line = 3'd3;
   localparam no_line = 3'd4;
   localparam no_frame = 3'd5;
   localparam reset = 3'd6;

   reg [2:0] 	  state = reset;
   reg [6:0] 	  cnt = 3'b0;

   //-----------------------------------------------

   reg 		  clk;
   reg 		  rst = 1'b0;
   reg [95:0] 	  tdata = 96'b0;
   reg 		  tlast;
   reg 		  tuser;
   reg 		  tvalid;

   reg [11:0] 	  hcounter = 12'b0;
   reg [11:0] 	  vcounter = 12'b0;  // more ???
   reg [11:0] 	  valid_counter = 12'b0;

   //-----------------------------------------------
   // Pixel clock generator
   //-----------------------------------------------

   initial
     begin
	while(1)
	  begin
	     #1 clk <= 1'b0;
	     #1 clk <= 1'b1;
	  end
     end

   //-----------------------------------------------

   integer rgbfile, i, v;

   //-----------------------------------------------

   always @(posedge clk)
     begin

	cnt <= cnt + 1;

	case(state)

	  reset:
	    begin
	       if (cnt == 7'd5) rst <= 1'b1;
	       if (cnt == 7'd100) state <= init_frame;
	    end
          
          init_frame:
            begin
               tlast <= 1'b0;
               tuser <= 1'b1;
               hcounter <= hcounter + 1;
               tvalid <= 1'b1;
               
               rgbfile = $fopen("/home/vision/Documents/Vivado/2018.2_Projects/fftTest_ZCU104/snake.ppm", "rb");
               
               // read header file (for bigger images can be different)
               for(i = 0; i < 16; i = i + 1)
		 begin
		    v = $fgetc(rgbfile);
		 end

	       tdata[23-:8] <= $fgetc(rgbfile);
               tdata[7-:8]  <= $fgetc(rgbfile);
               tdata[15-:8] <= $fgetc(rgbfile);

	       tdata[47-:8] <= $fgetc(rgbfile);
               tdata[31-:8] <= $fgetc(rgbfile);
               tdata[39-:8] <= $fgetc(rgbfile);

               tdata[71-:8] <= $fgetc(rgbfile);
               tdata[55-:8] <= $fgetc(rgbfile);
               tdata[63-:8] <= $fgetc(rgbfile);
               
	       tdata[95-:8] <= $fgetc(rgbfile);
               tdata[79-:8] <= $fgetc(rgbfile);
               tdata[87-:8] <= $fgetc(rgbfile);
	       
               if(valid_counter < valid_step - 1)
		 begin
                    valid_counter <= valid_counter + 1;
                    state <= read;
		 end
               else
		 begin
                    valid_counter <= 12'b0;
                    state <= no_valid;
		 end
            end
          
          read:
            begin
               tlast <= 1'b0;
               tuser <= 1'b0;
               hcounter <= hcounter + 1;
               tvalid <= 1'b1;

	       tdata[23-:8] <= $fgetc(rgbfile);
               tdata[7-:8]  <= $fgetc(rgbfile);
               tdata[15-:8] <= $fgetc(rgbfile);

	       tdata[47-:8] <= $fgetc(rgbfile);
               tdata[31-:8] <= $fgetc(rgbfile);
               tdata[39-:8] <= $fgetc(rgbfile);

               tdata[71-:8] <= $fgetc(rgbfile);
               tdata[55-:8] <= $fgetc(rgbfile);
               tdata[63-:8] <= $fgetc(rgbfile);
               
	       tdata[95-:8] <= $fgetc(rgbfile);
               tdata[79-:8] <= $fgetc(rgbfile);
               tdata[87-:8] <= $fgetc(rgbfile);
	       
               if(hcounter == hr - 2)
		 begin
                    state <= end_line;
		 end
               else if(valid_counter < valid_step - 1)
		 begin
                    valid_counter <= valid_counter + 1;
		 end
               else
		 begin
                    valid_counter <= 12'b0;
                    state <= no_valid;
		 end
            end
          
          no_valid:
            begin
               tlast <= 1'b0;
               tuser <= 1'b0;
               tvalid <= 1'b0;
               
               if(valid_counter < no_valid_width -1) valid_counter <= valid_counter + 1;
               else
		 begin
                    valid_counter <= 12'b0;
                    state <= read;
		 end
            end
          
          end_line:
            begin
               tlast <= 1'b1;
               tuser <= 1'b0;
               hcounter <= 12'b0;
               tvalid <= 1'b1;
              
	       tdata[23-:8] <= $fgetc(rgbfile);
               tdata[7-:8]  <= $fgetc(rgbfile);
               tdata[15-:8] <= $fgetc(rgbfile);

	       tdata[47-:8] <= $fgetc(rgbfile);
               tdata[31-:8] <= $fgetc(rgbfile);
               tdata[39-:8] <= $fgetc(rgbfile);

               tdata[71-:8] <= $fgetc(rgbfile);
               tdata[55-:8] <= $fgetc(rgbfile);
               tdata[63-:8] <= $fgetc(rgbfile);
               
	       tdata[95-:8] <= $fgetc(rgbfile);
               tdata[79-:8] <= $fgetc(rgbfile);
               tdata[87-:8] <= $fgetc(rgbfile);
	       
               if(vcounter == vr - 1)
		 begin
                    vcounter <= 12'b0;
                    state <= no_frame;
		 end
               else
		 begin
                    vcounter <= vcounter + 1;
                    state <= no_line;
		 end
            end
          
          no_line:
            begin
               tlast <= 1'b1;
               tuser <= 1'b0;
               tvalid <= 1'b0;
               
               if(hcounter < hp - 1) hcounter <= hcounter + 1;
               else 
		 begin
                    hcounter <= 12'b0;
                    state <= read;
		 end
            end
          
          no_frame:
            begin
               tlast <= 1'b1;
               tuser <= 1'b0;
               hcounter <= hcounter + 1;
               tvalid <= 1'b0;
               
               if(hcounter < vp - 1) hcounter <= hcounter + 1;
               else 
		 begin
                    hcounter <= 12'b0;
                    state <= init_frame;
		 end
            end
	endcase

     end

   //-----------------------------------------------

   assign s_axis_video_aclk = clk;
   assign s_axis_video_aresetn = rst;
   assign VIDEO_IN_tdata = tdata;
   assign VIDEO_IN_tlast = tlast;
   assign VIDEO_IN_tuser = tuser;
   assign VIDEO_IN_tvalid = tvalid;
   
   //-----------------------------------------------
endmodule
//-----------------------------------------------
