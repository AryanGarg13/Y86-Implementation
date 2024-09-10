module fetch(clk,F_predPC,f_icode,f_ifun,f_rA,f_rB,f_valC,f_valP,f_stat,M_icode,M_Cnd,M_valA,W_icode,W_valM,f_predPC);
    input clk;    
    input signed [63:0] F_predPC; 
    reg [7:0] PC_mem [0:1023]; 
    output reg [3:0] f_icode,f_ifun;
    output reg signed [63:0] f_valC; 
    output reg [3:0] f_rA,f_rB; 
    output reg signed [63:0] f_valP; 
    output reg [1:0] f_stat=0;
    output reg signed [63:0] f_predPC;
    input [3:0] M_icode,W_icode;
    input M_Cnd;
    input signed [63:0] M_valA,W_valM;



    integer i;
    initial begin
        f_stat=0;
        for(i=0;i<1023;i=i+1) begin
            PC_mem[i]=0;
        end
        $readmemh("./instructions_lhret.txt",PC_mem);
    end

    // always @(posedge clk) begin
    //     if(M_icode==4'b0111) begin
    //         if(!M_Cnd) begin
    //             f_pc=M_valA;
    //         end
    //     end
    //     if(W_icode==4'b1001) begin
    //         f_pc=W_valM;
    //     end
    // end

    // input [63:0] F_predPC,M_valA,W_valM;
    // input [3:0] M_icode,W_icode; 
    // input M_Cnd;
    reg signed [63:0] f_pc;

    always @(*) begin
        if(M_icode==4'b0111 && !M_Cnd) begin     //instr: jxx
            // if(!M_Cnd) begin            // checking CND returned from execute stage
                f_pc = M_valA;
            // end
        end
        else if(W_icode==4'b1001) begin //instr: ret
            f_pc = W_valM;
        end
        else begin                    // For the rest of the conditions
            f_pc = F_predPC;
        end
        // $display("Time = %0t, f_pc = %d, F_predPC = %d\n",$time,f_pc,F_predPC);
    end

    always @* begin
        f_icode = PC_mem[f_pc][7:4];
        f_ifun = PC_mem[f_pc][3:0];
        // $display("time=%0t\n",$time);
        // $display("clock=%d\n",clk);
        // $display("f_pc=%d \n",f_pc);
        // $display("f_icode=%d \n",f_icode);
        f_stat=2'b00;
        if(f_icode<4'b0000 && f_icode>4'b1011) begin
            f_stat=2'b10;
        end
        else if(f_icode == 4'b0000) //instr: halt
        begin
            f_valP = f_pc+1;
            if(f_ifun!=4'b0000)begin
                f_stat=2'b10;
            end
            f_stat =2'b11;
        end
        else if(f_icode == 4'b0001) //instr: nop
        begin
            f_valP = f_pc+1;
        end
        else if(f_icode == 4'b0010) //instr: rrmovq/cmovq
        begin
            f_valP = f_pc+2;
            if(f_ifun>=4'b0000 && f_ifun<=4'b0110)begin
                f_rA = PC_mem[f_pc+1][7:4];
                f_rB = PC_mem[f_pc+1][3:0];
            end
            else begin
                f_stat=2'b10;
            end
        end
        else if(f_icode == 4'b0011) //instr: irmmovq
        begin
            f_valP = f_pc+10;
            f_rA = PC_mem[f_pc+1][7:4];   // updating value of f_rA to the instruction value
            f_rB = PC_mem[f_pc+1][3:0];   // updating value of f_rB to the instruction value
            f_valC = {PC_mem[f_pc+9][7:0],PC_mem[f_pc+8][7:0],PC_mem[f_pc+7][7:0],PC_mem[f_pc+6][7:0],PC_mem[f_pc+5][7:0],PC_mem[f_pc+4][7:0],PC_mem[f_pc+3][7:0],PC_mem[f_pc+2][7:0]}; //updating the value of f_valC if required in instr
        end
        else if(f_icode == 4'b0100) //instr: rmmovq
        begin
            f_valP = f_pc+10;
            f_rA = PC_mem[f_pc+1][7:4];
            f_rB = PC_mem[f_pc+1][3:0];
            f_valC = {PC_mem[f_pc+9][7:0],PC_mem[f_pc+8][7:0],PC_mem[f_pc+7][7:0],PC_mem[f_pc+6][7:0],PC_mem[f_pc+5][7:0],PC_mem[f_pc+4][7:0],PC_mem[f_pc+3][7:0],PC_mem[f_pc+2][7:0]};
        end
        else if(f_icode == 4'b0101) //instr: mrmovq
        begin
            f_valP = f_pc+10;
            f_rA = PC_mem[f_pc+1][7:4];
            f_rB = PC_mem[f_pc+1][3:0];
            f_valC = {PC_mem[f_pc+9][7:0],PC_mem[f_pc+8][7:0],PC_mem[f_pc+7][7:0],PC_mem[f_pc+6][7:0],PC_mem[f_pc+5][7:0],PC_mem[f_pc+4][7:0],PC_mem[f_pc+3][7:0],PC_mem[f_pc+2][7:0]};
        end
        else if(f_icode == 4'b0110) //instr: OP
        begin
            f_valP = f_pc+2;
            if(f_ifun>=4'b0000 && f_ifun<=4'b0100)begin
                f_rA = PC_mem[f_pc+1][7:4];
                f_rB = PC_mem[f_pc+1][3:0];
            end
            else begin
                f_stat=2'b10;
            end
        end
        else if(f_icode == 4'b0111) //instr: jump
        begin
            f_valP = f_pc+9;
            if(f_ifun>=4'b0000 && f_ifun<=4'b0110)begin
                f_valC = {PC_mem[f_pc+8][7:0],PC_mem[f_pc+7][7:0],PC_mem[f_pc+6][7:0],PC_mem[f_pc+5][7:0],PC_mem[f_pc+4][7:0],PC_mem[f_pc+3][7:0],PC_mem[f_pc+2][7:0],PC_mem[f_pc+1][7:0]};
            end
            else begin
                f_stat=2'b10;
            end
        end
        else if(f_icode == 4'b1000) //instr: call
        begin
            f_valP = f_pc+9;
            f_valC = {PC_mem[f_pc+8][7:0],PC_mem[f_pc+7][7:0],PC_mem[f_pc+6][7:0],PC_mem[f_pc+5][7:0],PC_mem[f_pc+4][7:0],PC_mem[f_pc+3][7:0],PC_mem[f_pc+2][7:0],PC_mem[f_pc+1][7:0]};
        end
        else if(f_icode == 4'b1001) //instr: ret
        begin
            f_valP = f_pc+1;
        end
        else if(f_icode == 4'b1010) //instr: push
        begin
            f_valP = f_pc+2;
            f_rA = PC_mem[f_pc+1][7:4];
            f_rB = PC_mem[f_pc+1][3:0];
        end
        else if(f_icode == 4'b1011) //instr: pop
        begin
            f_valP = f_pc+2;
            f_rA = PC_mem[f_pc+1][7:4];
            f_rB = PC_mem[f_pc+1][3:0];
        end
        if(f_pc>1023 || f_pc<0) begin
                f_stat=2'b10;
        end
        // $display("FUCKKKKK");
        if(f_icode==4'b0111) begin     //instr: jxx
            f_predPC=f_valC;           // checking CND returned from execute stage
            
        end
        else if(f_icode==4'b1000) begin //instr: call
            f_predPC = f_valC;
           
        end
        else begin                    // For the rest of the conditions
            // $display("At time=%0t , f_predpc is %d",$time,f_predPC);
            f_predPC = f_valP;
        end
    end

    // always @* begin
    //     if(f_icode==4'b0111) begin     //instr: jxx
    //         f_predPC=f_valC;           // checking CND returned from execute stage
            
    //     end
    //     else if(f_icode==4'b1000) begin //instr: call
    //         f_predPC = f_valC;
           
    //     end
    //     else begin                    // For the rest of the conditions
    //         $display("At time=%0t , f_predpc is %d",$time,f_predPC);
    //         f_predPC = f_valP;
    //     end
    //     end

endmodule 