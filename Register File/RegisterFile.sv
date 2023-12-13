// Author(s): Kevin Huang and Jake Stewart
// Date: 13/12/2023
// Module name: RegisterFile
// Description: this RegisterFile module implements a 16-bit register file by using a 1-D array

module RegisterFile #(
    parameter AddressWidth = 6,
    parameter RegisterHeight = 1 << AddressWidth,
    parameter RegisterWidth = 16
)(
    input logic Clock, WriteEnable,
    input logic [RegisterWidth-1:0] WriteData,
    input logic [AddressWidth-1:0] AddressA, AddressB,
    output logic [RegisterWidth-1:0] ReadDataA, ReadDataB
);
    // Define 1-D array of RegisterHeight length and RegisterWidth element width
    logic [RegisterWidth-1:0] Registers [RegisterHeight];

    // Async read outputs
    always_comb begin
        ReadDataA = Registers[AddressA];
        ReadDataB = Registers[AddressB];
    end

    // Clocked writing 
    always_ff @(posedge Clock) begin
        if (WriteEnable) begin
            Registers[AddressA] <= WriteData;
        end
    end
endmodule
