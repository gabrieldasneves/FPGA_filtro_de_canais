`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2019 16:53:43
// Design Name: 
// Module Name: rgb2gray
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


module rgb2gray(
    input i_clk,
    input i_rst,

	input [11:0] i_rgb,
	output reg [11:0] o_gray
    );
	always @(posedge i_clk)
	begin
	   if (i_rst)  // reset to start of frame
       begin
           o_gray <= 0;
       end
       else
	   begin
	       o_gray <= i_rgb[11:8] + i_rgb[11:8] + i_rgb[11:8];
	   end
	end
endmodule
