`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2023 01:44:17 PM
// Design Name: 
// Module Name: counter
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


module counter(
    input clk1Hz,
    input clk,
    input rst,
    
    output [7:0] seconds
    
    );
    
    reg [7:0] secCounter = 0;
    reg current_clk = 0;
    
//    always @ (posedge pause) begin
//        if(pause == 1)
//            temp_pause <=1;
//    end

//     always @ (*) begin
//	 if (adj) begin
//	 	current_clk = clk2Hz;
//	 end
//	 else begin
//	 	current_clk = clk1Hz;
//	 end
//     end
    
    
	always @ (posedge clk or posedge rst) begin

	
	if (rst) begin
	   secCounter <= 59;
	end else begin

            if(clk1Hz) begin
                if (secCounter == 0) begin
                    secCounter <= 59;
                end else begin
                    secCounter <= secCounter - 1;
                end
          end
	end
end
//    always @ (posedge clk1Hz or posedge rst) begin
//    // if(pause == 1) begin
//    //      temp_pause <= ~temp_pause;
//        // pause = 0;
//    // end
//    if (rst) begin
//       minCounter <= 0;
//       secCounter <= 0;
//    end else begin
//        if (~temp_pause) begin
//            minCounter <= minutes;
//            secCounter <= seconds;
//            if (~adj) begin
//                if (minCounter == 59 && secCounter == 59) begin
//                    minCounter <= 0;
//                    minCounter <= 0;
//                end else if (minCounter != 59 && secCounter == 59) begin
//                    minCounter <= minCounter + 1;
//                    secCounter <= 0;
//                end else begin
//                    secCounter <= secCounter + 1;
//                end
//            end
//        end
//    end
//end
//    always @ (posedge clk2Hz or posedge rst) begin
//	// if(pause == 1) begin
//	//      temp_pause <= ~temp_pause;
//		// pause = 0;
//	// end
//	if (rst) begin
//	   minCounter <= 0;
//	   secCounter <= 0;
//	end else begin
//        if (~temp_pause) begin
//            minCounter <= minutes;
//            secCounter <= seconds;
//            if (adj) begin
//                if (sel) begin
//                    if (secCounter == 59) begin
//                        secCounter <= 0;
//                    end else begin
//                        secCounter <= secCounter + 1;
//                    end
//                end else begin
//                    if (minCounter == 59) begin
//                        minCounter <= 0;
//                    end else begin
//                        minCounter <= minCounter + 1;
//                    end
//                end
//            end
//        end
//	end
//end
assign seconds = secCounter;
   
   
endmodule
