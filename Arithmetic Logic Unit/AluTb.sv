`timescale 1ns / 1ps

import InstructionSetPkg::*;

// This module implements a set of tests that 
// partially verify the ALU operation.
module AluTb();

	eOperation Operation;
	
	sFlags    InFlags;
	sFlags    OutFlags;
	
	logic signed [ImmediateWidth-1:0] InImm = '0;
	
	logic	signed [DataWidth-1:0] InSrc  = '0;
	logic signed [DataWidth-1:0] InDest = '0;
	
	logic signed [DataWidth-1:0] OutDest;

	ArithmeticLogicUnit uut (.*);

	initial
	begin
		InFlags = sFlags'(0);
		
		
		$display("Start of NAND tests");
		Operation = NAND;
		
		InDest = 16'h0000;
		InSrc  = 16'ha5a5;      
	   #1 if (OutDest != 16'hFFFF) $display("Error in NAND operation at time %t",$time);
		
		#10 InDest = 16'h9999; 
	   #1 if (OutDest != 16'h7E7E) $display("Error in NAND operation at time %t",$time);
		
		#10 InDest = 16'hFFFF; 
	   #1 if (OutDest != 16'h5a5a) $display("Error in NAND operation at time %t",$time);
		
		#10 InDest = 16'h1234; 
	   #1 if (OutDest != 16'hFFDB) $display("Error in NAND operation at time %t",$time);
		
		#10 InSrc = 16'h0000;   
		InDest = 16'ha5a5;     
	   #1 if (OutDest != 16'hFFFF) $display("Error in NAND operation at time %t",$time);
		
		#10 InSrc = 16'h9999;  
	   #1 if (OutDest != 16'h7E7E) $display("Error in NAND operation at time %t",$time);
		
		#10 InSrc = 16'hFFFF; 
	   #1 if (OutDest != 16'h5a5a) $display("Error in NAND operation at time %t",$time);
		
		#10 InSrc = 16'h1234;  
	   #1 if (OutDest != 16'hFFDB) $display("Error in NAND operation at time %t",$time);
		#50;

				
		
		$display("Start of ADC tests");
		Operation = ADC;
		
		InDest = 16'h0000;
		InSrc = 16'ha5a5;   
	   #1 
		if (OutDest != 16'ha5a5) $display("Error in ADC operation at time %t",$time);
	   if (OutFlags != sFlags'(12)) $display("Error (flags) in ADC operation at time %t",$time);
		
		#10 InFlags.Carry = '1;
	   #1 
		if (OutDest != 16'ha5a6) $display("Error in ADC operation at time %t",$time);
	   if (OutFlags != sFlags'(12)) $display("Error (flags) in ADC operation at time %t",$time);

		#10 InDest = 16'h5a5a; 
	   #1 
		if (OutDest != 16'h0000) $display("Error in ADC operation at time %t",$time);
	   if (OutFlags != sFlags'(11)) $display("Error (flags) in ADC operation at time %t",$time);
		
		#10 InDest = 16'h8000;
		InFlags.Carry = '0;
		InSrc = 16'hffff;      
	   #1 
		if (OutDest != 16'h7fff) $display("Error in ADC operation at time %t",$time);
	   if (OutFlags != sFlags'(17)) $display("Error (flags) in ADC operation at time %t",$time);
		
		#10 InDest = 16'h7fff;
		InSrc = 16'h0001;     
	   #1 
		if (OutDest != 16'h8000) $display("Error in ADC operation at time %t",$time);
	   if (OutFlags != sFlags'(20)) $display("Error (flags) in ADC operation at time %t",$time);
		#50;

		
		$display("Start of LIU tests");
		Operation = LIU;
		
		InDest = 16'h0000;
		InImm = 6'h3F;          
	   #1 if (OutDest != 16'hF800) $display("Error in LIU operation at time %t",$time);
		
		#10 InImm = 6'h0F;      
	   #1 if (OutDest != 16'h03C0) $display("Error in LIU operation at time %t",$time);
		
		#10 InDest = 16'hAAAA;  		
	   #1 if (OutDest != 16'h03EA) $display("Error in LIU operation at time %t",$time);
		
		#10 InImm = 6'h3F;      
	   #1 if (OutDest != 16'hFAAA) $display("Error in LIU operation at time %t",$time);

	

		// Put your code here to verify the instructions.

		$display ("Start of MOVE tests");
		Operation = MOVE;

		InDest = 16'h0000;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'hFFFF) $display("Error in MOVE operation at time %t",$time);

		#10 InSrc = 16'h0000;
		#1 if (OutDest != 16'h0000) $display("Error in MOVE operation at time %t",$time);

		#10 InSrc = 16'hAAAA;
		#1 if (OutDest != 16'hAAAA) $display("Error in MOVE operation at time %t",$time);

		#10 InSrc = 16'hFFFF;
		#1 if (OutDest != 16'hFFFF) $display("Error in MOVE operation at time %t",$time);


		$display ("Start of NOR tests");
		Operation = NOR;

		InDest = 16'h0000;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'h0000) $display("Error in NOR operation at time %t",$time);

		#10 InSrc = 16'h0000;
		#1 if (OutDest != 16'hFFFF) $display("Error in NOR operation at time %t",$time);

		#10 InSrc = 16'hAAAA;
		#1 if (OutDest != 16'h5555) $display("Error in NOR operation at time %t",$time);

		#10 InSrc = 16'hFFFF;
		#1 if (OutDest != 16'h0000) $display("Error in NOR operation at time %t",$time);


		$display ("Start of ROR tests");
		Operation = ROR;

		InDest = 16'h0000;
		InFlags.Carry = '0;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'h7FFF) $display("Error in ROR operation at time %t",$time);

		#10 InFlags.Carry = '1;
		#1 if (OutDest != 16'hFFFF) $display("Error in ROR operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InFlags.Carry = '0;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'h7FFF) $display("Error in ROR operation at time %t",$time);

		#10 InFlags.Carry = '1;
		#1 if (OutDest != 16'hFFFF) $display("Error in ROR operation at time %t",$time);


		$display ("Start of SUB tests");
		Operation = SUB;

		InDest = 16'h0000;
		InFlags.Carry = '0;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'h0001) $display("Error in SUB operation at time %t",$time);

		#10 InFlags.Carry = '1;
		#1 if (OutDest != 16'h0000) $display("Error in SUB operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InFlags.Carry = '0;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'hAAAB) $display("Error in SUB operation at time %t",$time);

		#10 InFlags.Carry = '1;
		#1 if (OutDest != 16'hAAAA) $display("Error in SUB operation at time %t",$time);

		
		$display ("Start of DIV tests");
		Operation = DIV;

		InDest = 16'h0000;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'h0000) $display("Error in DIV operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'h0000) $display("Error in DIV operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InSrc = 16'h0001;
		#1 if (OutDest != 16'hAAAA) $display("Error in DIV operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InSrc = 16'h0002;
		#1 if (OutDest != 16'h5555) $display("Error in DIV operation at time %t",$time);


		$display ("Start of MOD tests");
		Operation = MOD;

		InDest = 16'h0000;	
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'h0000) $display("Error in MOD operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'hAAAA) $display("Error in MOD operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InSrc = 16'h0001;
		#1 if (OutDest != 16'h0000) $display("Error in MOD operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InSrc = 16'h0002;
		#1 if (OutDest != 16'h0000) $display("Error in MOD operation at time %t",$time);


		$display ("Start of MUL tests");
		Operation = MUL;

		InDest = 16'h0000;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'h0000) $display("Error in MUL operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'h5554) $display("Error in MUL operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InSrc = 16'h0001;
		#1 if (OutDest != 16'hAAAA) $display("Error in MUL operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InSrc = 16'h0002;
		#1 if (OutDest != 16'h1554) $display("Error in MUL operation at time %t",$time);


		$display ("Start of MUH tests");
		Operation = MUH;

		InDest = 16'h0000;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'h0000) $display("Error in MUH operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InSrc = 16'hFFFF;
		#1 if (OutDest != 16'h5554) $display("Error in MUH operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InSrc = 16'h0001;
		#1 if (OutDest != 16'hAAAA) $display("Error in MUH operation at time %t",$time);

		#10 InDest = 16'hAAAA;
		InSrc = 16'h0002;
		#1 if (OutDest != 16'h1554) $display("Error in MUH operation at time %t",$time);

		// End of instruction simulation


		$display("End of tests");
	end
endmodule