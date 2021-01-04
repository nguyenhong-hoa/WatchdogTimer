`include "../../RTL/APB.v"
`include "../../RTL/register.v"
`include "../../RTL/WDT_logic.v"

module WATCHDOG(pclk,sclk,pwrite,psel,pena,paddr,pwdata,pready,prdata,rst,crst,sreset,isr);

input			pclk,sclk,pwrite,psel,pena,rst,crst;
input	[7:0]	paddr;
input	[31:0]	pwdata;
output			pready,sreset,isr;
output	[31:0]	prdata;

wire			ena00,ena04,cr1out;
wire	[31:0]	dataout,cr2,icr,cr1in;

//connect module
APB apb_1(.pclk(pclk), .pwrite(pwrite), .psel(psel), .pena(pena), .paddr(paddr), 
	.pwdata(pwdata), .pready(pready), .prdata(prdata), .rst(rst), .ena00(ena00),
	.ena04(ena04), .dataout(dataout));

register register_1(.rst(rst), .crst(crst), .clk(clk), .pwdata(pwdata), .cr1out(cr1out), 
			.pwrite(pwrite), .pclk(pclk), .ena00(ena00), .ena04(ena04), 
			.cr2(cr2), .icr(icr), .dataout(dataout), .cr1in(cr1in));

WDT_logic wdt_logic_1(.pclk(pclk), .sclk(sclk), .cr1in(cr1in), .cr2(cr2), .icr(icr),
	 .cr1out(cr1out), .sreset(sreset), .isr(isr), .clk(clk));
endmodule
