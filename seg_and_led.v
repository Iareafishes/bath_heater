//延迟动作(开机2s内，部分模式切换后一定时间内)状态下数码管和led灯的控制
module seg_and_led(
	input clk,
	input clk_1kHz,
	input rst,
	input [3:0] mode_cur,
	input [1:0] on_st,
	input [31:0] cnt,
	input key_led,					//照明开关

	output reg [7:0] seg_array,
	output reg [6:0] seg_data,
	output reg [15:0] led
);
	reg flag = 1'b0;
	reg [10:0] cnt_2Hz = 11'b0;
	initial begin
	led = 16'h0;
	seg_array = 8'h0;
	seg_data = 7'h0;
	end
	
	always @(posedge clk_1kHz or posedge rst) begin
	if(rst)
	cnt_2Hz <= 1'b0;
	else if(cnt_2Hz < 11'h7cf && on_st == 2'b01)
	cnt_2Hz <= cnt_2Hz + 1'b1;
	else
	cnt_2Hz <= 1'b0;
	end
	//led灯控制
	always @(posedge clk or posedge rst) begin
	if(rst) begin
	flag <= 1'b0;
	led <= 16'h0;
	end
	else if(on_st == 2'b01) begin
		if((cnt_2Hz >= 11'h0 && cnt_2Hz <= 11'h1f3)||(cnt_2Hz >= 11'h3e8 && cnt_2Hz <= 11'h5db)) begin 
		led <= 16'hffff;
		end
		else if((cnt_2Hz >= 11'h1f4 && cnt_2Hz <= 11'h3e7)||(cnt_2Hz >= 11'h5dc && cnt_2Hz <= 11'h7cf)) begin
		led <= 16'h0;
		end
	end
	else if(on_st == 2'b10) begin
	if(key_led)
		flag <= ~flag;
	else if(flag == 1'b1) 
		led <= 16'h40;
	else if(flag == 1'b0)
		led <= 16'h0;
	end
	else if(on_st == 2'b00) begin
	led <= 16'h0;
	flag <= 1'b0;
	end
	end
	
	//数码管控制
	always @(posedge clk or posedge rst) begin
	if(rst) begin
	seg_data <= 7'b0;
	seg_array <= 8'b0;
	end
	else if(on_st == 2'b01) begin
		if((cnt_2Hz >= 11'h0 && cnt_2Hz <= 11'h1f3)||(cnt_2Hz >= 11'h3e8 && cnt_2Hz <= 11'h5db)) begin 
		seg_data <= 7'h7f;
		end
		else if((cnt_2Hz >= 11'h1f4 && cnt_2Hz <= 11'h3e7)||(cnt_2Hz >= 11'h5dc && cnt_2Hz <= 11'h7cf)) begin
		seg_data <= 7'h0;
		end
	seg_array <= 8'h0;
	end
	else if(on_st == 2'b10) begin
	//不在计时状态下,数码管熄灭
		if(cnt == 1'h0) begin
		seg_data <= 7'b0;
		seg_array <= 8'b0;
		end
		else if(cnt > 1'h0 && cnt < 32'd4999_9999) begin
		seg_data <= (mode_cur == 4'b0010)? 7'h5b : 7'h66;	//在风暖模式下，第一秒内显示2;在强暖模式下第一秒显示4
		seg_array <= 8'b11011111;
		end
		else if(cnt >= 32'd5000_0000 && cnt < 32'd9999_9999) begin
		seg_data <= (mode_cur == 4'b0010)? 7'h06 : 7'h4f;	//在强暖模式下，第二秒内显示1;在强暖模式下第二秒显示3
		seg_array <= 8'b11011111;
		end
		else if(cnt >= 32'd10000_0000 && cnt < 32'd14999_9999) begin
		seg_data <= 7'h5b;
		seg_array <= 8'b11011111;
		end
		else if(cnt >= 32'd15000_0000 && cnt < 32'd19999_9999) begin
		seg_data <= 7'h06;
		seg_array <= 8'b11011111;
		end
	end
	else begin
	seg_data <= 7'b0;
	seg_array <= 8'b0;
	end
	end

endmodule