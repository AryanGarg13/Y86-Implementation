module reg_M(clk,M_stat,M_icode,M_valE,M_valA,M_Cnd,M_dstE,M_dstM,E_stat,E_icode,e_valE,E_valA,e_dstE,E_dstM,e_cnd,M_bubble);

input clk;
input [1:0] E_stat;
input [3:0] E_icode,e_dstE,E_dstM;    
input e_cnd;
input signed [63:0] e_valE,E_valA;
input M_bubble;
output reg [1:0] M_stat=0;
output reg M_Cnd;
output reg [3:0] M_icode,M_dstE,M_dstM;
output reg signed [63:0] M_valE,M_valA;

always @(posedge clk) begin
    if(!M_bubble)begin
    M_stat<=E_stat;
    M_icode<=E_icode;
    M_valE<=e_valE;
    M_valA<=E_valA;
    M_dstE<=e_dstE;
    M_dstM<=E_dstM;
    M_Cnd <= e_cnd;
    end
    else begin
        M_icode<=1;
    end
end

endmodule