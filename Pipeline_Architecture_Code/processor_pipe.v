`include "fetch.v"
`include "reg_F.v"
`include "reg_D.v"
`include "reg_E.v"
`include "reg_M.v"
`include "reg_W.v"
`include "decode_writeBack.v"
`include "ALU.v"
`include "execute.v"
`include "memory.v"
// `include "pc_update.v"
`include "pipeline_control.v"


module processor_pipe;

reg clk;
// reg signed [63:0] PC;
// wire signed [63:0] valA,valB,valE,valC,valM,valP,PC_update;
// wire [3:0] rA,rB,icode,ifun;
// wire instr_valid,imem_error,CND;
// wire [1:0] stat;

reg signed [63:0] F_predPC;  // select pc
wire signed [63:0] pc_up;

// wire [63:0] M_valA,W_valM;
// input [3:0] M_icode,W_icode; 
// input M_Cnd;

wire signed [63:0] f_predPC; // regF


wire signed [63:0] f_pc; //fetch
// reg [7:0] PC_mem [0:1023]; 
wire [3:0] f_icode,f_ifun;
wire signed [63:0] f_valC; 
wire [3:0] f_rA,f_rB; 
wire signed [63:0] f_valP; 
wire [1:0] f_stat;
// wire signed [63:0] f_predPC;
// input [3:0] M_icodeW_icode;
// input M_cnd;
// input signed [63:0] M_valA,W_valM;

// input [1:0] f_stat; // regD
// input [3:0] f_icode,f_ifun;
// input [3:0] f_rA,f_rB;
// input signed [63:0] f_valC,f_valP;
wire [1:0] D_stat;
wire [3:0] D_icode,D_ifun;
wire [3:0] D_rA,D_rB;
wire signed [63:0] D_valC,D_valP;

// input [3:0] D_icode,D_ifun,W_icode; // decode
// input [3:0] D_rA,D_rB;
// input signed [63:0] D_valP;
// input signed [63:0] W_valE,W_valM,D_valC;
wire signed [63:0] d_valA,d_valB;
// reg signed [63:0] R [0:14];
wire [3:0] d_srcA,d_srcB,w_dstM,w_dstE;

// input [1:0] D_stat; //  regE
// input [3:0] D_icode,D_ifun;
// input [3:0] d_srcA,d_srcB,d_dstE,d_dstM;
// input signed [63:0] d_valC,d_valA,d_valB;
wire [1:0] E_stat;
wire [3:0] E_icode,E_ifun;
wire [3:0] E_srcA,E_srcB,E_dstE,E_dstM;
wire signed [63:0] E_valC,E_valA,E_valB;

// input [3:0] E_icode,E_ifun; // execute
// input signed [63:0] E_valA,E_valB,E_valC;
wire signed [63:0] e_valE;
// reg sf,zf,of;
wire e_cnd;
// input E_dstE;
wire [3:0] e_dstE;

// input [1:0] E_stat; // regM
// input [3:0] E_icode;    
// input e_Cnd;
// input signed [63:0] e_valE,E_valA;
wire [1:0] M_stat;
wire M_Cnd;
wire [3:0] M_icode,M_ifun;
wire signed [63:0] M_valE,M_valA;
wire [3:0] M_dstE,M_dstM;

// input [3:0] M_icode; // memory
// input signed [63:0] M_valE,M_valA;
wire signed [63:0] m_valM;
wire [1:0] m_stat;

// input [1:0] m_stat; // writeback
// input [3:0] M_icode,M_dstM;
// input signed [63:0] M_valE,m_valM;
wire [1:0] W_stat;
wire [3:0] W_icode,W_dstM,W_dstE;
wire signed [63:0] W_valE,W_valM;
wire F_stall,D_stall,D_bubble,E_bubble,M_bubble,W_stall,set_cc;



// fetch fetch_module(.clk(clk),.PC(PC),.icode(icode),.ifun(ifun),.rA(rA),.rB(rB),.valC(valC),.valP(valP),.instr_valid(instr_valid),.mem_error(imem_error));
// decode_writeBack dec_wb(.clk(clk),.icode(icode),.ifun(ifun),.CND(CND),.rA(rA),.rB(rB),.valE(valE),.valM(valM),.valA(valA),.valB(valB));
// execute exec(.clk(clk),.icode(icode),.ifun(ifun),.valA(valA),.valB(valB),.valC(valC),.valE(valE),.cnd(CND));
// memory mem_module(.clk(clk),.icode(icode),.valE(valE),.valA(valA),.valP(valP),.instr_valid(instr_valid),.imem_error(imem_error),.valM(valM),.stat(stat));
// pc_update pc(.clk(clk),.CND(CND),.valP(valP),.valC(valC),.valM(valM),.icode(icode),.PC_update(PC_update));

pipeline_control pcl(D_icode,d_srcA,d_srcB,E_icode,E_dstM,e_cnd,M_icode,m_stat,W_stat,F_stall,D_stall,D_bubble,E_bubble,M_bubble,W_stall,set_cc);
reg_F r_F(clk,pc_up,f_predPC,F_stall);
fetch f(clk,F_predPC,f_icode,f_ifun,f_rA,f_rB,f_valC,f_valP,f_stat,M_icode,M_Cnd,M_valA,W_icode,W_valM,f_predPC);
// pc_update pc(clk,F_predPC,M_icode,M_Cnd,M_valA,W_icode,W_valM,f_pc);
reg_D r_D(clk,D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,f_stat,f_icode,f_ifun,f_rA,f_rB,f_valC,f_valP,D_stall,D_bubble);
decode_writeBack d_w(clk,D_icode,D_ifun,W_icode,D_valP,D_rA,D_rB,d_srcA,d_srcB,w_dstM,w_dstE,W_valE,W_valM,d_valA,d_valB,D_valC,e_dstE,e_valE,M_dstE,M_valE,M_dstM,m_valM,W_dstE,W_dstM,W_valE,W_valM);
reg_E r_E(clk,E_stat,E_icode,E_ifun,E_valC,E_valA,E_valB,E_srcA,E_srcB,E_dstE,E_dstM,D_stat,D_icode,D_ifun,D_valC,d_valA,d_valB,d_srcA,d_srcB,w_dstE,w_dstM,E_bubble);
execute exec(clk,E_icode,E_ifun,E_valA,E_valB,E_valC,E_dstE,e_valE,e_cnd,e_dstE,m_stat,W_stat,set_cc);
reg_M r_M(clk,M_stat,M_icode,M_valE,M_valA,M_Cnd,M_dstE,M_dstM,E_stat,E_icode,e_valE,E_valA,e_dstE,E_dstM,e_cnd,M_bubble);
memory mem(clk,M_icode,M_valE,M_valA,M_stat,m_valM,m_stat);
reg_W r_W(clk,W_stat,W_icode,W_valE,W_valM,W_dstE,W_dstM,m_stat,M_icode,M_valE,m_valM,M_dstE,M_dstM,W_stall);





initial begin
    // $monitor("time = %0t\npc_up = %5d\nf_predPC = %5d\n",$time,pc_up,f_predPC);
    // $monitor("time = %0t\nclk=%b\nf_pc = %5d\nf_icode = %5d\nf_ifun = %5d\nf_rA = %5d\nf_rB = %5d\nf_valC = %5d\nf_valP = %5d\nf_stat = %5d\nD_stat = %5d\nD_icode = %5d\nD_ifun = %5d\nD_rA = %5d\nD_rB = %5d\nD_valC = %5d\nD_valP = %5d\n",$time,clk,f_pc,f_icode,f_ifun,f_rA,f_rB,f_valC,f_valP,f_stat,D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP);
    // $monitor("time = %0t\nD_stat = %5d\nD_icode = %5d\nD_ifun = %5d\nD_rA = %5d\nD_rB = %5d\nD_valC = %5d\nD_valP = %5d\n",$time,D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP);
    $dumpfile("Seq.vcd");
    $dumpvars(0,processor_pipe); 
    clk=1;
    F_predPC=0;
    
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;

    $finish;
end

always @(clk) begin
    $display("time = %0t\npc_up = %5d\nf_predPC = %5d\n",$time,pc_up,f_predPC);
    // $display("clk=%b\nF_predPC = %5d\nf_icode = %5d\nf_ifun = %5d\nf_rA = %5d\nf_rB = %5d\nf_valC = %5d\nf_valP = %5d\nf_stat = %5d\n",clk,F_predPC,f_icode,f_ifun,f_rA,f_rB,f_valC,f_valP,f_stat);
    // $display("D_stat = %5d\nD_icode = %5d\nD_ifun = %5d\nD_rA = %5d\nD_rB = %5d\nD_valC = %5d\nD_valP = %5d\n",D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP);
//     if(stat == 4'b0011) begin // Halt instruction encountered
//         $display("Halt Instruction Encountered");
//         $finish;
//     end
//     if(stat ==4'b0010) begin // Invalid instruction 
//         $display("ERROR:Invalid Instruction Detected");
//         $finish;
//     end
//     if(stat == 4'b0001) begin //Memory address out of bounds
//         $display("ERROR:Memory out of bounds error");
//         $finish;
//     end
end

always @* begin
    if(W_stat==2'b11) begin
        $finish;
    end
end

always @(posedge clk) begin
    if(!F_stall)begin
    F_predPC<=f_predPC;
    end
    
    // if(f_stat == 3)begin
    //     $finish;
    // end
end

always #5 clk=~clk;
endmodule
