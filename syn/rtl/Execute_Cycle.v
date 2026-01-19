// `include "Mux.v"
// `include "ALU.v"
// `include "PC_Adder.v"   

module execute_cycle(clk, rst, RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE, ALUControlE, 
                     RD1E, RD2E, ImmExtE, RDE, PCE, PCPlus4E, 
                     ResultW, ForwardAE, ForwardBE, JumpE,
                     RegWriteM, MemWriteM, ResultSrcM, PCSrcE, RDM, PCPlus4M, 
                     WriteDataM, ALUResultM, PCTargetE);

    input clk, rst, RegWriteE, ALUSrcE, MemWriteE, BranchE, JumpE;
    input [1:0] ResultSrcE; 
    input [2:0] ALUControlE;
    input [31:0] RD1E, RD2E, ImmExtE;
    input [4:0] RDE;
    input [31:0] PCE, PCPlus4E;
    input [31:0] ResultW; 
    input [1:0] ForwardAE, ForwardBE;

    output reg RegWriteM, MemWriteM;
    output reg [1:0] ResultSrcM; 
    output PCSrcE;
    output reg [4:0] RDM; 
    output reg [31:0] PCPlus4M, WriteDataM, ALUResultM;
    output [31:0] PCTargetE;

    wire [31:0] SrcAE_Final, SrcBE_Forwarded, SrcBE_Final;
    wire [31:0] ResultE;
    wire ZeroE;

    // --- Forwarding MUXES ---
    Mux_3_by_1 SrcA_Mux (
        .a(RD1E), .b(ResultW), .c(ALUResultM), .s(ForwardAE), .d(SrcAE_Final)
    );

    Mux_3_by_1 SrcB_Mux (
        .a(RD2E), .b(ResultW), .c(ALUResultM), .s(ForwardBE), .d(SrcBE_Forwarded)
    );

    // --- ALU Source MUX ---
    Mux ALU_Src_Mux (
         .a(SrcBE_Forwarded), .b(ImmExtE), .s(ALUSrcE), .c(SrcBE_Final)
    );

    // --- ALU ---
    ALU alu_inst (
        .A(SrcAE_Final), .B(SrcBE_Final), .Result(ResultE), .ALUControl(ALUControlE),
        .OverFlow(), .Carry(), .Zero(ZeroE), .Negative()
    );

    // --- Branch Target ---
    PC_Adder branch_adder (
        .a(PCE), .b(ImmExtE), .c(PCTargetE)
    );

    assign PCSrcE = (BranchE & ZeroE) | JumpE;

    // --- Pipeline Register (Execute -> Memory) ---
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0) begin
            RegWriteM <= 1'b0;
            MemWriteM <= 1'b0;
            ResultSrcM <= 2'b00;
            ALUResultM <= 32'd0;
            RDM <= 5'd0;
            PCPlus4M <= 32'd0;
            WriteDataM <= 32'd0;
        end else begin
            RegWriteM <= RegWriteE;
            MemWriteM <= MemWriteE;
            ResultSrcM <= ResultSrcE;
            RDM <= RDE;
            PCPlus4M <= PCPlus4E;
            ALUResultM <= ResultE;
            WriteDataM <= SrcBE_Forwarded;
        end
    end
endmodule