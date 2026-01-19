module Main_Decoder(Op, RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump);
    input [6:0] Op;
    output RegWrite, ALUSrc, MemWrite, Branch, Jump;
    output [1:0] ImmSrc, ALUOp, ResultSrc; // ResultSrc bit

    wire [6:0] op_load = 7'b0000011;
    wire [6:0] op_store = 7'b0100011;
    wire [6:0] op_rtype = 7'b0110011;
    wire [6:0] op_itype = 7'b0010011;
    wire [6:0] op_branch = 7'b1100011;
    wire [6:0] op_jal = 7'b1101111; // J-Type (Jump)

    assign RegWrite = (Op == op_load || Op == op_rtype || Op == op_itype || Op == op_jal);
    
    assign ImmSrc   = (Op == op_store) ? 2'b01 : 
                      (Op == op_branch) ? 2'b10 : 
                      (Op == op_jal) ? 2'b11 : 2'b00; // 11 for J-type if needed in SignExtend

    assign ALUSrc   = (Op == op_load || Op == op_store || Op == op_itype);
    assign MemWrite = (Op == op_store);
    assign Branch   = (Op == op_branch);
    assign Jump     = (Op == op_jal);

    // 00: ALU, 01: Memory, 10: PC+4
    assign ResultSrc = (Op == op_load) ? 2'b01 : 
                       (Op == op_jal) ? 2'b10 : 2'b00;

    assign ALUOp    = (Op == op_rtype) ? 2'b10 :
                      (Op == op_branch) ? 2'b01 : 2'b00;
endmodule