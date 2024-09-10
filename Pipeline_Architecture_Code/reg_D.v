module reg_D(clk,D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,f_stat,f_icode,f_ifun,f_rA,f_rB,f_valC,f_valP,D_stall,D_bubble);

input clk;
input [1:0] f_stat;
input [3:0] f_icode,f_ifun;
input [3:0] f_rA,f_rB;
input signed [63:0] f_valC,f_valP;
output reg [1:0] D_stat=0;
output reg [3:0] D_icode,D_ifun;
output reg [3:0] D_rA,D_rB;
output reg signed [63:0] D_valC,D_valP;
input D_stall,D_bubble;

initial begin
    D_stat<=0;
end

always @(posedge clk) begin
    if(!D_stall && !D_bubble)begin
        D_icode<=f_icode;
        D_ifun<=f_ifun;
        D_rA<=f_rA;
        D_rB <= f_rB;
        D_valC<=f_valC;
        D_valP<=f_valP;
        D_stat<=f_stat;
    end
    else if(D_bubble && !D_stall)begin
        D_icode <= 4'b1;
        D_ifun <= 4'b0;
    end

end

endmodule