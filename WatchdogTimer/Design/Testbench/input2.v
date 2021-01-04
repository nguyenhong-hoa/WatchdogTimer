module inputfile;

reg	[46:0]	dataout;
integer		f;

initial
begin
        f = $fopen("input2.txt","w");
end

initial
begin
//write on addr x00 SEL,ENA = 00 10 11, PWD = 8'A5 , count2,SRESET 
dataout= 47'B1_0000_0000_110100_1010_0101_0000000000000000000_00101;
$fwrite(f,"%b\n",dataout);
//write on addr x04 SEL,ENA 00 10 11, DATA = 32'h186A0
dataout= 47'B1_0000_0100_110100_000000000000_0001_1000_0110_1010_0000;
$fwrite(f,"%b\n",dataout);
//write on addr x00 SEL,ENA = 00 10 11, PWD = 8'A5 , count2,ISR 
dataout= 47'B1_0000_0000_110100_1010_0101_0000_000000000000000_00111;
$fwrite(f,"%b\n",dataout);
//write on addr x00 SEL,ENA = 00 10 11, PWD = 8'A5 , count1,SRESET 
dataout= 47'B1_0000_0000_110100_1010_0101_0000000000000000000_00001;
$fwrite(f,"%b\n",dataout);
//write on addr x00 SEL,ENA = 00 10 11, PWD = 8'A5 , count1,ISR 
dataout= 47'B1_0000_0000_110100_1010_0101_0000000000000000000_00011;
$fwrite(f,"%b\n",dataout);
//read on addr x00 SEL,ENA = 00 10 11
dataout= 47'B0_0000_0000_110100_0000_0000_0000000000000000000_00000;
$fwrite(f,"%b\n",dataout);
//read on addr x04 SEL,ENA = 00 10 11
dataout= 47'B0_0000_0100_110100_0000_0000_0000000000000000000_00000;
$fwrite(f,"%b\n",dataout);
end

endmodule