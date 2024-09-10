module full_adder(a,b,c,sum,carry);
    input a,b,c;
    output sum,carry;
    wire w1,w2,w3,w4,w5;
    xor x1(w1,a,b);
    xor x2(w2,w1,c);
    and a1(w3,a,b);
    and a2(w4,w1,c);
    or o1(w5,w3,w4);
    assign sum = w2;
    assign carry = w5;
endmodule

module adder(a,b,add,ca);
    input signed [63:0] a,b;
    output signed [63:0] add,ca;
    genvar i;
    generate
        for(i=0;i<64;i=i+1) begin
                                if(i==0)
                                    full_adder fa (a[i],b[i],1'b0,add[i],ca[i]);
                                else
                                    full_adder ba (a[i],b[i],ca[i-1],add[i],ca[i]); 
                            end

    endgenerate
endmodule

module subtractor(a,b,sub,cs);
    input signed [63:0] a,b;
    output signed [63:0] sub,cs;
    wire signed [63:0] mid;
    genvar i;
    generate
        for(i=0;i<64;i=i+1) begin
                                xor x9 (mid[i],b[i],1'b1);
                                if(i==0)
                                    full_adder fa (a[i],mid[i],1'b1,sub[i],cs[i]);
                                else
                                    full_adder ba (a[i],mid[i],cs[i-1],sub[i],cs[i]); 
                            end

    endgenerate
endmodule

module XORER(a,b,xoring);
    input signed [63:0] a,b;
    output signed [63:0] xoring;

    genvar i;
    generate
        for(i=0;i<64;i=i+1) begin
                                xor x(xoring[i],a[i],b[i]);
                            end

    endgenerate
endmodule

module ANDER(a,b,anding);
    input signed [63:0] a,b;
    output signed [63:0] anding;
    genvar i;
    generate
        for(i=0;i<64;i=i+1) begin
                                and ander(anding[i],a[i],b[i]);
                            end

    endgenerate
endmodule

module ALU(control,a,b,sum,carry);
    input  signed [63:0] a,b;
    input [1:0] control;
    output signed [63:0] sum;
    output carry;
    wire signed [63:0] add,ca,mid;
    wire signed [63:0] sub,cs,anding,xoring;
    reg signed [63:0] fin;
    reg out;
    adder DUT (a,b,add,ca);
    subtractor EUT (a,b,sub,cs);
    ANDER FUT (a,b,anding);
    XORER GUT (a,b,xoring);
    wire of_1,of_2;
    wire A,B,S;
    not(A,a[63]);
    not(B,b[63]);
    always @* begin
        case(control)
            2'b00: begin
                out = 0;
             
                if((a < 0 == b < 0)&&(add<0 != a < 0))begin
                    out = 1;
                end
                fin = add;
                
            end
            2'b01: begin
                out = 0;
             
                if((a < 0 == b > 0)&&(sub<0 != a < 0))begin
                    out = 1;
                end
                fin = sub;
                
            end
            2'b10: begin
                fin = xoring;
                out = 0;
            end
            2'b11: begin
                fin = anding;
                out = 0;
            end
        endcase
    end
    // always @* begin
    //     if(out==1'b1)begin
    //         $display("Overflow Detected Bitch");
    //     end
    // end
    assign sum = fin;
    assign carry = out;
  
endmodule