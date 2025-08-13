`timescale 1ns / 1ps



module UART_Tx(input clk,
                input rst,
                input tx_st,
                input [7:0]tx_data,
                output tx_busy,
                output tx_serial
    );
    
    parameter baudrate=115200,clk_freq=50_000_000;
    parameter clk_perbit=clk_freq/baudrate;
    parameter idle=0, start=1, transfer=2, stop=3;
    reg [1:0]state;
    reg [15:0]count;
    reg [3:0]bit_count;
	reg [7:0]tx_reg;

	
	
	
	
	
    
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            state<=idle;
			count<=0;
			bit_count<=0;
			tx_reg<=0;

		end
        else begin
			case(state)
				idle:begin
					count<=0;
					bit_count<=0;
					state<=(tx_st==1)?start:idle;					
				end
				start:begin
					tx_reg<=tx_data;
					if(count<clk_perbit-1)
						count<=count+1;
					else begin
						count<=0;
						state<=transfer;
	
					end

				end
				transfer:begin

					if(count<clk_perbit-1)
						count<=count+1;
					else begin
						count<=0;
						if(bit_count<7)
							bit_count<=bit_count+1;
						else begin
							bit_count<=0;
							state<=stop;
						end
					end
				end
				stop:begin
					if(count<clk_perbit-1)
						count<=count+1;
					else begin
						count<=0;
						state<=idle;
					end

				end
			endcase
		end
	end
	

	assign tx_busy=(~(state==idle))&(~rst);
	assign tx_serial=(state==start)?0:((state==transfer)?tx_reg[bit_count]:1);
     
    
endmodule
