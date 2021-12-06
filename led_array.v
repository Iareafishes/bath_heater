module led_array(
	input clk,
	input [3:0] en,			//四个工作模式对应的使能信号
	input [1:0] on_st,
	input rst,
	
	output reg [7:0] rled_col,
	output reg [7:0] gled_col
);
	reg [2:0] cnt;
	reg [10:0] cnt_time;
	
	initial begin
	{rled_col,gled_col} = 16'h0;
	cnt = 3'b000;
	cnt_time = 11'h0;
	end
	
	always @(posedge clk or posedge rst) begin
	if(rst)
	cnt <= 3'b000;
	else 
	cnt <= cnt + 1'b1;
	end
	
	//1ms计时器
	always @(posedge clk or posedge rst) begin
	if(rst)
	cnt_time <= 11'h0;
	else if(cnt_time < 11'h7cf && on_st)
	cnt_time <= cnt_time + 1'b1;
	else 
	cnt_time <= 0;
	end
	
	//四种工作模式动画实现
	always @(posedge clk or posedge rst) begin
	if(rst)	begin
	{rled_col,gled_col} <= 16'h0;
	end
	
	else if(on_st == 2'b01) begin
	if((cnt_time >= 11'h0 && cnt_time <= 11'h1f3)||(cnt_time >= 11'h3e8 && cnt_time <= 11'h5db)) begin 
	rled_col <= 8'b11111111; gled_col <= 8'b00000000;
	end
	else if((cnt_time >= 11'h1f4 && cnt_time <= 11'h3e7)||(cnt_time >= 11'h5dc && cnt_time <= 11'h7cf)) begin
	rled_col <= 8'b00000000; gled_col <= 8'b11111111; end
	end
	
	//开机2s后可进行工作
	else if(on_st == 2'b10) begin
	case(en)
	
	//换气模式动画
	4'b0001: begin
		if( (cnt_time >= 10'h0 && cnt_time <= 11'h1f3) || (cnt_time >= 11'h3e8 && cnt_time <= 11'h5db) )
		begin
		//显示画面1, 时长0.5s
		case(cnt)
		3'b000: begin gled_col <= 8'b10000111; rled_col <= 8'b00000000; end
		3'b001: begin gled_col <= 8'b11000110; rled_col <= 8'b00000000; end
		3'b010: begin gled_col <= 8'b11100100; rled_col <= 8'b00000000; end
		3'b011: begin gled_col <= 8'b00011000; rled_col <= 8'b00000000; end
		3'b100: begin gled_col <= 8'b00011000; rled_col <= 8'b00000000; end
		3'b101: begin gled_col <= 8'b00100111; rled_col <= 8'b00000000; end
		3'b110: begin gled_col <= 8'b01100011; rled_col <= 8'b00000000; end
		3'b111: begin gled_col <= 8'b11100001; rled_col <= 8'b00000000; end
		endcase 
		end
		else if( (cnt_time >= 11'h1f4 && cnt_time <= 11'h3e7) || (cnt_time >= 11'h5dc && cnt_time <= 11'h7cf) ) 
		begin
		//显示画面2 时长0.5s
		case(cnt)
		3'b000: begin gled_col <= 8'b00001000; rled_col <= 8'b00000000; end
		3'b001: begin gled_col <= 8'b00011000; rled_col <= 8'b00000000; end
		3'b010: begin gled_col <= 8'b00001000; rled_col <= 8'b00000000; end
		3'b011: begin gled_col <= 8'b11111010; rled_col <= 8'b00000000; end
		3'b100: begin gled_col <= 8'b01011111; rled_col <= 8'b00000000; end
		3'b101: begin gled_col <= 8'b00010000; rled_col <= 8'b00000000; end
		3'b110: begin gled_col <= 8'b00011000; rled_col <= 8'b00000000; end
		3'b111: begin gled_col <= 8'b00010000; rled_col <= 8'b00000000; end
		endcase
		end
	end
	
	//风暖模式动画
	4'b0010: begin
		if(cnt_time >= 11'h0 && cnt_time <= 11'h1f3) begin
		//显示画面1, 时长0.5s
		case(cnt)
		3'b000: begin rled_col <= 8'b00000111; gled_col <= 8'b11100000; end
		3'b001: begin rled_col <= 8'b00000011; gled_col <= 8'b11000000; end
		3'b010: begin rled_col <= 8'b00000101; gled_col <= 8'b10100000; end
		3'b011: begin rled_col <= 8'b00001000; gled_col <= 8'b00010000; end
		3'b100: begin rled_col <= 8'b00010000; gled_col <= 8'b00001000; end
		3'b101: begin rled_col <= 8'b10100000; gled_col <= 8'b00000101; end
		3'b110: begin rled_col <= 8'b11000000; gled_col <= 8'b00000011; end
		3'b111: begin rled_col <= 8'b11100000; gled_col <= 8'b00000111; end
		endcase
		end
		
		else if(cnt_time >= 11'h1f4 && cnt_time <= 11'h3e7) begin
		//显示画面2 时长0.5s
		case(cnt)
		3'b000: begin rled_col <= 8'b00000000; gled_col <= 8'b00001000; end
		3'b001: begin rled_col <= 8'b00000000; gled_col <= 8'b00011100; end
		3'b010: begin rled_col <= 8'b01000000; gled_col <= 8'b00001000; end
		3'b011: begin rled_col <= 8'b11110010; gled_col <= 8'b00001000; end
		3'b100: begin rled_col <= 8'b01001111; gled_col <= 8'b00010000; end
		3'b101: begin rled_col <= 8'b00000010; gled_col <= 8'b00010000; end
		3'b110: begin rled_col <= 8'b00000000; gled_col <= 8'b00111000; end
		3'b111: begin rled_col <= 8'b00000000; gled_col <= 8'b00010000; end
		endcase
		end
		
		else if(cnt_time >= 11'h3e8 && cnt_time <= 11'h5db) begin
		//显示画面3 时长0.5s
		case(cnt)
		3'b000: begin gled_col <= 8'b00000111; rled_col <= 8'b11100000; end
		3'b001: begin gled_col <= 8'b00000011; rled_col <= 8'b11000000; end
		3'b010: begin gled_col <= 8'b00000101; rled_col <= 8'b10100000; end
		3'b011: begin gled_col <= 8'b00001000; rled_col <= 8'b00010000; end
		3'b100: begin gled_col <= 8'b00010000; rled_col <= 8'b00001000; end
		3'b101: begin gled_col <= 8'b10100000; rled_col <= 8'b00000101; end
		3'b110: begin gled_col <= 8'b11000000; rled_col <= 8'b00000011; end
		3'b111: begin gled_col <= 8'b11100000; rled_col <= 8'b00000111; end
		endcase
		end
		
		else if(cnt_time >= 11'h5dc && cnt_time <= 11'h7cf) begin
		//显示画面4 时长0.5s
		case(cnt)
		3'b000: begin gled_col <= 8'b00000000; rled_col <= 8'b00001000; end
		3'b001: begin gled_col <= 8'b00000000; rled_col <= 8'b00011100; end
		3'b010: begin gled_col <= 8'b01000000; rled_col <= 8'b00001000; end
		3'b011: begin gled_col <= 8'b11110010; rled_col <= 8'b00001000; end
		3'b100: begin gled_col <= 8'b01001111; rled_col <= 8'b00010000; end
		3'b101: begin gled_col <= 8'b00000010; rled_col <= 8'b00010000; end
		3'b110: begin gled_col <= 8'b00000000; rled_col <= 8'b00111000; end
		3'b111: begin gled_col <= 8'b00000000; rled_col <= 8'b00010000; end
		endcase
		end
	end
	
	//强暖模式动画
	4'b0100: begin
		if(cnt_time >= 11'h0 && cnt_time <= 11'h1f3) begin
		//显示画面1, 时长0.5s
		case(cnt)
		3'b000: begin rled_col <= 8'b11100111; gled_col <= 8'b11100000; end
		3'b001: begin rled_col <= 8'b11000011; gled_col <= 8'b11000000; end
		3'b010: begin rled_col <= 8'b10100101; gled_col <= 8'b10100000; end
		3'b011: begin rled_col <= 8'b00011000; gled_col <= 8'b00010000; end
		3'b100: begin rled_col <= 8'b00011000; gled_col <= 8'b00001000; end
		3'b101: begin rled_col <= 8'b10100101; gled_col <= 8'b00000101; end
		3'b110: begin rled_col <= 8'b11000011; gled_col <= 8'b00000011; end
		3'b111: begin rled_col <= 8'b11100111; gled_col <= 8'b00000111; end
		endcase
		end
		else if(cnt_time >= 11'h1f4 && cnt_time <= 11'h3e7) begin
		//显示画面2 时长0.5s
		case(cnt)
		3'b000: begin rled_col <= 8'b00001000; gled_col <= 8'b00001000; end
		3'b001: begin rled_col <= 8'b00011100; gled_col <= 8'b00011100; end
		3'b010: begin rled_col <= 8'b01001000; gled_col <= 8'b00001000; end
		3'b011: begin rled_col <= 8'b11111010; gled_col <= 8'b00001000; end
		3'b100: begin rled_col <= 8'b01011111; gled_col <= 8'b00010000; end
		3'b101: begin rled_col <= 8'b00010010; gled_col <= 8'b00010000; end
		3'b110: begin rled_col <= 8'b00111000; gled_col <= 8'b00111000; end
		3'b111: begin rled_col <= 8'b00010000; gled_col <= 8'b00010000; end
		endcase
		end
		else if(cnt_time >= 11'h3e8 && cnt_time <= 11'h5db) begin
		//显示画面3 时长0.5s
		case(cnt)
		3'b000: begin gled_col <= 8'b00000111; rled_col <= 8'b11100111; end
		3'b001: begin gled_col <= 8'b00000011; rled_col <= 8'b11000011; end
		3'b010: begin gled_col <= 8'b00000101; rled_col <= 8'b10100101; end
		3'b011: begin gled_col <= 8'b00001000; rled_col <= 8'b00011000; end
		3'b100: begin gled_col <= 8'b00010000; rled_col <= 8'b00011000; end
		3'b101: begin gled_col <= 8'b10100000; rled_col <= 8'b10100101; end
		3'b110: begin gled_col <= 8'b11000000; rled_col <= 8'b11000011; end
		3'b111: begin gled_col <= 8'b11100000; rled_col <= 8'b11100111; end
		endcase
		end
		else if(cnt_time >= 11'h5dc && cnt_time <= 11'h7cf) begin
		//显示画面4 时长0.5s
		case(cnt)
		3'b000: begin gled_col <= 8'b00000000; rled_col <= 8'b00001000; end
		3'b001: begin gled_col <= 8'b00000000; rled_col <= 8'b00011100; end
		3'b010: begin gled_col <= 8'b01000000; rled_col <= 8'b01001000; end
		3'b011: begin gled_col <= 8'b11110010; rled_col <= 8'b11111010; end
		3'b100: begin gled_col <= 8'b01001111; rled_col <= 8'b01011111; end
		3'b101: begin gled_col <= 8'b00000010; rled_col <= 8'b00010010; end
		3'b110: begin gled_col <= 8'b00000000; rled_col <= 8'b00111000; end
		3'b111: begin gled_col <= 8'b00000000; rled_col <= 8'b00010000; end
		endcase
		end
	end
	
	//干燥模式动画
	4'b1000: begin
		if(cnt_time >= 11'h0 && cnt_time <= 11'h1f3) begin
		//显示画面1, 时长0.5s
		case(cnt)
		3'b000: begin gled_col <= 8'b10000111; rled_col <= 8'b10000000; end
		3'b001: begin gled_col <= 8'b11000110; rled_col <= 8'b11000000; end
		3'b010: begin gled_col <= 8'b11100100; rled_col <= 8'b11100000; end
		3'b011: begin gled_col <= 8'b00011000; rled_col <= 8'b00010000; end
		3'b100: begin gled_col <= 8'b00011000; rled_col <= 8'b00001000; end
		3'b101: begin gled_col <= 8'b00100111; rled_col <= 8'b00000111; end
		3'b110: begin gled_col <= 8'b01100011; rled_col <= 8'b00000011; end
		3'b111: begin gled_col <= 8'b11100001; rled_col <= 8'b00000001; end
		endcase
		end
		
		else if(cnt_time >= 11'h1f4 && cnt_time <= 11'h3e7) begin
		//显示画面2 时长0.5s
		case(cnt)
		3'b000: begin gled_col <= 8'b00001000; rled_col <= 8'b00001000; end
		3'b001: begin gled_col <= 8'b00011000; rled_col <= 8'b00011000; end
		3'b010: begin gled_col <= 8'b00001000; rled_col <= 8'b00001000; end
		3'b011: begin gled_col <= 8'b11111010; rled_col <= 8'b00001000; end
		3'b100: begin gled_col <= 8'b01011111; rled_col <= 8'b00010000; end
		3'b101: begin gled_col <= 8'b00010000; rled_col <= 8'b00010000; end
		3'b110: begin gled_col <= 8'b00011000; rled_col <= 8'b00011000; end
		3'b111: begin gled_col <= 8'b00010000; rled_col <= 8'b00010000; end
		endcase
		end
		
		else if(cnt_time >= 11'h3e8 && cnt_time <= 11'h5db) begin
		//显示画面3 时长0.5s
		case(cnt)
		3'b000: begin gled_col <= 8'b10000111; rled_col <= 8'b00000111; end
		3'b001: begin gled_col <= 8'b11000110; rled_col <= 8'b00000110; end
		3'b010: begin gled_col <= 8'b11100100; rled_col <= 8'b00000100; end
		3'b011: begin gled_col <= 8'b00011000; rled_col <= 8'b00001000; end
		3'b100: begin gled_col <= 8'b00011000; rled_col <= 8'b00010000; end
		3'b101: begin gled_col <= 8'b00100111; rled_col <= 8'b00100000; end
		3'b110: begin gled_col <= 8'b01100011; rled_col <= 8'b01100000; end
		3'b111: begin gled_col <= 8'b11100001; rled_col <= 8'b11100000; end
		endcase
		end
		
		else if(cnt_time >= 11'h5dc && cnt_time <= 11'h7cf) begin
		//显示画面4 时长0.5s
		case(cnt)
		3'b000: begin gled_col <= 8'b00001000; rled_col <= 8'b00000000; end
		3'b001: begin gled_col <= 8'b00011000; rled_col <= 8'b00000000; end
		3'b010: begin gled_col <= 8'b00001000; rled_col <= 8'b00000000; end
		3'b011: begin gled_col <= 8'b11111010; rled_col <= 8'b11110010; end
		3'b100: begin gled_col <= 8'b01011111; rled_col <= 8'b01001111; end
		3'b101: begin gled_col <= 8'b00010000; rled_col <= 8'b00000000; end
		3'b110: begin gled_col <= 8'b00011000; rled_col <= 8'b00000000; end
		3'b111: begin gled_col <= 8'b00010000; rled_col <= 8'b00000000; end
		endcase
		end
	end
	
	default: {gled_col,rled_col} <= 16'h0;
	endcase
	end
	
	else if(on_st == 2'b00) begin
	{rled_col,gled_col} <= 16'h0;
	end
	end
endmodule