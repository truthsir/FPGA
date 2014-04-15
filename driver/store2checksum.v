module store2checksum(CLK,RSTn,RX_Done_Sig,RX_Data,Data);
input CLK,RSTn;
input RX_Done_Sig;
input[7:0]RX_Data;


output [39:0]Data;


parameter S0=14'b00000000000000,S1=14'b00000000000001,S2=14'b00000000000010,S3=14'b00000000000100,
			 S4=14'b00000000001000,S5=14'b00000000010000,S6=14'b00000000100000,S7=14'b00000001000000,
			 S8=14'b00000010000000,S9=14'b00000100000000,S10=14'b00001000000000,S11=14'b00010000000000,S12=14'b00100000000000,S13=14'b01000000000000,S14=14'b10000000000000;

reg [13:0]Cstate;

reg [7:0]R1,R2,R3,R4,R5;
reg [7:0]R6;

reg [39:0]Data_R;
reg [7:0]Sum;
reg[7:0]Checksum;

//假如CRC校验结果不同，Data被置为FFFFFFFFFFFFFFFF；
	  
reg Data_Lock;

always@(posedge CLK or negedge RSTn)
if(!RSTn)
begin
	R1<=8'd0;
	R2<=8'd0;
	R3<=8'd0;
	R4<=8'd0;
	R5<=8'd0;
	R6<=8'd0;
	Data_R<=40'd0;
	Cstate<=S0;
	Sum<=8'd0;
	Checksum<=8'd0;
	Data_Lock<=1'b0;
end
else 
	case(Cstate)
	S0:	if(RX_Done_Sig) begin R1<=RX_Data; Cstate<=S1; end else Cstate<=S0;
	S1:	if(RX_Done_Sig) begin R2<=RX_Data; Cstate<=S2;Data_R<=40'h0;Data_Lock<=1'b0; end else Cstate<=S1;
	S2:	if(RX_Done_Sig) begin R3<=RX_Data; Cstate<=S3; end else Cstate<=S2;
	S3:	if(RX_Done_Sig) begin R4<=RX_Data; Cstate<=S4; end else Cstate<=S3;
	S4:	if(RX_Done_Sig) begin R5<=RX_Data; Cstate<=S5; end else Cstate<=S4;
	S5:	if(RX_Done_Sig) begin R6<=RX_Data; Sum<=R1+R2+R3+R4+R5;Cstate<=S6; end else Cstate<=S5;
	S6:   begin Checksum<=Sum+R6;Cstate<=S7; end
	S7:   Cstate<=S8; 
	S8:   Cstate<=S9;
	S9:   Cstate<=S10;
	S10:  if(Checksum==8'd0)  Cstate<=S11; else if(Checksum!=8'd0)  Cstate<=S12; 
	S11:  begin Data_R<={R1,R2,R3,R4,R5}; Cstate<=S13;end
	S12:  begin Data_R<=Data_R|40'hffffffffff; Cstate<=S13;end
	S13:  begin Data_Lock<=1'b1; Cstate<=S14; end
	S14:  begin Cstate<=S0;end
	default: begin Cstate<=S0; end
	endcase

reg[39:0]Data_RR;	
	
always@(posedge CLK or negedge RSTn)
if(!RSTn)
Data_RR<=40'd0;
else if(Data_Lock==1'b1)
Data_RR<=Data_R;
else
Data_RR<=40'h0;


assign Data=Data_RR;



  

endmodule