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

module runner(
    an, seg, clk, sw, Hsync, Vsync, vgaRed, vgaBlue, vgaGreen, reset
);

    input clk;
    input [3:0] sw;
    input reset;
    output [3:0] an;//selection for which light to change
    output [6:0] seg;//cathode or lights
    output [3:0] vgaRed;
    output [3:0] vgaGreen;
    output [3:0] vgaBlue;
    output Hsync;
    output Vsync;
    wire [6:0] tmpSeg;
    wire [3:0] tmpAn;
    wire tmph;
    wire tmpv;    
    wire [3:0] dbsw;
    wire rst_state;
    wire [7:0] seconds;
    wire Hz1;
    wire scoreZero;
    
    debouncer debouncer1(.clk(clk), .button(sw[0]), .button_res(dbsw[0]));
    debouncer debouncer2(.clk(clk), .button(sw[1]), .button_res(dbsw[1]));
    debouncer debouncer3(.clk(clk), .button(sw[2]), .button_res(dbsw[2]));
    debouncer debouncer4(.clk(clk), .button(sw[3]), .button_res(dbsw[3]));
    debouncer debouncer5(.clk(clk), .button(reset), .button_res(rst_state));
    
    ourClk ourClk(.clk(clk),.Hz1(Hz1));
    counter counter(.clk(clk), .clk1Hz(Hz1), .rst(rst_state), .seconds(seconds), .scoreZero(scoreZero));
    
//    reg [10:0] counter = 0;
    /*
    vga vga(
        .dclk(clk), .clr(0), 
        .sw1(dbsw[3]), .sw2(dbsw[2]),.sw3(dbsw[1]),.sw4(dbsw[0]),
        .hsync(tmph), .vsync(tmpv),
        .red(vgaRed), .green(vgaGreen), .blue(vgaBlue),
        .an(tmpAn), .seg(tmpSeg)
    );*/
//    always @ (posedge clk) begin
//        counter <= counter + 1;
//        if(counter == 100) begin
//            counter <= 0;
//            $display("%b, %b,", an, seg);
//        end
//        //$display("TMP an, seg, %b, %b", tmpAn, tmpSeg);
//        //$display("an, seg, %b, %b", an, seg);
//    end
    newvga newvga(
        .seconds(seconds),
        .scoreZero(scoreZero),
        .clk(clk), .reset(rst_state),
        .sw1(dbsw[3]), .sw2(dbsw[2]),.sw3(dbsw[1]),.sw4(dbsw[0]),
        .Hsync(tmph), .Vsync(tmpv),
        .vgaRed(vgaRed), .vgaGreen(vgaGreen), .vgaBlue(vgaBlue),
        .an(tmpAn), .seg(tmpSeg)
    );

    assign Hsync = tmph;
    assign Vsync = tmpv;
    assign an = tmpAn;
    assign seg = tmpSeg;
 

endmodule
