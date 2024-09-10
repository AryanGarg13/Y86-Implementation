module reg_E(clk,E_stat,E_icode,E_ifun,E_valC,E_valA,E_valB,E_srcA,E_srcB,E_dstE,E_dstM,D_stat,D_icode,D_ifun,D_valC,d_valA,d_valB,d_srcA,d_srcB,w_dstE,w_dstM,E_bubble);

input clk;
input [1:0] D_stat;
input [3:0] D_icode,D_ifun;
input [3:0] d_srcA,d_srcB,w_dstE,w_dstM;
input E_bubble;
input signed [63:0] D_valC,d_valA,d_valB;
output reg [1:0] E_stat;
output reg [3:0] E_icode,E_ifun;
output reg [3:0] E_srcA,E_srcB,E_dstE,E_dstM;
output reg signed [63:0] E_valC,E_valA,E_valB;

always @(posedge clk) begin
    if(!E_bubble)begin
    E_stat<=D_stat;
    E_icode<=D_icode;
    E_ifun<=D_ifun;
    // E_rA<=d_rA;
    // E_rB<=d_rB;
    E_valC<=D_valC;
    E_valA<=d_valA;
    E_valB<=d_valB;
    E_dstE<=w_dstE;
    E_dstM<=w_dstM;
    E_srcA<=d_srcA;
    E_srcB<=d_srcB;
    end
    else begin
        E_icode <= 1;
        E_ifun <= 0;
    end
end

endmodule