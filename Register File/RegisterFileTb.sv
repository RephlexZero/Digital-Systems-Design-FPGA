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

module RegisterFileTb();
	logic        Clock = 0;
	logic [5:0]  AddressA;
	logic [15:0] ReadDataA;
	logic [15:0] WriteData;
	logic        WriteEnable;
	logic [5:0]  AddressB;
	logic [15:0] ReadDataB;

endmodule

logic [RegisterWidth-1:0] Registers [Number of Registers]; 