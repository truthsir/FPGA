module tx2pc(CLK,RSTn,TX2PC_En,TX2PC_Done,TX2PC_Data,TX_Done_Sig,TX_En_Sig,TX_Data);
input CLK,RSTn;
input [39:0]TX2PC_Data;
input TX2PC_En;
output TX2PC_Done; 
input TX_Done_Sig;
output TX_En_Sig;
output [7:0]TX_Data;


//这个模块的为了衔接decondev2模块和tx_module模块。
//TX2PC_En为1的时候，开始对数据的发送，TX_Done_Sig 6次上升沿之后，TX2PC_Done置1
//告诉decodev2已经结束，decodev2再使TX2PC_En置0，结束
reg TX_En_Sig;
reg[7:0]TX_Data;
reg TX2PC_Done;
parameter S0=13'b00000000000,S1=13'b00000000001,S2=13'b00000000010,S3=13'b00000000100,S4=13'b00000001000,
          S5=13'b00000010000,S6=13'b00000100000,S7=13'b00001000000,S8=13'b00010000000,S9=13'b00100000000,
          S10=13'b01000000000,S11=13'b10000000000,S12=13'b100000000000,S13=13'b1000000000000;

reg[7:0] R1,R2,R3,R4,R5,R6;			 
			 
reg[12:0]Cstate;
always@(posedge CLK or negedge RSTn)
if(!RSTn) begin
TX_En_Sig<=1'b0;
TX2PC_Done<=1'b0;
TX_Data<=8'd0;
R1<=8'd0;
R2<=8'd0;
R3<=8'd0;
R4<=8'd0;
R5<=8'd0;
R6<=8'd0;
end
else
	case(Cstate)
	S0:if(TX2PC_En) begin TX_Data<=TX2PC_Data[39:32];R1<=TX2PC_Data[39:32];TX2PC_Done<=1'b0;Cstate<=S1;end
			else begin TX2PC_Done<=1'b0;Cstate<=S0;end
	S1:  begin TX_En_Sig<=1'b1; Cstate<=S2;TX2PC_Done<=1'b0; end
	S2:  if(TX_Done_Sig) begin TX_Data<=TX2PC_Data[31:24];R2<=TX2PC_Data[31:24]; TX_En_Sig<=1'b0;Cstate<=S3;end else Cstate<=S2;
	S3:  begin TX_En_Sig<=1'b1; Cstate<=S4; end	
	S4:  if(TX_Done_Sig) begin TX_Data<=TX2PC_Data[23:16];R3<=TX2PC_Data[23:16];TX_En_Sig<=1'b0;Cstate<=S5;end else Cstate<=S4;
	S5:  begin TX_En_Sig<=1'b1; Cstate<=S6; end
	S6:  if(TX_Done_Sig) begin TX_Data<=TX2PC_Data[15:8];R4<=TX2PC_Data[15:8];TX_En_Sig<=1'b0;Cstate<=S7;end else Cstate<=S6;
	S7:  begin TX_En_Sig<=1'b1; Cstate<=S8; end
	S8:  if(TX_Done_Sig) begin TX_Data<=TX2PC_Data[7:0];R5<=TX2PC_Data[7:0];TX_En_Sig<=1'b0;Cstate<=S9;end else Cstate<=S8;
	S9:  begin TX_En_Sig<=1'b1;R6<=R1+R2+R3+R4+R5; Cstate<=S10; end
	S10: if(TX_Done_Sig) begin TX_Data<=~R6+1'b1; TX_En_Sig<=1'b0;Cstate<=S11;TX2PC_Done<=1'b1;end else Cstate<=S10;
	S11: begin TX_En_Sig<=1'b1; Cstate<=S12;TX2PC_Done<=1'b0; end
	S12: if(TX_Done_Sig) begin TX2PC_Done<=1'b1;TX_En_Sig<=1'b0;Cstate<=S13;end
	S13: begin TX2PC_Done<=1'b0;Cstate<=S0;end
  default: Cstate<=S0;
  endcase


endmodule