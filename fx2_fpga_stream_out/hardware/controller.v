module usb_stream_out(
	fx2_fdata, //  FX2型USB2.0芯片的SlaveFIFO的数据线
	fx2_faddr, //  FX2型USB2.0芯片的SlaveFIFO的FIFO地址线
	fx2_slrd,  //  FX2型USB2.0芯片的SlaveFIFO的读控制信号，低电平有效
	fx2_slwr,  //  FX2型USB2.0芯片的SlaveFIFO的写控制信号，低电平有效
	fx2_sloe,  //  FX2型USB2.0芯片的SlaveFIFO的输出使能信号，低电平有效
	fx2_flagc, //  FX2型USB2.0芯片的端点6满标志
	fx2_flagb, //  FX2型USB2.0芯片的端点2空标志
	fx2_ifclk, //  FX2型USB2.0芯片的接口时钟信号
	fx2_pkt_end,	//数据包结束标志信号
	fx2_slcs,
	reset_n,
	data_out,	//经过FPGA接收了的USB数据
	data_valid,	//经过FPGA接收了的USB数据有效标志信号
	source_ready	//外部数据消费者数据接收允许信号，例如FPGA中的缓存FIFO中有足够的空间存储一帧USB数据，则允许从Slave FIFO中去读取数据。
);

input reset_n;
input [15:0]fx2_fdata;
input fx2_flagb;
input fx2_flagc;
input fx2_ifclk;

output [1:0]fx2_faddr;
output fx2_sloe;
output fx2_slwr;
output fx2_slrd;
output fx2_pkt_end;
output fx2_slcs;
	
output reg [15:0] data_out;
output reg data_valid;

input source_ready;

reg slrd_n;
reg slwr_n;
reg sloe_n;

reg [1:0]faddr_n;

parameter [1:0] stream_out_idle       = 2'd0;
parameter [1:0] stream_out_read       = 2'd1;
parameter [1:0] stream_out_wait       = 2'd2;

reg [1:0]current_stream_out_state;
reg [1:0]next_stream_out_state;

assign fx2_slwr = 1;
assign fx2_slrd = slrd_n;
assign fx2_sloe = sloe_n;
assign fx2_faddr = 2'b00;
assign fx2_pkt_end = 1'b1;
assign fx2_slcs = 1'b0;

//将USB数据流输出给其他逻辑
always@(posedge fx2_ifclk)begin
	data_out <= fx2_fdata;
	data_valid <= ~slrd_n;
end


//产生读Slave FIFO数据请求信号
always@(*)begin
	if((current_stream_out_state == stream_out_read) & (fx2_flagb == 1'b1))begin
		slrd_n = 1'b0;
		sloe_n = 1'b0;
	end else begin
		slrd_n = 1'b1;
		sloe_n = 1'b1;
	end
end	

//两段式状态机现态和次态切换
always@(posedge fx2_ifclk, negedge reset_n) begin
	if(reset_n == 1'b0)
		current_stream_out_state <= stream_out_wait;
	else
		current_stream_out_state <= next_stream_out_state;
end

//两段式状态机状态跳转部分
always@(*) begin
	next_stream_out_state = current_stream_out_state;
	case(current_stream_out_state)
		stream_out_wait:begin	//等待数据使用逻辑允许从USB中读取新的数据
			if(source_ready)
				next_stream_out_state = stream_out_idle;
			else
				next_stream_out_state = stream_out_wait;
		end
		stream_out_idle:begin	//等待FX2的Slave FIFO中端点2非空
			if(fx2_flagb == 1'b1)
				next_stream_out_state = stream_out_read;
			else
				next_stream_out_state = stream_out_idle;
		end
		stream_out_read:begin	//从端点2中读取数据
			if(fx2_flagb == 1'b0)
				next_stream_out_state = stream_out_wait;
			else
				next_stream_out_state = stream_out_read;
		end
		default: 
			next_stream_out_state = stream_out_wait;
	endcase		
end

endmodule
