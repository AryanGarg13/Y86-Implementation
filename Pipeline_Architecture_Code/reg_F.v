module reg_F(clk,F_predPC,f_predPC,F_stall);

input clk;
input signed [63:0] f_predPC;
input F_stall;
output reg signed [63:0] F_predPC;

always @(posedge clk) begin
    if(!F_stall)begin
        F_predPC<=f_predPC;
        // $display("F_predPC=%d f_predPC=%d F_stall=%d\n",F_predPC,f_predPC,F_stall);
    end
    else begin
        F_predPC<=F_predPC;
        // $display("F_predPC=%d F_stall=%d",F_predPC,F_stall);
    end
end

endmodule