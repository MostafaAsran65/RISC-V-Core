module Instruction_Memory(rst, A, RD);
    input rst;
    input [31:0] A;
    output reg [31:0] RD;

    // We use a case statement (ROM Logic) so Synthesis creates permanent gates
    // instead of an empty array.
    always @(*) begin
        if (rst == 1'b0) begin
            RD = 32'd0;
        end else begin
            case (A)
                // Instructions from your memfile.hex
                32'h00000000: RD = 32'h00500293; // addi t0, zero, 5
                32'h00000004: RD = 32'h00300313; // addi t1, zero, 3
                32'h00000008: RD = 32'h006283B3; // add t2, t0, t1
                32'h0000000C: RD = 32'h00002403; // lw s0, 0(zero)
                32'h00000010: RD = 32'h00100493; // addi s1, zero, 1
                32'h00000014: RD = 32'h00940533; // add a0, s0, s1
                
                // Default case for unused addresses
                default: RD = 32'h00000000; 
            endcase
        end
    end
endmodule
