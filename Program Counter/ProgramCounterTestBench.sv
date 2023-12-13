// Author(s): Kevin Huang and Jake Stewart
// Date: 13/12/2023
// Module name: ProgramCounterTestBench
// Description: This module implements a testbench for the Program Counter
//				We use this to verify the operation of the program counter
//				By simulating testcases involving Reset, LoadValue, Offset, and Combination of inputs

module ProgramCounterTestBench();

	// These are the signals that connect to 
	// the program counter
	logic              	Clock = '0;
	logic              	Reset;
	logic signed       [15:0]	LoadValue;
	logic				LoadEnable;
	logic signed  [8:0]	Offset;
	logic 					OffsetEnable;
	logic signed  [15:0]	CounterValue;

	// this is another method to create an instantiation
	// of the program counter
	ProgramCounter uut
	(
		.Clock,
		.Reset,
		.LoadValue,
		.LoadEnable,
		.Offset,
		.OffsetEnable,
		.CounterValue
	);
	

	default clocking @(posedge Clock);
	endclocking
		
	always  #10  Clock++;

	initial
	begin
		// Test case 1: Reset
		Reset = 1;
		#20;
		Reset = 0;
		#20;

		// Test case 2: LoadValue
		LoadValue = 16'h1234;
		LoadEnable = 1;
		#20;
		LoadEnable = 0;
		#20;

		// Test case 3: Offset
		Offset = 9'h1F;
		OffsetEnable = 1;
		#20;
		OffsetEnable = 0;
		#20;

		// Test case 4: Negative Offset
		Offset = 9'hFF;
		OffsetEnable = 1;
		#20;
		OffsetEnable = 0;
		#20;

		// Test case 5: Combination of inputs
		Reset = 1;
		LoadValue = 16'h5678;
		LoadEnable = 1;
		Offset = 9'h0A;
		OffsetEnable = 1;
		#20;
		Reset = 0;
		LoadEnable = 0;
		OffsetEnable = 0;
		#20;

		$finish;
	end
endmodule