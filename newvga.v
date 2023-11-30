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
		input wire clk, reset,
		input sw1,
        input sw2,
        input sw3,
        input sw4,
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
    reg [10:0] score = 34;
    reg [6:0] tenScore;
    reg [6:0] oneScore;
    reg [6:0] number [0:9];
    reg  [6:0] tempseg;
    reg  [3:0] tempan;
    reg [3:0] displaycounter = 0;
    
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
    end
	// infer registers

	always @(posedge clk, posedge reset) begin
	    tenScore <= number[score/10];
        oneScore <= number[score%10];
        if(displaycounter == 0) begin
            tempan <= 4'b0111; //0111
            tempseg <= tenScore;
            displaycounter <= 1;
        end else if(displaycounter == 1) begin
            tempseg <= oneScore;
            tempan <= 4'b1011; //1011
            displaycounter <= 0;
        end 
        an <= tempan;
        seg <= tempseg;
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
        if(counter % 100 == 0) begin
            $display("%b, %b, %b, %b", an, seg, mole, score);
        end
        if(counter == 1000) begin 
           $display("UPDATE: %b, %b, %b, %b", an, seg, mole, score);
           counter <= 0;
           for(i = 0; i < 4; i=i+1) begin
               a = $urandom%5;
               if(mole[i]==1 && a > 0) begin
                   mole[i] = 0;
                   if(score > 0) begin
                       score = score - 1;
                   end
               end else if(mole[i] == 0 && a == 0) begin
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
		$display("v/h count, %b, %b", h_count_next, v_count_next);
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
			$display("always begin");
			$display("v/h reg %b, %b", v_count_reg, h_count_reg);
			if (v_count_reg >= 0 && v_count_reg < V_DISPLAY) begin
			    $display("within v_display");
			    if (h_count_reg >= 0 && h_count_reg < H_DISPLAY) begin
			        $display("within h_display");
                    if (v_count_reg >= 0 && v_count_reg < 240) begin
                       if (h_count_reg >= 0 && h_count_reg < 320)begin 
                           if(mole[0] == 1'b1) begin
                               $display("mole 0 is 1");
                               vgaRed = 4'b0000;
                               vgaGreen = 4'b1111;
                               vgaBlue = 4'b0000;
                           end else begin
                           $display("mole 0 is 0");
                               vgaRed = 4'b1111;
                               vgaGreen = 4'b0000;
                               vgaBlue = 4'b0000;
                           end
                       end
                    end
                    else if (v_count_reg >= 240 && v_count_reg < 480) begin
                       if (h_count_reg >= 0 && h_count_reg < 320)begin 
                           if(mole[1] == 1'b1) begin
                           $display("mole 1 is 1");
                               vgaRed = 4'b0000;
                               vgaGreen = 4'b1111;
                               vgaBlue = 4'b0000;
                           end else begin
                           $display("mole 1 is 0");
                               vgaRed = 4'b1111;
                               vgaGreen = 4'b0000;
                               vgaBlue = 4'b0000;
                           end
                       end
                    end
                    else if (v_count_reg >= 0 && v_count_reg < 240) begin
                       if (h_count_reg >= 320 && h_count_reg < 640)begin 
                           if(mole[2] == 1'b1) begin
                           $display("mole 2 is 1");
                               vgaRed = 4'b0000;
                               vgaGreen = 4'b1111;
                               vgaBlue = 4'b0000;
                           end else begin
                           $display("mole 2 is 0");
                               vgaRed = 4'b1111;
                               vgaGreen = 4'b0000;
                               vgaBlue = 4'b0000;
                           end
                       end
                    end
                    else if (v_count_reg >= 240 && v_count_reg < 480) begin
                       if (h_count_reg >= 320 && h_count_reg < 640)begin 
                           if(mole[3] == 1'b1) begin
                           $display("mole 3 is 1");
                               vgaRed = 4'b0000;
                               vgaGreen = 4'b1111;
                               vgaBlue = 4'b0000;
                           end else begin
                           $display("mole 3 is 0");
                               vgaRed = 4'b1111;
                               vgaGreen = 4'b0000;
                               vgaBlue = 4'b0000;
                           end
                       end
                    end
                    else begin
                        vgaRed = 0;
                        vgaGreen = 0;
                        vgaBlue = 0;
                    end
                end
                else begin
                    vgaRed = 0;
                    vgaGreen = 0;
                    vgaBlue = 0;
                end
            end
            else begin
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