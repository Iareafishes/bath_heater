module clk_div(
	input clk_in,
	input rst,
	output clk_out
);
	parameter width = 1'b1;
	parameter n = 2;			//分频系数，n不能大于2^width，否则计数会溢出
	reg [width-1:0] cnt;		//计数器
	reg clk_d;					//寄存器记录当前输出电平
	
	initial
	begin
		cnt = 0;
		clk_d = 0;
	end
	always @(posedge clk_in or posedge rst)
	begin
		if(rst)
			cnt <= 0;
		else if(cnt == n/2 - 1) //当计数器经过半个设定周期，翻转输出电平
			begin
			cnt <= 0;
			clk_d <= ~clk_d;	//计数器置0时，输出时钟翻转
			end
		else
			cnt <= cnt + 1'b1;
	end
	
	assign clk_out = clk_d;
	
endmodule