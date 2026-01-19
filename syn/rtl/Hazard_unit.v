module hazard_unit(rst, RegWriteM, RegWriteW, RDM, RDW, Rs1E, Rs2E, ForwardAE, ForwardBE);
    input rst, RegWriteM, RegWriteW;
    input [4:0] RDM, RDW, Rs1E, Rs2E;
    output [1:0] ForwardAE, ForwardBE;
    
    // Forwarding for Source A
    assign ForwardAE = (rst == 1'b0) ? 2'b00 : 
                       ((RegWriteM == 1'b1) & (RDM != 5'h00) & (RDM == Rs1E)) ? 2'b10 : // Forward from Memory
                       ((RegWriteW == 1'b1) & (RDW != 5'h00) & (RDW == Rs1E)) ? 2'b01 : // Forward from Writeback
                       2'b00;
                       
    // Forwarding for Source B
    assign ForwardBE = (rst == 1'b0) ? 2'b00 : 
                       ((RegWriteM == 1'b1) & (RDM != 5'h00) & (RDM == Rs2E)) ? 2'b10 : // Forward from Memory
                       ((RegWriteW == 1'b1) & (RDW != 5'h00) & (RDW == Rs2E)) ? 2'b01 : // Forward from Writeback
                       2'b00;
endmodule