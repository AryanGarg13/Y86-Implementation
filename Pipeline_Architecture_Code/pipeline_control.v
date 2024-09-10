module pipeline_control(D_icode,d_srcA,d_srcB,E_icode,E_dstM,e_cnd,M_icode,m_stat,W_stat,F_stall,D_stall,D_bubble,E_bubble,M_bubble,W_stall,set_cc);
    input [3:0] D_icode,d_srcA,d_srcB,E_icode,E_dstM,M_icode;
    input e_cnd;
    input [1:0] m_stat,W_stat;
    output reg F_stall,D_stall,D_bubble,E_bubble,M_bubble,W_stall,set_cc;
    initial begin
        F_stall = 0;
        D_stall = 0;
        D_bubble = 0;
        E_bubble = 0;
        M_bubble = 0;
        W_stall = 0;
        set_cc = 0;
    end
    
    always @* begin
        F_stall = 0;
        D_stall = 0;
        D_bubble = 0;
        E_bubble = 0;
        M_bubble = 0;
        W_stall = 0;
        set_cc = 0;
        if(((E_icode == 4'b0101 || E_icode == 4'b1011) && (E_dstM == d_srcA || E_dstM == d_srcB)) || D_icode == 4'b1001 || E_icode == 4'b1001 || M_icode == 4'b1001)begin
            F_stall<=1;
        end

        if(((E_icode == 4'b0101 || E_icode == 4'b1011) && (E_dstM == d_srcA || E_dstM == d_srcB)))begin
            D_stall<=1;
        end

        if((E_icode == 4'b0111 && !e_cnd) || (!((E_icode == 4'b0101 || E_icode == 4'b1011) && (E_dstM == d_srcA || E_dstM == d_srcB) && !(E_dstM==4'b1111))  && (D_icode == 4'b1001 || E_icode == 4'b1001 || M_icode == 4'b1001)))begin
            // $display("1,%b\n",(E_icode == 4'b0111 && !e_cnd));
            // $display("2,%b\n",(!((E_icode == 4'b0101 || E_icode == 4'b1011) && (E_dstM == d_srcA || E_dstM == d_srcB) && !(E_dstM==4'b1111))  && (D_icode == 4'b1001 || E_icode == 4'b1001 || M_icode == 4'b1001)));
            // $display("e_cnd=%d \n",e_cnd);
            // $display("3,%b\n",(E_icode == 4'b0111 && !e_cnd));
            D_bubble<=1;
        end

        if((E_icode == 4'b0111 && !e_cnd) || ((E_icode == 4'b0101 || E_icode == 4'b1011) && (E_dstM == d_srcA || E_dstM == d_srcB)))begin
            E_bubble<=1;
        end

        if(m_stat!=0 || W_stat!=0)begin
            M_bubble<=1;
        end

        if(W_stat!=0)begin
            W_stall<=1;
        end

        if(E_icode==4'b0110 && m_stat==0 && W_stat ==0)begin
            set_cc<=1;
        end

    end

endmodule