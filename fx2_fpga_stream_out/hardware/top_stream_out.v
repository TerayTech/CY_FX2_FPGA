module top_stream_out(sys_clk_50M,
                      rst_n,
                      led,
                      rx_trigger,
					  
					  fx2_fdata,//fx2 inputs
					  fx2_flagb,
					  fx2_flagc,
					  fx2_ifclk,

					  fx2_faddr,//fx2 outputs
					  fx2_sloe,
					  fx2_slwr,
					  fx2_slrd,
					  fx2_pkt_end,
					  fx2_slcs,

					  data_out,//main data output
					  data_valid
					  );
    
    //sys inputs
    input sys_clk_50M, rst_n, rx_trigger;
    
    //sys output
    output [7:0] led;
    
    //cyusb fx2
    input [15:0]fx2_fdata;
    input fx2_flagb;
    input fx2_flagc;
    input fx2_ifclk;
	 wire fx2_ifclk_buf;
    buf B1 (fx2_ifclk_buf,fx2_ifclk);
	 
    output [1:0]fx2_faddr;
    output fx2_sloe;
    output fx2_slwr;
    output fx2_slrd;
    output fx2_pkt_end;
    output fx2_slcs;
    
    output [15:0] data_out;
    output data_valid;

	wire pll_clk_100M;
    
    //led assignment
    assign led [7]   = fx2_slrd;
    assign led [6]   = fx2_slwr;
    assign led [5]   = fx2_sloe;
    assign led [4]   = fx2_flagc;
    assign led [3]   = fx2_flagb;
    assign led [2:0] = 3'b111;
    
    usb_stream_out stream_inst1(
    .fx2_fdata(fx2_fdata),
    .fx2_faddr(fx2_faddr),
    .fx2_slrd(fx2_slrd),
    .fx2_slwr(fx2_slwr),
    .fx2_sloe(fx2_sloe),
    .fx2_flagc(fx2_flagc),
    .fx2_flagb(fx2_flagb),
    .fx2_ifclk(fx2_ifclk_buf),
    .fx2_pkt_end(fx2_pkt_end),
    .fx2_slcs(fx2_slcs),
    .reset_n(rst_n),
    .data_out(data_out),
    .data_valid(data_valid),
    .source_ready(~rx_trigger)
    );

	pll_ip	pll_ip_inst (
	.areset ( ~rst_n ),
	.inclk0 ( sys_clk_50M ),
	.c0 ( pll_clk_100M )
	);
	
endmodule