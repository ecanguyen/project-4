`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2023 01:03:36 PM
// Design Name: 
// Module Name: testdb
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


module debouncer(
    input clk,
    input button,
    output button_res
    );
    
    reg button_res_state = 0;
    // assign button_res = button_res_state;
    
    reg [1:0] counter;
    reg [10:0] counter2;
    always @(posedge clk) begin
        if(button == 0) begin
            counter[1] <= counter[0];
            counter[0] <= 0;
            counter2 <= 0;
        end else begin
            counter2 = counter2 + 1;
            if(counter2 > 1000) begin
                counter[1] <= counter[0];
                counter[0] <= 1;
                counter2 <= 1001;
            end else begin
                counter[1] <= counter[0];
                counter[0] <= 0;
            end
        end
        if(counter[0] == 1 && counter[1] == 0) begin
            button_res_state <= 1;
        end else begin
            button_res_state <= 0;
        end
    end

    assign button_res = button_res_state;
endmodule