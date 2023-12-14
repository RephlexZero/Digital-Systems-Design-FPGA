module RegisterFileTb();
    // Testbench inputs
    logic        Clock = 0;
    logic [5:0]  AddressA;
    logic [15:0] WriteData;
    logic        WriteEnable;
    logic [5:0]  AddressB;

    // Testbench outputs
    logic [15:0] ReadDataA;
    logic [15:0] ReadDataB;

    // Instantiate the RegisterFile module
    RegisterFile #(
        .AddressWidth(6),
        .RegisterHeight(1 << 6),
        .RegisterWidth(16)
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
        // Test case 1: Write data to register at AddressA
        AddressA = 2;
        WriteData = 16'h1234;
        WriteEnable = 1;
        #10;
        WriteEnable = 0;
        #10;

        // Test case 2: Read data from register at AddressA
        AddressA = 2;
        #10;

        // Test case 3: Write data to register at AddressB
        AddressB = 4;
        WriteData = 16'hABCD;
        WriteEnable = 1;
        #10;
        WriteEnable = 0;
        #10;

        // Test case 4: Read data from register at AddressB
        AddressB = 4;
        #10;

        // Add more test cases as needed

        $finish;
    end
endmodule