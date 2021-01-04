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
