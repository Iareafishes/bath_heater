module row_scan(
	input clk,
	input rst,
	input [1:0] on_st,
	output reg [7:0] led_row
);	
	reg [2:0] cnt;
	
	initial begin
	led_row = 8'h0;
	cnt = 3'b0;
	end

	always @(posedge clk or posedge rst) begin
	if(rst)
		cnt <= 3'b0;
	else 
		cnt <= cnt + 1'b1;
	end
	
	//点阵逐行扫描
	always @(posedge clk or posedge rst)	begin
	if(rst)
		led_row <= 8'b0000000;
	else if(on_st)
		begin
		case(cnt)
		3'b000: led_row <= 8'b11111110;
		3'b001: led_row <= 8'b11111101;
		3'b010: led_row <= 8'b11111011;
		3'b011: led_row <= 8'b11110111;
		3'b100: led_row <= 8'b11101111;
		3'b101: led_row <= 8'b11011111;
		3'b110: led_row <= 8'b10111111;
		3'b111: led_row <= 8'b01111111;
		endcase
		end
	end
endmodule