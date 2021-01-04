module APB(rst,pclk,paddr,pwrite,psel,pena,pwdata,
		prdata,dataout,pready,ena00,ena04);

//declare Parameter
parameter IDLE = 2'b00, SETUP = 2'b01, ACCESS = 2'b11;

//declare port
input		rst,pclk,pwrite,psel,pena;
input	[7:0]	paddr;
input	[31:0]	pwdata,dataout;
output			pready,ena00,ena04;
output	[31:0]	prdata;

reg	[1:0]	state,nstate;
reg	[31:0]	prdata;
reg			pready,ena00,ena04;

//update state
always_ff @(posedge pclk or negedge rst)
begin
	if (~rst)
		state <= IDLE;
	else
		state <= nstate;
end

//determine next state
always_comb
begin
case (state)
IDLE:
	begin
	case ({psel,pena})
	2'b10:
		nstate <= SETUP;
	default:	
		nstate <= IDLE;
	endcase
	end
SETUP:
	begin
	case ({psel,pena})
	2'b11:
		nstate <= ACCESS;
	2'b10:	
		nstate <= SETUP;
	default:	
		nstate <= IDLE;
	endcase
	end
ACCESS:
	begin
	case ({psel,pena})
	2'b10:
		nstate <= SETUP;
	2'b11:
		nstate <= ACCESS;
	default:	
		nstate <= IDLE;
	endcase
	end
default:
	nstate <= IDLE;
endcase	
end

//export result
always_comb
begin
case (state)
	SETUP,ACCESS:
		begin
			if ({psel,pena} == 2'b11)
				begin
					pready = 1'b1;
					ena00 = ~(|(paddr));
					ena04 = &({~paddr[7:3],paddr[2],~paddr[1:0]});
					prdata = pwrite?32'b0:dataout;
				end
			else
				begin
					pready = 1'b0;
					ena00 = 1'b0;
					ena04 = 1'b0;
					prdata = 32'b0;
				end
		end
	default:
		begin
			pready = 1'b0;
			ena00 = 1'b0;
			ena04 = 1'b0;
			prdata = 32'b0;
		end
endcase
end
endmodule
[hoanguyen@login02 RTL]$ cat register.v
module register(rst, crst, clk, pwdata, cr1out, pwrite,
		 pclk, ena00, ena04, cr2, icr, dataout, cr1in);

//input and output of register
input		rst,clk,crst,cr1out,ena00,ena04,pclk,pwrite;
input	[31:0]	pwdata;
output	[31:0]	cr2,icr,dataout,cr1in;

logic	[31:0]	icr,dataout,cr2,cr1in;
wire	[31:0]	icr_new;
wire		enacr2,pwd04,pwd2,pwd00,pwd,enacr1;

//update CR1IN register
always_ff @(posedge pclk or negedge rst)
begin
	if (~rst)
		cr1in[31:24] <= 8'h5A;
	else 
		cr1in[31:24] <= enacr1?pwdata[31:24]:cr1in[31:24];
end

always @(posedge pclk or negedge rst)
begin
        if (~rst)
                {cr1in[23:4],cr1in[2:0]} <= 23'b0;
        else 
                {cr1in[23:4],cr1in[2:0]} <= pwd00?{pwdata[23:4],pwdata[2:0]}:{cr1in[23:4],cr1in[2:0]};
end

//define enable for CR1IN register
assign cr1in[3] = cr1out;
assign enacr1 = ena00&pwrite;
assign pwd = ((&({pwdata[31],~pwdata[30],pwdata[29],~pwdata[28],~pwdata[27],pwdata[26],~pwdata[25],pwdata[24]}))===1'B1)?1'B1:1'B0;
assign pwd00 = enacr1 & pwd;

//define enable for CR2 register
assign pwd2 = &({cr1in[31],~cr1in[30],cr1in[29],~cr1in[28],~cr1in[27],cr1in[26],~cr1in[25],cr1in[24]});
assign pwd04 = ena04 & pwd2;
assign enacr2 = pwd04 & pwrite;

//update CR2 register
always @(posedge pclk or negedge rst)
begin
        if (~rst)
                cr2 <= 32'b0;
        else 
                cr2 <= enacr2?pwdata:cr2;
end

//define export
always_comb
begin
	case ({ena04,ena00})
	2'b01:
		dataout = pwrite?32'b0:cr1in;
	2'b10:
		dataout = pwrite?32'b0:cr2;
	default:
		dataout = 32'b0;
	endcase
end

//up counter
assign icr_new = (icr + 1);

always_ff @(posedge clk or negedge crst)
begin
	if ((~crst)|(cr1in[4]))
		icr <= 32'h0;
	else
		icr <= icr_new;
end
endmodule
