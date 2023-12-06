// RegisterFileTestBench
//
// Uriel Martinez-Hernandez
//
// November 2022
//
// This module test the functionality of the Register File
// NOTE:
// THIS MODULE IS INCOMPLETE, YOU NEED TO ADD MORE LINES
// OF CODE TO TEST ALL THE FUNCTIONALITIES OF YOUR MODULE
//

module RegisterFileTB;
    // Parameters
    parameter AddressWidth = 6;
    parameter RegisterHeight = 1 << AddressWidth;
    parameter RegisterWidth = 16;

    // Inputs
    logic Clock;
    logic WriteEnable;
    logic [RegisterWidth-1:0] WriteData;
    logic [AddressWidth-1:0] AddressA, AddressB;

    // Outputs
    logic [RegisterWidth-1:0] ReadDataA, ReadDataB;

    // Instantiate the RegisterFile module
    RegisterFile #(
        .AddressWidth(AddressWidth),
        .RegisterHeight(RegisterHeight),
        .RegisterWidth(RegisterWidth)
    ) dut (
        .Clock(Clock),
        .WriteEnable(WriteEnable),
        .WriteData(WriteData),
        .AddressA(AddressA),
        .AddressB(AddressB),
        .ReadDataA(ReadDataA),
        .ReadDataB(ReadDataB)
    );

    // Clock generation
    always #5 Clock = ~Clock;

    // Testbench stimulus
    initial begin
        // Initialize inputs
        Clock = 0;
        WriteEnable = 1;
        WriteData = 16'hABCD;
        AddressA = 6'b001100;
        AddressB = 6'b010101;

        // Wait for a few clock cycles
        #10;

        // Display initial register values
        $display("Initial Register Values:");
        for (int i = 0; i < RegisterHeight; i++) begin
            $display("Register[%0d] = %h", i, dut.Registers[i]);
        end

        // Perform write operation
        #10;
        WriteEnable = 1;
        WriteData = 16'h1234;
        AddressA = 6'b001100;

        // Wait for a few clock cycles
        #10;

        // Perform read operation
        WriteEnable = 0;
        AddressA = 6'b001100;
        AddressB = 6'b010101;

        // Wait for a few clock cycles
        #10;

        // Display final register values
        $display("Final Register Values:");
        for (int i = 0; i < RegisterHeight; i++) begin
            $display("Register[%0d] = %h", i, dut.Registers[i]);
        end

        // End simulation
        $finish;
    end
endmodule