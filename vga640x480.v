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
module vga(
	input wire dclk,			//pixel clock: 25MHz
	input wire clr,			//asynchronous reset
	input sw1,
	input sw2,
	input sw3,
	input sw4,
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [1:0] blue,	//blue vga output
	output reg [3:0] an,
	output reg [6:0] seg
	);

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc = 0;
reg [9:0] vc = 0;
reg [3:0] mole = 0;
reg [31:0] counter = 0;
reg [10:0] score = 0;
reg [6:0] tenScore;
reg [6:0] oneScore;
reg [6:0] number [0:9];
reg  [6:0] tempseg;
reg  [3:0] tempan;
reg [3:0] displaycounter = 0;

integer i = 0;
integer a = 0;
// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
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
always @(posedge dclk or posedge clr)
begin
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
	if(counter == 100) begin 
	   $display("%b, %b", hsync, vsync);
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
	if (clr == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
		
	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
always @(*)
begin
    
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vbp+240) begin
	   if (hc >= hbp && hc < (hbp+320))begin 
	       if(mole[0] == 1) begin
               red = 3'b000;
               green = 3'b111;
               blue = 2'b00;
           end else begin
               red = 3'b111;
               green = 3'b000;
               blue = 2'b00;
           end
	   end
	end
	if (vc >= vbp+240 && vc < vbp+480) begin
       if (hc >= hbp && hc < (hbp+320))begin  
           if(mole[1] == 1) begin
              red = 3'b000;
              green = 3'b111;
              blue = 2'b00;
          end else begin
              red = 3'b111;
              green = 3'b000;
              blue = 2'b00;
          end
       end
    end
	if (vc >= vbp && vc < vbp+240) begin
       if (hc >= hbp+320 && hc < (hbp+640))begin 
           if(mole[2] == 1) begin
              red = 3'b000;
              green = 3'b111;
              blue = 2'b00;
          end else begin
              red = 3'b111;
              green = 3'b000;
              blue = 2'b00;
          end
       end
    end
    if (vc >= vbp+240 && vc < vbp+480) begin
       if (hc >= hbp+320 && hc < (hbp+640))begin 
           if(mole[3] == 1) begin
              red = 3'b000;
              green = 3'b111;
              blue = 2'b00;
          end else begin
              red = 3'b111;
              green = 3'b000;
              blue = 2'b00;
          end
       end
    end
    
//	if (vc >= vbp && vc < vfp)
//	begin
//		// now display different colors every 80 pixels
//		// while we're within the active horizontal range
//		// -----------------
//		// display white bar
		
//		if (hc >= hbp && hc < (hbp+20))
//		begin
//			red = 3'b111;
//			green = 3'b111;
//			blue = 2'b11;
//		end
//		// display yellow bar
//		else if (hc >= (hbp+80) && hc < (hbp+160))
//		begin
//			red = 3'b111;
//			green = 3'b111;
//			blue = 2'b00;
//		end
//		// display cyan bar
//		else if (hc >= (hbp+160) && hc < (hbp+240))
//		begin
//			red = 3'b000;
//			green = 3'b111;
//			blue = 2'b11;
//		end
//		// display green bar
//		else if (hc >= (hbp+240) && hc < (hbp+320))
//		begin
//			red = 3'b000;
//			green = 3'b111;
//			blue = 2'b00;
//		end
//		// display magenta bar
//		else if (hc >= (hbp+320) && hc < (hbp+400))
//		begin
//			red = 3'b111;
//			green = 3'b000;
//			blue = 2'b11;
//		end
//		// display red bar
//		else if (hc >= (hbp+400) && hc < (hbp+480))
//		begin
//			red = 3'b111;
//			green = 3'b000;
//			blue = 2'b00;
//		end
//		// display blue bar
//		else if (hc >= (hbp+480) && hc < (hbp+560))
//		begin
//			red = 3'b000;
//			green = 3'b000;
//			blue = 2'b11;
//		end
//		// display black bar
//		else if (hc >= (hbp+560) && hc < (hbp+640))
//		begin
//			red = 3'b000;
//			green = 3'b000;
//			blue = 2'b00;
//		end
//		// we're outside active horizontal range so display black
//		else
//		begin
//			red = 0;
//			green = 0;
//			blue = 0;
//		end
//	end
//	// we're outside active vertical range so display black
	if (vc < vbp || vc >= vfp || hc < hbp || hc >= hfp)begin
		red = 0;
		green = 0;
		blue = 0;
	end
end

endmodule
