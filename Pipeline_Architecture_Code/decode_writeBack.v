module decode_writeBack(clk,D_icode,D_ifun,W_icode,D_valP,D_rA,D_rB,d_srcA,d_srcB,w_dstM,w_dstE,W_valE,W_valM,d_valA,d_valB,D_valC,e_dstE,e_valE,M_dstE,M_valE,M_dstM,m_valM,W_dstE,W_dstM,W_valE,W_valM);

input clk;
input signed [63:0] e_valE,M_valE,m_valM;
input [3:0] e_dstE,M_dstE,M_dstM,W_dstE,W_dstM;
input [3:0] D_icode,D_ifun,W_icode;
input [3:0] D_rA,D_rB;
input signed [63:0] D_valP;
input signed [63:0] W_valE,W_valM,D_valC;

output reg signed [63:0] d_valA,d_valB;

reg signed [63:0] R [0:14];

output reg [3:0] d_srcA,d_srcB,w_dstM,w_dstE;
integer i;

initial begin
    for(i=0;i<15;++i) begin
        R[i]=0;
    end
    $readmemh("./reg.txt",R,0,14);

end

always @ (*) begin

    if(D_icode==4'b0000) begin //instr: halt
        d_srcA<=4'b1111;
        d_srcB<=4'b1111;
    end

    if(D_icode==4'b0001) begin //instr: nop
        d_srcA<=4'b1111;
        d_srcB<=4'b1111;
    end

    if (D_icode==4'b0011) begin //instr: irmovq
        d_srcA<=4'b1111;
        d_srcB<=4'b1111;
    end

    else if (D_icode==4'b0010) begin //instr: cmovq and rrmovq
        d_srcA<=D_rA;
        d_srcB<=4'b1111;
    end

    else if (D_icode==4'b0100) begin //instr: rmmovq
        d_srcA<=D_rA;
        d_srcB<=D_rB;
    end

    else if (D_icode==4'b0101) begin //instr: mrmovq
        d_srcA<=4'b1111;
        d_srcB<=D_rB;
    end

    //CHECK THE DECODE FOR OPq AS WELL
    else if (D_icode==4'b0110) begin //instr: OPq
        d_srcB<=D_rB;
        d_srcA<=D_rA;
    end

    else if (D_icode==4'b1010) begin //instr: pushq
        d_srcA<=D_rA;
        d_srcB<=4;
    end

    else if (D_icode==4'b1011) begin //instr: popq
        d_srcA<=4;
        d_srcB<=4;
    end    

    else if (D_icode==4'b0111) begin //instr: jxx
        d_srcA<=4'b1111;
        d_srcB<=4'b1111;
    end

    else if (D_icode==4'b1000) begin //instr: call
        d_srcA<=4'b1111;
        d_srcB<=4;
    end

    else if (D_icode==4'b1001) begin //instr: ret
        d_srcA<=4;
        d_srcB<=4;
    end

    if(d_srcA!=4'b1111) begin // value in register d_srcA is set as d_valA
        d_valA=R[d_srcA];
    end
    if(d_srcB!=4'b1111) begin // value in register d_srcB is set as d_valB
        d_valB=R[d_srcB];
    end
end

always @* begin

    if(D_icode==4'b0000) begin //instr: halt
        w_dstM<=4'b1111;
        w_dstE<=4'b1111;
    end

    if(D_icode==4'b0001) begin //instr: nop
        w_dstM<=4'b1111;
        w_dstE<=4'b1111;
    end

    if (D_icode==4'b0011) begin //instr: irmovq
        w_dstM<=4'b1111;
        w_dstE<=D_rB;
    end

    else if (D_icode==4'b0010) begin //instr: rrmovq and cmovq
        w_dstM<=4'b1111;
        w_dstE<=D_rB;
    end

    else if (D_icode==4'b0100) begin //instr: rmmovq
        w_dstM<=4'b1111;
        w_dstE<=4'b1111;
    end

    else if (D_icode==4'b0101) begin //instr: mrmovq
        w_dstM<=D_rA;
        w_dstE<=4'b1111;
    end

    else if (D_icode==4'b0110) begin //instr: OPq
        w_dstM<=4'b1111;
        w_dstE<=D_rB;
    end

    else if (D_icode==4'b1010) begin //instr: pushq
        w_dstM<=4'b1111;
        w_dstE<=4;
    end

    else if (D_icode==4'b1011) begin //instr: popq
        w_dstM<=D_rA;
        w_dstE<=4;
    end    

    else if (D_icode==4'b0111) begin //instr: jxx
        w_dstM<=4'b1111;
        w_dstE<=4'b1111;
    end

    else if (D_icode==4'b1000) begin //instr: call
        w_dstM<=4'b1111;
        w_dstE<=4;
    end

    else if (D_icode==4'b1001) begin //instr: ret
        w_dstM<=4'b1111;
        w_dstE<=4;
    end
end

always @ (posedge clk) begin
    if(W_dstE!=4'b1111) begin
        R[W_dstE]=W_valE;
        $writememh("./reg_out.txt",R);
    end
    if(W_dstM!=4'b1111) begin
        R[W_dstM]=W_valM;
        $writememh("./reg_out.txt",R);
        // $writememh("./reg_out.txt",R);
    end
    for(i=0;i<15;++i) begin
        $display("%d",R[i]);
    end
    $display("\n");
end

always @(*) begin
    if(D_icode == 4'b0111 || D_icode == 4'b1000) begin
        d_valA <= D_valP;
    end
    else if(d_srcA == e_dstE) begin
        d_valA <= e_valE;
    end
    else if(d_srcA == M_dstM) begin
        d_valA <= m_valM;
    end
    else if(d_srcA == M_dstE) begin
        d_valA <= M_valE;
    end
    else if(d_srcA == W_dstM) begin
        d_valA <= W_valM;
    end
    else if(d_srcA == W_dstE) begin
        d_valA <= W_valE;
    end
    else begin
        d_valA <= d_valA;
    end
        
    if(d_srcB == e_dstE) begin
        d_valB <= e_valE;
    end
    else if(d_srcB == M_dstM) begin
        d_valB <= m_valM;
    end
    else if(d_srcB == M_dstE) begin
        d_valB <= M_valE;
    end
    else if(d_srcB == W_dstM) begin
        d_valB <= W_valM;
    end
    else if(d_srcB == W_dstE) begin
        d_valB <= W_valE;
    end
    else begin
        d_valB <= d_valB;
    end
end

endmodule
