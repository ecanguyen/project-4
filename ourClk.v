`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2023 12:37:30 PM
// Design Name: 
// Module Name: clk
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


module ourClk(

    input clk,
    //input rst,
//    output [6:0] seg,
//    output [3:0] an,
    
    output wire Hz1
    );
    reg [31:0] some_counter_1Hz = 0;
    reg your_clk_1Hz;


    
    // if adj == 2: clk = 2hz else clk = 1hz
    
    always @ (posedge clk)// or posedge rst) //for 1 hz
    begin
    
//    if (rst) begin
//        $display("reset counter");
//        some_counter_1Hz <= 'd0;
//    end
//    else
     if (some_counter_1Hz == 100000000) //100000000
    begin
        some_counter_1Hz <= 'd0;
        your_clk_1Hz <= 1'b1;
    end
    else
    begin
        //$display("counter: %b", some_counter_1Hz);
        some_counter_1Hz <= some_counter_1Hz + 1'b1;
        your_clk_1Hz <= 1'b0;
    end

    end
    
    assign Hz1 = your_clk_1Hz;
    
endmodule
