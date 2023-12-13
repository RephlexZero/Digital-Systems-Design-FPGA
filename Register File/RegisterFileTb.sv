// Author(s): Kevin Huang and Jake Stewart
// Date: 13/12/2023
// Module name: RegisterFileTb
// Description: this testbench tests the functionality of the RegisterFile module by using it to store and retrieve data

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

        #10;

        // Perform write operation
        #10;
        WriteEnable = 1;
        WriteData = 16'h1234;
        AddressA = 6'b001100;

        #10;

        // Perform read operation
        WriteEnable = 0;
        AddressA = 6'b001100;
        AddressB = 6'b001100;

        #10;

        // End simulation
        $finish;
    end
endmodule