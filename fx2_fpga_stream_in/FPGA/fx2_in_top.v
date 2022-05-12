module fx2_in_top(
	reset_n,
	fx2_fdata, //  FX2型USB2.0芯片的SlaveFIFO的数据线
	fx2_faddr, //  FX2型USB2.0芯片的SlaveFIFO的FIFO地址线
	fx2_slrd,  //  FX2型USB2.0芯片的SlaveFIFO的读控制信号，低电平有效
	fx2_slwr,  //  FX2型USB2.0芯片的SlaveFIFO的写控制信号，低电平有效
	fx2_sloe,  //  FX2型USB2.0芯片的SlaveFIFO的输出使能信号，低电平有效
	fx2_flagc, //  FX2型USB2.0芯片的端点6满标志
	fx2_flagb, //  FX2型USB2.0芯片的端点2空标志
	fx2_ifclk, //  FX2型USB2.0芯片的接口时钟信号
	fx2_pkt_end,	//数据包结束标志信号
	
	tx_trigger
);

	input reset_n;
	output [15:0]fx2_fdata;
	input fx2_flagb;
	input fx2_flagc;
	input fx2_ifclk;
	input tx_trigger;//发送触发器，按钮按下触发

	output [1:0]fx2_faddr;
	output fx2_sloe;
	output fx2_slwr;
	output fx2_slrd;
	output fx2_pkt_end;

	wire slrd_n;
	reg slwr_n;
	wire sloe_n;
	reg slrd_d_n;

	reg [15:0] data_out1;

	parameter stream_in_idle   = 1'b0;
	parameter stream_in_write  = 1'b1;

	reg current_stream_in_state;
	reg next_stream_in_state;

	assign fx2_slwr = slwr_n;
	assign fx2_slrd = slrd_n;
	assign fx2_sloe = sloe_n;
	assign fx2_pkt_end = 1'b1;
	//assign fx2_fdata[15:0] = {data_out1[7:0],data_out1[15:8]};
	assign fx2_fdata = data_out1;
	assign fx2_faddr = 2'b10;

	assign slrd_n = 1;
	assign sloe_n = 1;

	//write control signal generation
	always@(*)begin
		if((current_stream_in_state == stream_in_write) & (fx2_flagc == 1'b1))
			slwr_n <= 1'b0;
		else
			slwr_n <= 1'b1;
	end
		
	//Stream_IN mode state machine 
	always@(posedge fx2_ifclk, negedge reset_n) begin
		if(reset_n == 1'b0)
			current_stream_in_state <= stream_in_idle;
			  else
			current_stream_in_state <= next_stream_in_state;
	end

	//Stream_IN mode state machine combo
	always@(*) begin
		next_stream_in_state = current_stream_in_state;
		case(current_stream_in_state)
			stream_in_idle:begin
				if(fx2_flagc == 1'b1 && tx_trigger == 1'b0)
					next_stream_in_state = stream_in_write;
				else
					next_stream_in_state = stream_in_idle;
			end
			stream_in_write:begin
				if(fx2_flagc == 1'b0 && tx_trigger == 1'b1)
					next_stream_in_state = stream_in_idle;
				else
					next_stream_in_state = stream_in_write;
			end
			default: 
				next_stream_in_state = stream_in_idle;
		endcase
	end

	//data generator counter
	always@(posedge fx2_ifclk, negedge reset_n)begin
		if(reset_n == 1'b0)
			data_out1 <= 16'd0;
		else if(slwr_n == 1'b0)
			data_out1 <= data_out1 + 16'd1;
	end		

endmodule

