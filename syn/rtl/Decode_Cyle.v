// `include "Control_Unit_Top.v"
// `include "Register_File.v"
// `include "Sign_Extend.v"

module decode_cycle (rst, clk, InstrD, PCD, PCPlus4D, RegWriteW, RDW, ResultW, 
                     RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE, ALUControlE, 
                     RdE, RD1E, RD2E, ImmExtE, PCE, PCPlus4E, Rs1E, Rs2E, JumpE);
    
    input rst, clk;
    input [31:0] InstrD, PCD, PCPlus4D;
    input RegWriteW;
    input [4:0] RDW;
    input [31:0] ResultW;

    output reg RegWriteE, ALUSrcE, MemWriteE, BranchE, JumpE;
    output reg [1:0] ResultSrcE; 
    output reg [2:0] ALUControlE;
    output reg [31:0] RD1E, RD2E, ImmExtE, PCE, PCPlus4E;
    output reg [4:0] RdE, Rs1E, Rs2E;

    wire RegWriteD, ALUSrcD, MemWriteD, BranchD, JumpD;
    wire [1:0] ResultSrcD; 
    wire [2:0] ALUControlD;
    wire [1:0] ImmSrcD;
    wire [31:0] RD1D, RD2D, ImmExtD;

    Control_Unit_Top control (
        .Op(InstrD[6:0]),
        .RegWrite(RegWriteD),
        .ImmSrc(ImmSrcD),
        .ALUSrc(ALUSrcD),
        .MemWrite(MemWriteD),
        .ResultSrc(ResultSrcD),
        .Branch(BranchD),
        .funct3(InstrD[14:12]),
        .funct7(InstrD[31:25]),
        .ALUControl(ALUControlD),
        .Jump(JumpD)
    );

    Register_File rf (
        .clk(clk),
        .rst(rst),
        .WE3(RegWriteW),
        .WD3(ResultW),
        .A1(InstrD[19:15]),
        .A2(InstrD[24:20]),
        .A3(RDW),
        .RD1(RD1D),
        .RD2(RD2D)
    );

    Sign_Extend se (
        .In(InstrD),
        .ImmSrc(ImmSrcD),
        .Imm_Ext(ImmExtD)
    );

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            RegWriteE <= 1'b0;
            ALUSrcE <= 1'b0;
            MemWriteE <= 1'b0;
            ResultSrcE <= 2'b00;
            BranchE <= 1'b0;
            JumpE <= 1'b0;
            ALUControlE <= 3'b0;
            RD1E <= 32'b0;
            RD2E <= 32'b0;
            ImmExtE <= 32'b0;
            PCE <= 32'b0;
            PCPlus4E <= 32'b0;
            RdE <= 5'b0;
            Rs1E <= 5'b0;
            Rs2E <= 5'b0;
        end else begin
            RegWriteE <= RegWriteD;
            ALUSrcE <= ALUSrcD;
            MemWriteE <= MemWriteD;
            ResultSrcE <= ResultSrcD;
            BranchE <= BranchD;
            JumpE <= JumpD;
            ALUControlE <= ALUControlD;
            RD1E <= RD1D;
            RD2E <= RD2D;
            ImmExtE <= ImmExtD;
            PCE <= PCD;
            PCPlus4E <= PCPlus4D;
            RdE <= InstrD[11:7];
            Rs1E <= InstrD[19:15];
            Rs2E <= InstrD[24:20];
        end
    end
endmodule