// ProgramCounterTestBench
//
//
// This module implements a testbench for 
// the Program Counter to be created in the
// Digital Systems Design tutorial.
// 
// You need to add the code to test the
// functionality of your PC
//

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

	// add your code here to test the functionality
	// of your program counter

	// you need test different values for the input signals:
	// Reset, LoadValue, LoadEnable, OffsetEnable
	// and Offet. Then, you can check whether the output signal
	// CounterValue shows the correct value, otherwise, you need
	// to fix your ProgramCounter module.
	
	end
endmodule
	
