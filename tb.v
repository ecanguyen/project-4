`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2023 12:56:05 PM
// Design Name: 
// Module Name: tb
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

module tb;

    reg clock;
    reg [3:0] sw = 0;
    wire [3:0] an;
    wire [6:0] seg;
    wire [2:0] red;
    wire [2:0] green;
    wire [1:0] blue;
    wire Hsync = 0;
    wire Vsync = 0;
    reg [10:0] counter = 0;

    initial 
        begin
            clock = 0;
        end
    //assign an = 0;
    //assign seg = 0;
    runner runner(
        .clk(clock), .reset(0), .sw(sw), .an(an), .seg(seg), 
        .vgaRed(red), .vgaBlue(blue), .vgaGreen(green), 
        .Hsync(Hsync), .Vsync(Vsync)
    );
    always begin
        #1 clock = ~clock;
        counter = counter + 1;
        if(counter == 997) begin
            //$display("%d, %d", an, seg);
            counter = 0;
        end
//        $display("%b, %b, %b, %b", om, os, tm, ts);
        //$display("%d, %d", an, seg);
        
    end
    
//    clk clk(.clk(clock),.rst(0),.Hz1(Hz1),.Hz2(Hz2),.Hz50(Hz50),.greaterThan1Hz(gt1Hz));
    
//    $display("%b, %b, %b, %b",Hz1, Hz2, Hz50, gt1Hz);  
    

//clk clk(.clk(clock),.rst(0),.Hz1(Hz1),.Hz2(Hz2),.Hz50(Hz50),.greaterThan1Hz(gt1Hz));

//always @ (posedge clock)
// $display("%b, %b, %b, %b",Hz1, Hz2, Hz50, gt1Hz);
 

endmodule
