// `include "Data_Memory.v"

module memory_cycle(clk, rst, RegWriteM, MemWriteM, ResultSrcM, 
                    RDM, PCPlus4M, WriteDataM, ALUResultM, 
                    ResultW, RegWriteW, ReadDataW, ResultSrcW, RdW, PCPlus4W, ALUResultW_out
    );

    input RegWriteM, MemWriteM;
    input [1:0] ResultSrcM; // 2 bits
    input [4:0] RDM; 
    input [31:0] PCPlus4M, WriteDataM, ALUResultM;
    input [31:0] ResultW; // For Forwarding loop only (unused inside)
    input clk, rst;

    output reg [31:0] ReadDataW, PCPlus4W, ALUResultW_out;
    output reg RegWriteW;
    output reg [1:0] ResultSrcW; // 2 bits
    output reg [4:0] RdW;

    wire [31:0] ReadDatM_wire;

    Data_Memory Memory(
        .clk(clk), .rst(rst), .WE(MemWriteM), .WD(WriteDataM), .A(ALUResultM), .RD(ReadDatM_wire)
    );

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            RegWriteW <= 1'b0;
            ResultSrcW <= 2'b00;
            RdW <= 5'd0;
            PCPlus4W <= 32'd0;
            ALUResultW_out <= 32'd0;
            ReadDataW <= 32'd0;
        end else begin
            RegWriteW <= RegWriteM;
            ResultSrcW <= ResultSrcM;
            RdW <= RDM;
            PCPlus4W <= PCPlus4M;
            ALUResultW_out <= ALUResultM;
            ReadDataW <= ReadDatM_wire;
        end
    end
endmodule