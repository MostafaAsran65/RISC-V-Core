module fetch_tb ();
    reg clk, rst;
    reg PCSrcE;
    reg [31:0] PCTargetE;
    wire [31:0] InstrD, PCD, PCPlus4D; // Fixed name mismatch (small 'l')

    fetch_cycle DUT (
        .clk(clk), .rst(rst), .PCSrcE(PCSrcE), .PCTargetE(PCTargetE),
        .InstrD(InstrD), .PCD(PCD), .PCPlus4D(PCPlus4D)
    );

    initial begin
        clk = 0;
        forever #50 clk = ~clk;
    end

    initial begin
        rst = 0; PCSrcE = 0; PCTargetE = 32'b0;
        #100; rst = 1; // Correct active low reset behavior
        #200; PCSrcE = 1; PCTargetE = 32'h00000020;
        #200; PCSrcE = 0;
        #500; $finish;
    end
    
    initial begin
        $dumpfile("fetch_tb.vcd");
        $dumpvars(0); // Fixed missing bracket
    end
endmodule