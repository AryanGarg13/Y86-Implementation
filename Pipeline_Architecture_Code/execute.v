module execute(clk,E_icode,E_ifun,E_valA,E_valB,E_valC,E_dstE,e_valE,e_cnd,e_dstE,m_stat,W_stat,set_cc);
    input clk;
    input [1:0] m_stat,W_stat;
    input [3:0] E_icode,E_ifun;
    input signed [63:0] E_valA,E_valB,E_valC;
    output reg signed [63:0] e_valE;
    reg sf,zf,of;
    output reg e_cnd;
    input [3:0] E_dstE;
    output reg [3:0] e_dstE;
    
    input set_cc;
    reg cc [0:2];
    // wire cnd;
    integer i;

    initial begin
        // $readmemh("./condition_codes.txt",cc);
        for(i=0;i<3;++i) begin
            cc[i]=0;
        end
        zf=cc[0];
        sf=cc[1];
        of=cc[2];
    end
    wire signed [63:0] vale;
    wire signed [63:0] rme,pushe,pope;
    wire over,crme,cpushe,cpope;
    
    ALU DUT(E_ifun[1:0],E_valA,E_valB,vale,over);
    ALU HUT(2'b00,E_valC,E_valB,rme,crme);
    ALU IUT(2'b01,E_valB,64'b0001,pushe,cpushe);
    ALU JUT(2'b00,64'b0001,E_valB,pope,cpope);

    always @* begin

        // set_cc=0;
        e_cnd=0;

        if(E_icode == 4'b0010)begin //rrmovq
            e_valE = E_valA;
        end

        else if(E_icode == 4'b0011)begin //irmovq
            e_valE = E_valC;
        end

        else if(E_icode == 4'b0100)begin //rmmovq
            e_valE = rme;
        end

        else if(E_icode == 4'b0101)begin //mrmovq
            e_valE = rme;
        end

        else if(E_icode == 4'b0110)begin //OPq
            e_valE = vale;
            of= over;
            sf = vale[63];
            if(vale==0) begin
                zf = 1;
            end
            else begin
                zf=0;
            end
        end
        

        else if(E_icode == 4'b1000) begin //call
            e_valE = pushe;    
        end

        else if(E_icode == 4'b1001) // ret
        begin
            e_valE = pope;
        end

        else if(E_icode == 4'b1010) // push
        begin
            e_valE = pushe;
        end

        else if(E_icode == 4'b1011) // pop
        begin
            e_valE = pope;
        end
  
        if(E_icode == 2 || E_icode == 7) //we raise e_cnd when we encounter cmovxx and jxx
        begin
            if(E_ifun == 4'h0)begin 
                e_cnd <= 1; 
            end
            else if(E_ifun== 4'b1)begin //le 
                e_cnd <= (of^sf)|zf; 
            end
            else if(E_ifun == 4'b0010)begin //l
                e_cnd <= (of^sf);
            end
            else if(E_ifun == 4'b0011)begin //e 
                e_cnd <= zf; 
            end
            else if(E_ifun == 4'b0100)begin //ne
                e_cnd <= ~zf;  
            end
            else if(E_ifun == 4'b0101)begin //ge
                e_cnd <= ~(of^zf);  
            end
            else if(E_ifun == 4'b0110)begin //g
                e_cnd <= ~(of^zf) & ~(zf); 
            end
            else begin
            e_cnd <= 0; 
            end
        end
    end

    always @(*)begin
        if(E_icode == 2 || E_icode==7) begin
            if(e_cnd == 1) begin
                e_dstE = E_dstE;
            end
            else begin
                e_dstE=4'b1111;
            end
        end
        else begin
            e_dstE = E_dstE;
        end
    end


    always @(posedge clk) begin
        if(set_cc==1 && m_stat == 0 && W_stat==0) begin
            cc[0]=zf;
            cc[1]=sf;
            cc[2]=of;

            // $writememh("./condition_codes.txt",cc);
        end
        // for(i=0;i<3;++i) begin
        //     $display("%d",cc[i]);
        // end
    end

endmodule