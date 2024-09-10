module reg_W(clk,W_stat,W_icode,W_valE,W_valM,W_dstE,W_dstM,m_stat,M_icode,M_valE,m_valM,M_dstE,M_dstM,W_stall);

input clk;
input [1:0] m_stat;
input [3:0] M_icode,M_dstM,M_dstE;
input signed [63:0] M_valE,m_valM;
output reg [1:0] W_stat=0;
output reg [3:0] W_icode,W_dstM,W_dstE;
output reg signed [63:0] W_valE,W_valM;
input W_stall;

always @(posedge clk) begin
    if(!W_stall)begin
    W_stat<=m_stat;
    W_icode<=M_icode;
    W_valE<=M_valE;
    W_valM<=m_valM;
    W_dstE<=M_dstE;
    W_dstM<=M_dstM;
    end
end

endmodule