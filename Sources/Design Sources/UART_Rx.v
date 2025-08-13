`timescale 1ns / 1ps

module UART_Rx(input clk,
				input rst,
				input rx_serial,
				output reg done,
				output reg[7:0]rx_data
    );
	parameter baudrate=115200, clk_freq=49_500_000;
	parameter clk_perbit=clk_freq/baudrate;
	parameter half_clk = clk_perbit>>1;
	parameter idle=0,start=1,transfer=2,stop=3;
	reg data;
	reg [15:0]count;
	reg [2:0]bit_count;
	reg [7:0]rx_reg;
	reg [1:0]state, next_state;
	
	
	
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			done<=0;
			rx_reg<=0;
			rx_data<=0;
			state<=idle;
		end
		else begin
			case(state)
				idle:begin
					state<=(rx_serial==1)?idle:start;
					done<=0;
					count<=0;
					bit_count<=0;
					rx_reg<=0;
				end
				start:begin
					if(count==half_clk-1)begin
						state<=(rx_serial==0)?transfer:idle;
						count<=0;
					end					
					else
						count<=count+1;
				end
				transfer:begin
					if(count==clk_perbit-1)begin
						count<=0;
						rx_reg[bit_count]<=rx_serial;
						if(bit_count<7)
							bit_count<=bit_count+1;
						else begin
							bit_count<=0;
							state<=stop;
						end
					end else
						count<=count+1;
				end
				stop:begin
					if(count==clk_perbit-1)begin
						if(rx_serial==1)begin
							rx_data<=rx_reg;
							done<=1;
						end
						state<=idle;
					end
					else
						count<=count+1;
				end
			endcase
		end
	end
	
	
	
endmodule
