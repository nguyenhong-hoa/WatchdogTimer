class cinput;
	randc bit [12:0] datafirst;
	constraint data_range {datafirst inside {[0:8191]};}

endclass

module inputfile;

reg	[12:0]	datafirst;
reg	[46:0]	dataout,temp=1;
integer		i,f;
initial
begin
        f = $fopen("input.txt","w");
end

initial
begin
cinput obj = new;
for (i=0;i<8192;i++)
begin
	dataout = 0;
	obj.randomize();
	datafirst = obj.datafirst;
	dataout[46] = datafirst[12];
	if (datafirst[11] == 1'b0)
		dataout[45:38]=8'h00;
	else
		dataout[45:38]=8'h04;
		
	dataout[37:32]=datafirst[10:5];
	
	if ((datafirst[4] == 1'b0) & (datafirst[12] == 1'b1) & (datafirst[11]==1'b0))
		begin
		dataout[3:0]	= datafirst[3:0];
		dataout[31:24]=8'h16;	
		end
		
	if ((datafirst[4] == 1'b1) & (datafirst[12] == 1'b1) & (datafirst[11]==1'b0))
		begin
		dataout[3:0]	= datafirst[3:0];
		dataout[31:24]	=	8'hA5;
		end
		
	if ((datafirst[12] == 1'b1) & (datafirst[11]==1'b1))
		dataout[31:0] = 32'h186A0;
		
	if (~(temp == dataout))
		$fwrite(f,"%b\n",dataout);
		
	temp = dataout;
end
end

endmodule
