`timescale 1ns/1ps
`include "../../RTL/WATCHDOG.v"

module tb_wdt;

//declare port
reg		pclk,sclk,pwrite,psel,pena,rst,crst,checkclock,old_sel,old_ena;
reg	[7:0]	paddr;
reg	[31:0]	pwdata;
reg	[46:0]	check;
reg	[46:0]	mem [0:8191];

wire		pready,sreset,isr;
wire	[31:0]	prdata;

integer			i,j;

//connect signal
WATCHDOG watchdog_1(.pclk(pclk),.sclk(sclk),.pwrite(pwrite),.psel(psel),
			.pena(pena),.paddr(paddr),.pwdata(pwdata),
		.pready(pready),.prdata(prdata),.rst(rst),.crst(crst),.sreset(sreset)
		,.isr(isr));

//create PCLK
always
begin
#0      pclk = 0;
#25     pclk = 1;
#25;
end

//create SCLK
always
begin
#0      sclk = 0;
#12.5   sclk = 1;
#12.5;
end

//restart ICR counter
task restart;
#0		crst  = 1;
#1		crst  = 0;
#1		crst  = 1;
endtask


initial
begin
#0      rst = 1;
	crst = 1;
#25     rst = 0;
	crst = 0;
#25     rst = 1;
	crst =1;
//$readmemb("input1.txt",mem);
//for (i=0;i<8192;i++)
$readmemb("input2.txt",mem);
for (i=0;i<8;i++)
begin
	$display("testcase number %d is in processing",i);
	check = mem[i];
	for (j=0;j<3;j++)
	begin
#10;
	psel = check[2*j+32];
	pena = check[2*j+33];
	pwrite = check[46];
	paddr = check[45:38];
	pwdata = check[31:0];
	if (paddr == 8'h00)
		checkclock = pwdata[2];
	@(posedge pclk);
	if ({old_sel,old_ena,psel,pena} == 4'b1100)
	begin
	#25 restart;
	if (checkclock == 1'b1)
		#2500000;
	else 
		#5000000;
	end
	old_sel = psel;
	old_ena = pena;
	end
	$display("testcase number %d is done",i);
end
#100;
$finish;
end

initial
begin
$vcdplusfile("tb_WDT.vpd");
$vcdpluson();
end

endmodule
