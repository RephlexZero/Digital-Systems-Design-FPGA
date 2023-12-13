// Author(s): Kevin Huang and Jake Stewart
// Date: 13/12/2023
// Module name: ArithemeticLogicUnit
// Description: Implementation of all essential ALU operations through the use of a case statement

// Load information about the instruction set. 
import InstructionSetPkg::*;

// Define the connections into and out of the ALU.
module ArithmeticLogicUnit
(
	// The Operation variable is an example of an enumerated type and
	// is defined in InstructionSetPkg.
	input eOperation Operation,
	
	// The InFlags and OutFlags variables are examples of structures
	// which have been defined in InstructionSetPkg. They group together
	// all the single bit flags described by the Instruction set.
	input  sFlags    InFlags,
	output sFlags    OutFlags,
	
	// All the input and output busses have widths determined by the 
	// parameters defined in InstructionSetPkg.
	input  signed [ImmediateWidth-1:0] InImm,
	
	// InSrc and InDest are the values in the source and destination
	// registers at the start of the instruction.
	input  signed [DataWidth-1:0] InSrc,
	input  signed [DataWidth-1:0] InDest,
	
	// OutDest is the result of the ALU operation that is written 
	// into the destination register at the end of the operation.
	output logic signed [DataWidth-1:0] OutDest
);

	// This block allows each OpCode to be defined. Any opcode not
	// defined outputs a zero. The names of the operation are defined 
	// in the InstructionSetPkg. 
	always_comb
	begin
	
		// By default the flags are unchanged. Individual operations
		// can override this to change any relevant flags.
		OutFlags  = InFlags;
		
		// The basic implementation of the ALU only has the NAND and
		// ROL operations as examples of how to set ALU outputs 
		// based on the operation and the register / flag inputs.
		case(Operation)		
		
			ROL:     {OutFlags.Carry,OutDest} = {InSrc,InFlags.Carry};	
			
			NAND:    OutDest = ~(InSrc & InDest);

			LIL:	 OutDest = InImm;

			LIU:
				begin
					if (InImm[ImmediateWidth - 1] ==  1)
						OutDest = {InImm[ImmediateWidth - 2:0], InDest[ImmediateHighStart - 1:0]};
					else if  (InImm[ImmediateWidth - 1] ==  0)	
						OutDest = {InImm[ImmediateWidth - 2:0], InDest[ImmediateMidStart - 1:0]};
					else
						OutDest = InDest;	
				end


			// ***** ONLY CHANGES BELOW THIS LINE ARE ASSESSED *****
			// Put your instruction implementations here.

			MOVE:	OutDest = InSrc;

			NOR:	OutDest = ~(InSrc | InDest);

			ROR:	{OutDest, OutFlags.Carry} = {InFlags.Carry, InSrc};

			ADC:	begin
					// Take most significant bits of inputs and output
					automatic logic msb_in_src = InSrc[DataWidth-1];
					automatic logic msb_in_dest = InDest[DataWidth-1];
					automatic logic msb_out_dest = OutDest[DataWidth-1];

					OutDest = InSrc + InDest + InFlags.Carry;

					OutFlags.Zero = OutDest == 0;
					OutFlags.Negative = OutDest < 0;
					OutFlags.Carry = (OutDest < InSrc) || (OutDest < InDest);
					OutFlags.Parity = ~^OutDest;
					OutFlags.Overflow = (~msb_out_dest & msb_in_src & msb_in_dest) | (msb_out_dest & ~msb_in_src & ~msb_in_dest);
				end

			SUB:	begin
					// Take most significant bits of inputs and output
					automatic logic msb_in_src = InSrc[DataWidth-1];
					automatic logic msb_in_dest = InDest[DataWidth-1];
					automatic logic msb_out_dest = OutDest[DataWidth-1];


					OutDest = InDest - (InSrc + InFlags.Carry);

					OutFlags.Zero = OutDest == 0;
					OutFlags.Negative = OutDest < 0;
					OutFlags.Carry = InDest < (InSrc + InFlags.Carry);
					OutFlags.Parity = ~^OutDest;
					OutFlags.Overflow = (~msb_out_dest & ~msb_in_src & msb_in_dest) | (msb_out_dest & msb_in_src & ~msb_in_dest);
				end

			DIV:	begin
					// Check for divide by zero
					if (InSrc != 0) begin
						OutDest = InDest / InSrc;

						OutFlags.Zero = OutDest == 0;
						OutFlags.Negative = OutDest < 0;
						OutFlags.Parity = ~^OutDest;
					end else begin
						OutDest = 0;
						
						OutFlags.Zero = 1;
						OutFlags.Negative = 0;
						OutFlags.Parity = 1;
					end
				end

			MOD:	begin
					OutDest = InDest % InSrc;

					OutFlags.Zero = OutDest == 0;
					OutFlags.Negative = OutDest < 0;
					OutFlags.Parity = ~^OutDest;
				end

			MUL:	begin
					OutDest = InDest * InSrc;

					OutFlags.Zero = OutDest == 0;
					OutFlags.Negative = 0;
					OutFlags.Parity = ~^OutDest;
				end

			MUH:	begin
					OutDest = (InDest * InSrc) >> DataWidth;

					OutFlags.Zero = OutDest == 0;
					OutFlags.Negative = OutDest < 0;
					OutFlags.Parity = ~^OutDest;
				
				end
			
			// ***** ONLY CHANGES ABOVE THIS LINE ARE ASSESSED	*****		
			
			default:	OutDest = '0;
			
		endcase;

	end

endmodule
