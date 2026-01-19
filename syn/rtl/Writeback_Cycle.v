// `include "Mux.v"

module writeback_cycle(clk, rst, ResultSrcW, PCPlus4W, ALUResultW, ReadDataW, ResultW);

    input clk, rst;
    input [1:0] ResultSrcW; // 2 bits to select 00, 01, 10
    input [31:0] PCPlus4W, ALUResultW, ReadDataW;
    output [31:0] ResultW;

    // a=00(ALU), b=01(Mem), c=10(PC+4)
    Mux_3_by_1 result_mux (    
        .a(ALUResultW),
        .b(ReadDataW),
        .c(PCPlus4W),
        .s(ResultSrcW),
        .d(ResultW)
    );
endmodule