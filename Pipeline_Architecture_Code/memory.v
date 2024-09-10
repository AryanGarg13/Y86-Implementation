module memory(clk,M_icode,M_valE,M_valA,M_stat,m_valM,m_stat);
input clk;
input [3:0] M_icode;
input signed [63:0] M_valE,M_valA;
output reg signed [63:0] m_valM;
output reg [1:0] m_stat;
input [1:0] M_stat;

reg mem_read=0;
reg mem_write=1;
reg mem_error;

reg [63:0] mem_addr,mem_data;

reg [63:0] mem [0:8191];

initial begin
    $readmemh("./mem.txt",mem);
end

always @ (*) begin

    mem_read=0;
    mem_write=0;
    mem_error=0;

    if (M_icode==4'b0100) begin //rmmovq
        mem_write=1;
        mem_addr=M_valE;
        mem_data=M_valA;
    end

    else if (M_icode==4'b0101) begin //mrmovq
        mem_read=1;
        mem_addr=M_valE;
    end

        else if (M_icode==4'b1010) begin //pushq
        mem_write=1;
        mem_addr=M_valE;
        mem_data=M_valA;
    end

    else if (M_icode==4'b1011) begin //popq
        mem_read=1;
        mem_addr=M_valA;
    end    

    else if (M_icode==4'b1000) begin //call
        mem_write=1;
        mem_addr=M_valE;
        mem_data=M_valA;
    end

    else if (M_icode==4'b1001) begin //ret
        mem_read=1;
        mem_addr=M_valA;
    end

    if(mem_read==1) begin
        m_valM=mem[mem_addr];
    end
    if(mem_addr>1023) begin
        mem_error=1;
    end
    if(M_icode==4'b0000) begin
        m_stat=4'b11;
    end
    else if(M_stat == 4'b0010) begin 
        m_stat=4'b10;
    end
    else if(M_stat ==4'b0000 && mem_error == 1) begin
        m_stat=4'b01;
    end
    else begin
        m_stat=4'b00;
    end
end

always @(posedge clk) begin

    if(mem_write==1) begin // writing only the positive edge of the clock
        mem[mem_addr]=mem_data;
        $writememh("./mem.txt",mem);
    end

end

endmodule