module WDT_logic(pclk,sclk,cr1in,cr2,icr,cr1out,sreset,isr,clk);

input	[31:0]	cr1in,cr2,icr;
input		pclk,sclk;
output		cr1out;
output		sreset,isr,clk;

assign clk = (~cr1in[2])&pclk | cr1in[2]&sclk;

assign cr1out = (cr2==icr);

assign ena = cr1in[3] & cr1in[0];

assign sreset 	 = ena & ~(cr1in[1]);
assign isr	 = ena & cr1in[1];

endmodule
