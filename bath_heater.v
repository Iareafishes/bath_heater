`timescale 1ns/10ps
module bath_heater(
	input clk,
	input main_sw,						//总开关
	input [4:0] btn,					//5种功能开关
	input rst,							//强制复位开关(测试用)
	
	output [7:0] led_row, 			//led点阵行
	output [7:0] rled_col,			//红色led点阵列
	output [7:0] gled_col,			//绿色led点阵列
	output [7:0] seg_array,			//控制数码管0~7
	output [6:0] seg_data,			//控制单个数码管的显示
	output [15:0] led					//控制led灯
);
	
	wire [4:0] btn_out;								//消抖后的按键
	wire clk_1kHz;										//1kHz时钟分频
	reg [1:0] on_st = 2'b0;							//开机状态，00为关机；01为开机2s内，只有开机动画，动作无效；10为开机2s后，动作有效
	reg [10:0] cnt_on = 11'h0;						//开机2秒计时器
	reg [31:0] cnt = 32'h0;							//倒计时计数器
	reg [3:0] mode;									//工作状态的使能信号
	reg [3:0] btn_reg_in;
	reg [3:0] mode_cur;
	reg [3:0] mode_next;
	
	//总开关
	always @(posedge clk_1kHz or posedge rst) begin
	if(rst)
	cnt_on <= 1'b0;
	else if(main_sw) begin
		if(cnt_on < 11'h7cf) begin		//开机计时未到2s时处于预热状态
		cnt_on <= cnt_on + 1'b1;
		on_st <= 2'b01;
		end
		else if(cnt_on == 11'h7cf)		//计时到2s时切换到工作状态
		on_st <= 2'b10;
	end
	else begin								//总开关断电时进入关机状态，开机计时器清零							
		cnt_on <= 11'h0;	
		on_st <= 2'b00;
		end
	end
	
	always @(posedge clk or posedge rst) begin
	if(rst)
	mode_cur <= 4'b0;
	else if(on_st == 2'b10)
	mode_cur <= mode_next;
	else 
	mode_cur <= 4'b0;
	end
	
	always @(*) begin
	case(mode_cur)
		4'b0000: begin
			case(btn_reg_in)
			4'b0001:	mode_next = 4'b0001;
			4'b0010:	mode_next = 4'b0010;
			4'b0100:	mode_next = 4'b0100;
			4'b1000:	mode_next = 4'b1000;
			default: mode_next = 4'b0000;
			endcase
		end
		4'b0001: begin
			case(btn_reg_in)
			4'b0001: mode_next = 4'b0000;
			4'b0010: mode_next = 4'b0010;
			4'b0100: mode_next = 4'b0100;
			4'b1000: mode_next = 4'b1000;
			default: mode_next = 4'b0001;
			endcase
		end
		4'b0010: begin
			case(btn_reg_in)
			4'b0001:	mode_next = 4'b0001;
			4'b0010:	mode_next = (cnt > 32'd99999999)? 4'b0000 : 4'b0010;
			4'b0100: mode_next = 4'b0100;
			4'b1000:	mode_next = 4'b1000;
			default: mode_next = 4'b0010;
			endcase
		end
			4'b0100: begin
			case(btn_reg_in)
			4'b0001:	mode_next = 4'b0001;
			4'b0010:	mode_next = 4'b0010;
			4'b0100:	mode_next = (cnt > 32'd199999999)? 4'b0000 : 4'b0100;
			4'b1000:	mode_next = 4'b1000;
			default: mode_next = 4'b0100;
			endcase
		end
		4'b1000: begin
			case(btn_reg_in)
			4'b0001:	mode_next = 4'b0001;
			4'b0010:	mode_next = 4'b0010;
			4'b0100:	mode_next = 4'b0100;
			4'b1000:	mode_next = 4'b0000;
			default: mode_next = 4'b1000;
			endcase
		end
		
	default : mode_next = mode_cur;
	endcase
	end
	
	always @(posedge clk or posedge rst) begin
	if(rst) begin
	cnt <= 4'b0;
	btn_reg_in <= 4'b0;
	mode <= 4'b0;
	end
	//当输入按键脉冲，检测按键状态并存储
	else if(btn_out[3:0] && on_st == 2'b10) begin
		case(btn_out[3:0])
		4'b0001,4'b0010,4'b0100,4'b1000: btn_reg_in <= {btn_out[0],btn_out[1],btn_out[2],btn_out[3]};
		default: btn_reg_in <= btn_reg_in;
		endcase
	end
	//当检测到按键输入，改变工作模式
	else if((btn_reg_in || cnt) && on_st == 2'b10) begin
	//通风模式下
	if(mode_cur == 4'b0001) begin 
		//切换至待机
		if(btn_reg_in == 4'b0001) begin
			mode <= 4'b0;
			btn_reg_in <= 4'b0;
		end
		//切换至其他模式
		else begin
			mode <= btn_reg_in;
			btn_reg_in <= 4'b0;
		end
	end
	//风暖模式下
	else if(mode_cur == 4'b0010) begin 
		//切换至待机,2s延迟
		if(btn_reg_in == 4'b0010 || cnt) begin
			if(cnt <= 32'd99999999)
			cnt <= cnt + 1'b1;
			else begin
			mode <= 4'b0;
			btn_reg_in <= 4'b0;
			cnt <= 32'h0;
			end
		end
		//切换至其他模式
		else begin
			mode <= btn_reg_in;
			btn_reg_in <= 4'b0;
		end
	end
	//强暖模式下
	else if(mode_cur == 4'b0100) begin 
		//切换至待机,4s延迟
		if(btn_reg_in == 4'b0100 || cnt) begin
			if(cnt <= 32'd199999999)
			cnt <= cnt + 1'b1;
			else begin
			mode <= 4'b0;
			btn_reg_in <= 4'b0;
			cnt <= 32'h0;
			end
		end
		//切换至其他模式
		else begin
			mode <= btn_reg_in;
			btn_reg_in <= 4'b0;
		end
	end
	//干燥模式下
	else if(mode_cur == 4'b1000) begin 
		//切换至待机
		if(btn_reg_in == 4'b1000) begin
			mode <= 4'b0;
			btn_reg_in <= 4'b0;
		end
		//切换至其他模式
		else begin
			mode <= btn_reg_in;
			btn_reg_in <= 4'b0;
		end
	end
	//待机切换至工作模式
	else if(mode_cur == 4'b0000) begin
		mode <= btn_reg_in;
		btn_reg_in <= 4'b0;
	end
	end
	else if(on_st == 2'b00) begin
		btn_reg_in <= 4'b0;
		mode <= 4'b0;
	end
	end
	
	clk_div #(.width(16), .n(50000)) clk1kHz(.clk_in(clk), .rst(rst), .clk_out(clk_1kHz));
	row_scan u0(.clk(clk_1kHz), .rst(rst), .led_row(led_row), .on_st(on_st));
	debounce d1(.clk(clk), .rst(rst), .key_in(btn), .key_out(btn_out));
	led_array u2(.clk(clk_1kHz), .rst(rst), .en(mode), .on_st(on_st), .rled_col(rled_col), .gled_col(gled_col));
	seg_and_led u3(.clk(clk), .clk_1kHz(clk_1kHz), .rst(rst), .key_led(btn_out[4]), .cnt(cnt), .on_st(on_st), .mode_cur(mode_cur), 
	 .seg_array(seg_array), .seg_data(seg_data), .led(led));

endmodule