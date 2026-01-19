// `include "Fetch_Cycle.v"
// `include "Decode_Cyle.v"
// `include "Execute_Cycle.v"
// `include "Memory_Cycle.v"
// `include "Writeback_Cycle.v"    
// `include "Hazard_unit.v"

module Pipeline_top(clk, rst, ALUResultW_out, Test_PC); 
    input clk, rst;
    output [31:0] ALUResultW_out; 
    output [31:0] Test_PC;       

            

    wire PCSrcE, RegWriteW, RegWriteE, ALUSrcE, MemWriteE, BranchE, RegWriteM, MemWriteM, JumpE;
    wire [1:0] ResultSrcE, ResultSrcM, ResultSrcW; // 2 bits
    wire [2:0] ALUControlE;
    wire [4:0] RdE, RDM, RDW, Rs1E, Rs2E;
    wire [31:0] PCTargetE, InstrD, PCD, PCPlus4D, ResultW, RD1E, RD2E, ImmExtE, PCE, PCPlus4E, PCPlus4M, WriteDataM, ALUResultM;
    wire [31:0] PCPlus4W, ALUResultW, ReadDataW;
    wire [1:0] ForwardBE, ForwardAE;

    assign ALUResultW_out = ALUResultW;
    assign Test_PC = PCD; 
    fetch_cycle Fetch (
        .clk(clk), .rst(rst), 
        .PCSrcE(PCSrcE), .PCTargetE(PCTargetE), 
        .InstrD(InstrD), .PCD(PCD), .PCPlus4D(PCPlus4D)
    );

    decode_cycle Decode (
        .clk(clk), .rst(rst), 
        .InstrD(InstrD), .PCD(PCD), .PCPlus4D(PCPlus4D), 
        .RegWriteW(RegWriteW), .RDW(RDW), .ResultW(ResultW), 
        .RegWriteE(RegWriteE), .ALUSrcE(ALUSrcE), .MemWriteE(MemWriteE), 
        .ResultSrcE(ResultSrcE), .BranchE(BranchE), .ALUControlE(ALUControlE), 
        .RdE(RdE), .RD1E(RD1E), .RD2E(RD2E), .ImmExtE(ImmExtE), 
        .PCE(PCE), .PCPlus4E(PCPlus4E), .Rs1E(Rs1E), .Rs2E(Rs2E), .JumpE(JumpE)
    );

    execute_cycle Execute (
        .clk(clk), .rst(rst), 
        .RegWriteE(RegWriteE), .ALUSrcE(ALUSrcE), .MemWriteE(MemWriteE), 
        .ResultSrcE(ResultSrcE), .BranchE(BranchE), .ALUControlE(ALUControlE), 
        .RD1E(RD1E), .RD2E(RD2E), .ImmExtE(ImmExtE), .RDE(RdE), 
        .PCE(PCE), .PCPlus4E(PCPlus4E), .ResultW(ResultW),
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE), .JumpE(JumpE),
        .RegWriteM(RegWriteM), .MemWriteM(MemWriteM), .ResultSrcM(ResultSrcM), 
        .PCSrcE(PCSrcE), .RDM(RDM), .PCPlus4M(PCPlus4M), 
        .WriteDataM(WriteDataM), .ALUResultM(ALUResultM), .PCTargetE(PCTargetE)
    );

    memory_cycle Memory (
        .clk(clk), .rst(rst), 
        .RegWriteM(RegWriteM), .MemWriteM(MemWriteM), .ResultSrcM(ResultSrcM), 
        .RDM(RDM), .PCPlus4M(PCPlus4M), .WriteDataM(WriteDataM), .ALUResultM(ALUResultM), 
        .ResultW(ResultW), .RegWriteW(RegWriteW), .ReadDataW(ReadDataW),
        .ResultSrcW(ResultSrcW), .RdW(RDW), .PCPlus4W(PCPlus4W), .ALUResultW_out(ALUResultW) 
    );

    writeback_cycle WriteBack (
        .clk(clk), .rst(rst), .ResultSrcW(ResultSrcW), 
        .PCPlus4W(PCPlus4W), .ALUResultW(ALUResultW), .ReadDataW(ReadDataW), .ResultW(ResultW)
    );

    hazard_unit Forwarding_block (
        .rst(rst), .RegWriteM(RegWriteM), .RegWriteW(RegWriteW), 
        .RDM(RDM), .RDW(RDW), .Rs1E(Rs1E), .Rs2E(Rs2E), 
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE)
    );
endmodule