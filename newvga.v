`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:30:38 03/19/2013 
// Design Name: 
// Module Name:    vga640x480 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module newvga

	(
        input [7:0] seconds,
		input wire clk, reset,
		input sw1,
        input sw2,
        input sw3,
        input sw4,
        input scoreZero,
		output wire Hsync, Vsync,
		output reg [3:0] vgaRed,
		output reg [3:0] vgaGreen,
		output reg [3:0] vgaBlue,
		output reg [3:0] an,
        output reg [6:0] seg
	);
	
	// constant declarations for VGA sync parameters
	localparam H_DISPLAY       = 640; // horizontal display area
	localparam H_L_BORDER      =  48; // horizontal left border
	localparam H_R_BORDER      =  16; // horizontal right border
	localparam H_RETRACE       =  96; // horizontal retrace
	localparam H_MAX           = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
	localparam START_H_RETRACE = H_DISPLAY + H_R_BORDER;
	localparam END_H_RETRACE   = H_DISPLAY + H_R_BORDER + H_RETRACE - 1;
	
	localparam V_DISPLAY       = 480; // vertical display area
	localparam V_T_BORDER      =  10; // vertical top border
	localparam V_B_BORDER      =  33; // vertical bottom border
	localparam V_RETRACE       =   2; // vertical retrace
	localparam V_MAX           = V_DISPLAY + V_T_BORDER + V_B_BORDER + V_RETRACE - 1;
        localparam START_V_RETRACE = V_DISPLAY + V_B_BORDER;
	localparam END_V_RETRACE   = V_DISPLAY + V_B_BORDER + V_RETRACE - 1;
	
	// mod-4 counter to generate 25 MHz pixel tick
	reg [1:0] pixel_reg = 0;
	wire [1:0] pixel_next;
	wire pixel_tick;
	
	always @(posedge clk, posedge reset) begin
	   //$display("pixel reg/next, %b, %b", pixel_reg, pixel_next);
		if(reset)
		  pixel_reg <= 0;
		else
		  pixel_reg <= pixel_next;
    end
	
	assign pixel_next = pixel_reg + 1; // increment pixel_reg 
	
	assign pixel_tick = (pixel_reg == 0); // assert tick 1/4 of the time
	
	// registers to keep track of current pixel location
	reg [9:0] h_count_reg = 0, h_count_next = 0, v_count_reg = 0, v_count_next = 0;
	
	// register to keep track of vsync and hsync signal states
	reg vsync_reg, hsync_reg;
	wire vsync_next, hsync_next;
	
	
	
    reg [3:0] mole = 0;
    reg [31:0] counter = 0;
    reg [10:0] score = 0;
    reg [6:0] tenScore;
    reg [6:0] oneScore;
    reg [6:0] number [0:9];
    reg  [6:0] tempseg;
    reg  [3:0] tempan;
    reg [3:0] displaycounter = 0;
    reg [31:0] rngMod = 10000019;
    reg [50:0] rngSeed = 123314;
    reg [7:0] chance [0:3];
    reg displayon = 1;
    reg [31:0] counter2 = 0;
    
    reg [6:0] tempTensSeconds;
    reg [6:0] tempOnesSeconds;
    
    integer i = 0;
    integer a = 0;
    initial begin
            number[0] = 7'b0000001;
            number[1] = 7'b1001111;
            number[2] = 7'b0010010;
            number[3] = 7'b0000110;
            number[4] = 7'b1001100;
            number[5] = 7'b0100100;
            number[6] = 7'b0100000;
            number[7] = 7'b0001111;
            number[8] = 7'b0000000;
            number[9] = 7'b0001100;
            chance[0] = 1;
            chance[1] = 1;
            chance[2] = 1;
            chance[3] = 1;
            //? right top, right bottom, ? ? ?  top
    end
	// infer registers

	always @(posedge clk, posedge reset) begin
	    counter2 <= counter2 + 1;
	    if(counter2 == 50000000) begin 
	       counter2 <= 0;
	       displayon <= ~displayon;
	    end
	    if(counter % 10000 == 0) begin
	    
           tempOnesSeconds <= number[seconds%10];
           tempTensSeconds <= number[seconds/10];
	    
            tenScore <= number[score/10];
            oneScore <= number[score%10];
            if(displaycounter == 0) begin
                tempan <= 4'b0111; //0111
                tempseg <= tenScore;
//                if(reset == 1) begin
//                    tempseg <= 7'b1111111;
//                    score <= 0;
//                end
                displaycounter <= 1;
            end else if(displaycounter == 1) begin
                tempseg <= oneScore;
                tempan <= 4'b1011; //1011
//                if(reset == 1) begin
//                    tempseg <= 7'b1111111;
//                    score <= 0;
//                end
                displaycounter <= 2;           
            end else if(displaycounter == 2) begin
                    
                    tempseg <= tempTensSeconds;
                    tempan <= 4'b1101; //1011
//                    if(reset == 1) begin
//                        tempseg <= 7'b1111111;
//                        score <= 0;
//                    end
                    displaycounter <= 3;
            end else if(displaycounter == 3) begin
                     tempseg <= tempOnesSeconds;
                    tempan <= 4'b1110; //1011
//                    if(reset == 1) begin
//                        tempseg <= 7'b1111111;
//                        score <= 0;
//                    end
                    displaycounter <= 0;    
            end 
            an <= tempan;
            if(scoreZero == 1 && displayon == 0) begin
                tempseg <= 7'b1111111;
            end else if(scoreZero == 1 && (displaycounter == 2 || displaycounter == 3)) begin
                tempseg <= number[0];
            end else
                seg <= tempseg;
            
        end
        // reset condition
        counter <= counter + 1;
        if(sw1 == 1) begin
           if(mole[0] == 1) begin
               mole[0] = 0;
               score = score + 1;
           end
        end
        if(sw2 == 1) begin
           if(mole[1] == 1) begin
               mole[1] = 0;
               score = score + 1;
           end
        end
        if(sw3 == 1) begin
           if(mole[2] == 1) begin
               mole[2] = 0;
               score = score + 1;
           end
        end
        if(sw4 == 1) begin
           if(mole[3] == 1) begin
               mole[3] = 0;
               score = score + 1;
           end
        end
//        if(counter % 100 == 0) begin
//            $display("%b, %b, mole, score, green, red: %b, %b, %b, %b", an, seg, mole, score, vgaGreen, vgaRed);
//        end
        if(counter == 10000000) begin 
           $display("UPDATE: %b, %b, %b, %b", an, seg, mole, score);
           counter <= 0;

           for(i = 0; i < 4; i=i+1) begin
               rngSeed = rngSeed * 6373397;
               rngSeed = rngSeed % rngMod;
               $display("rng value: %b, %b", rngSeed, rngSeed%137);
               if(mole[i]==1) begin
                   if(rngSeed%137 < chance[i]) begin
                       $display("turn mole %d off", i);
                       mole[i] = 0;
                       if(score > 0) begin
                           score = score - 1;
                       end
                       chance[i] = 1;
                   end else begin
                       chance[i] = chance[i]+1;
                   end
               end else if(mole[i] == 0 && rngSeed%137 < 2) begin
                   $display("turn mole %d on", i);
                   mole[i] = 1;
               end
           end
        end
		if(reset)
		    begin
                    v_count_reg <= 0;
                    h_count_reg <= 0;
                    vsync_reg   <= 0;
                    hsync_reg   <= 0;
                    score <= 0;
		    end
		else
		    begin
                    v_count_reg <= v_count_next;
                    h_count_reg <= h_count_next;
                    vsync_reg   <= vsync_next;
                    hsync_reg   <= hsync_next;
		    end
	end
	// next-state logic of horizontal vertical sync counters
	always @*
		begin
		//$display("v/h count, %b, %b", h_count_next, v_count_next);
		h_count_next = pixel_tick ? 
		               h_count_reg == H_MAX ? 0 : h_count_reg + 1
			       : h_count_reg;
		
		v_count_next = pixel_tick && h_count_reg == H_MAX ? 
		               (v_count_reg == V_MAX ? 0 : v_count_reg + 1) 
			       : v_count_reg;
		end
		
        // hsync and vsync are active low signals
        // hsync signal asserted during horizontal retrace
        assign hsync_next = h_count_reg >= START_H_RETRACE
                            && h_count_reg <= END_H_RETRACE;
   
        // vsync signal asserted during vertical retrace
        assign vsync_next = v_count_reg >= START_V_RETRACE 
                            && v_count_reg <= END_V_RETRACE;

        // video only on when pixels are in both horizontal and vertical display region
        assign video_on = (h_count_reg < H_DISPLAY) 
                          && (v_count_reg < V_DISPLAY);
		always @(*)
		begin
			// first check if we're within vertical active video range
			//$display("always begin");
//			if(counter % 100 == 0) begin
//			    $display("v/h reg %b, %b", v_count_reg, h_count_reg);
//			end
			if (v_count_reg >= 0 && v_count_reg < V_DISPLAY) begin 
			    //$display("within v_display");
			    if (h_count_reg >= 0 && h_count_reg < H_DISPLAY) begin
			        //$display("within h_display");
			        if (v_count_reg >= 40 && v_count_reg < 200) begin
                       if (h_count_reg >= 40 && h_count_reg < 280)begin 
                           if(mole[0] == 1'b1) begin
                               vgaRed = 4'b0000;
                               vgaGreen = 4'b1111;
                               vgaBlue = 4'b0000;
                           end else begin
                               vgaRed = 4'b1111;
                               vgaGreen = 4'b1100;
                               vgaBlue = 4'b1101;
                           end
                       end else if (h_count_reg >= 360 && h_count_reg < 600)begin 
                           if(mole[2] == 1'b1) begin
                               vgaRed = 4'b0000;
                               vgaGreen = 4'b1111;
                               vgaBlue = 4'b0000;
                           end else begin
                               vgaRed = 4'b1111;
                               vgaGreen = 4'b1010;
                               vgaBlue = 4'b0000;
                           end
                       end else begin
                           vgaRed = 0;
                           vgaGreen = 1111;
                           vgaBlue = 1111;
                       end
                    end else if (v_count_reg >= 280 && v_count_reg < 440) begin
                       if (h_count_reg >= 40 && h_count_reg < 280)begin 
                           if(mole[1] == 1'b1) begin
                               vgaRed = 4'b0000;
                               vgaGreen = 4'b1111;
                               vgaBlue = 4'b0000;
                           end else begin
                               vgaRed = 4'b0000;
                               vgaGreen = 4'b0000;
                               vgaBlue = 4'b1111;
                           end
                       end else if (h_count_reg >= 360 && h_count_reg < 600)begin 
                          if(mole[3] == 1'b1) begin
                              vgaRed = 4'b0000;
                              vgaGreen = 4'b1110;
                              vgaBlue = 4'b0000;
                          end else begin
                              vgaRed = 4'b1111;
                              vgaGreen = 4'b1111;
                              vgaBlue = 4'b0000;
                          end
                      end else begin
                          vgaRed = 0;
                          vgaGreen = 1111;
                          vgaBlue = 1111;
                      end
                    end else begin
                        vgaRed = 0;
                        vgaGreen = 1111;
                        vgaBlue = 1111;
                    end
                end else begin
                    vgaRed = 0;
                    vgaGreen = 0;
                    vgaBlue = 0;
                end
            end else begin
                vgaRed = 0;
                vgaGreen = 0;
                vgaBlue = 0;
            end
        end
        // output signals
        assign Hsync  = hsync_reg;
        assign Vsync  = vsync_reg;
        // assign x      = h_count_reg;
        // assign y      = v_count_reg;
        // assign p_tick = pixel_tick;
endmodule
