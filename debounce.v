module debounce (
	input clk,
   input rst,
   input [4:0] key_in,         //输入的按键					
	output [4:0] key_out        //输出按键值
);
 
   reg [4:0] key_now_pre = 5'b11111;         //定义一个寄存器型变量存储上一个触发时的按键值
   reg [4:0] key_now = 5'b11111;              //定义一个寄存器变量储存储当前时刻触发的按键值
   wire [4:0] key_edge;           //检测到按键由高到低变化是产生一个高脉冲
 
   always @(posedge clk or posedge rst) begin
		if (rst) begin
			key_now <= {5{1'b1}};
			key_now_pre <= {5{1'b1}};
		end
      else begin
			key_now <= key_in;         //将当前时刻按键值记录
         key_now_pre <= key_now;    //非阻塞赋值，由于always块结束时key_now才被赋值，此时key_now_pre记录下的是上一个时钟周期的按键值
      end    
	end
		
	assign key_edge = (~key_now_pre) & (key_now);//脉冲边沿检测。当key检测到下降沿时，key_edge产生一个时钟周期的高电平
 
   reg [19:0] cnt;

	//从key下降为低电平开始，计数20ms的延迟
	always @(posedge clk or posedge rst) begin
		if(rst)
			cnt <= 20'h0;
		else if(key_edge)
         cnt <= 20'h0;
      else
         cnt <= cnt + 1'd1;
      end  
 
	reg [4:0] key_new_pre;	//延时后检测电平寄存器变量
   reg [4:0] key_new;                    
 
	//延时后检测key，如果按键状态变低产生一个时钟的高脉冲。如果按键状态是高的话说明按键无效
   always @(posedge clk or posedge rst)begin
		if (rst)
			key_new <= {5{1'b1}};
      else if (cnt == 20'hf423f)
         key_new <= key_in;  
      end
		
   always @(posedge clk or posedge rst) begin
		if (rst)
			key_new_pre <= 1'h1;
      else                   
         key_new_pre <= key_new;             
      end      
	assign key_out = key_new_pre & (~key_new);
endmodule