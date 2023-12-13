// Author(s): Kevin Huang and Jake Stewart
// Date: 13/12/2023
// Module name: HighRiscSystem
// Description: The HighRisc system module connects a HighRisc processor to memory and peripherals via separate instruction and data busses.

// The connections are (values in hex):
// Module              Address     Size  Bus
// Program Memory            0     4000   I
// Data Memory               0     4000   D
// VGA display buffer     4000     4000   D
// Switches SW0 to 9      C000        1   D
// LEDs     LED0 to 9     C200        1   D

import InstructionSetPkg::*;

module HighRiscSystem
(
   input                CLOCK_50,
   input     	 [ 3:0]  KEY,
	input        [ 9:0]	SW,
	output logic [ 9:0]	LEDR,
	output logic 			VGA_CLK,
	output logic 			VGA_BLANK_N,
	output logic 			VGA_SYNC_N,
	output logic 			VGA_HS,
	output logic 			VGA_VS,
	output logic [ 7:0] 	VGA_R,
	output logic [ 7:0] 	VGA_G,
	output logic [ 7:0] 	VGA_B
);

	logic [15:0] LEDs;
	logic Reset;
	logic Clock;
	 
	assign Clock   = CLOCK_50;
	assign VGA_CLK = ~CLOCK_50;
	assign Reset   = ~KEY[0];
	assign LEDR    = LEDs[9:0];

   Bus #(1,0) Ibus();
	Bus #(2,2) Dbus();

	HighRiscProcessor iProcesor (.*);

	ProgramMemory iProgramMemory 
	(
		.Clock,
		.TheBus(Ibus.Block16k[0].Slave)
	);
	
	DataMemory iDataMemory 
	(
		.Clock,
		.TheBus(Dbus.Block16k[0].Slave)
	);

	BusInPort iI
	(
		.Clock,
		.TheBus(Dbus.Block512[0].Port),
		.BusPort({6'd0,SW})
	);
	
	BusOutPort iO
	(
		.Clock,
		.TheBus(Dbus.Block512[1].Port),
		.BusPort(LEDs)
	);


	VgaSystem iVga
	(
		.CLOCK_50,
		.Reset,
		.VGA_BLANK_N,
		.VGA_SYNC_N,
		.VGA_HS,
		.VGA_VS,
		.VGA_R,
		.VGA_G,
		.VGA_B,
		
		.TheBus(Dbus.Block16k[1].Slave)		
	);

endmodule



// The Bus interface is used to connect the processor to 
// memories and memory mapped peripherals.
interface Bus
#( 
   // The blocks parameter can be 0 to 3. It indicates the 
	// number of 16k word block slave modports that can be 
	// used.
	parameter Blocks = 0,
	
	// The ports parameter can be 0 to 32. It indicates the 
	// number of 512 word block slave modports that can be 
	// used.
	parameter Ports = 0
)
();
	// Basic bus connections
	logic [AddressWidth-1:0] Address;
	logic [DataWidth-1:0]    ReadData;
	logic [DataWidth-1:0]    WriteData;
	logic                    WriteEnable;

	// 16k word block connections
	logic [13:0]             SlaveAddress;
	logic [DataWidth-1:0] 	 SlaveReadData [4];
	logic [Blocks-1:0]       SlaveWriteEnable;
	logic [1:0]              BlockInUse;
	
	// 512 word block connections
	logic [8:0]              PortAddress;
	logic [DataWidth-1:0] 	 PortReadData [32];
	logic [Ports-1:0]        PortWriteEnable;	
	logic [4:0]              PortInUse;
	
	// The master controls writes and the address
   modport Master 
	(
		output Address,
		input  ReadData,
		output WriteData,
		output WriteEnable
	);
	
	// Up to 3 16k word block modports are created
	// unused blocks have zeros inserted as thier return values
	generate
	genvar i;
	   // Create the correct number of 16k word blocks
		for (i=0;i<Blocks;i++)
		begin: Block16k
			modport Slave
			(
				input  SlaveAddress,
				output .ReadData(SlaveReadData[i]),
				input  WriteData,
				input  .WriteEnable(SlaveWriteEnable[i])
			);
		end
		
		// Handle unused blocks gracefully
		for (i=Blocks;i<3;i++) 
		begin: BlockDefaults
			assign SlaveReadData[i] = '0;
		end
	endgenerate
	
	always_comb
	begin
	   // Extract sectiosn fo the address
		BlockInUse = Address[AddressWidth-1:AddressWidth-2];
		SlaveAddress = Address[AddressWidth-3:0];
		
		// Pass back data to the master based on the address selected.
		ReadData = SlaveReadData[BlockInUse];
		
		// Create a single write enable signal based on the address
		SlaveWriteEnable = '0;
		SlaveWriteEnable[BlockInUse] = WriteEnable;
	end
	
	generate
	genvar j;
	   // Create the correct number of 512 word blocks
		for (j=0;j<Ports;j++)
		begin: Block512
			modport Port
			(
				input  PortAddress,
				output .ReadData(PortReadData[j]),
				input  WriteData,
				input  .WriteEnable(PortWriteEnable[j])
			);
		end

		// Handle unused blocks gracefully
		for (i=Ports;i<32;i++) 
		begin: PortDefaults
			assign PortReadData[i] = '0;
		end
	endgenerate
	
	always_comb
	begin
	   // Extract sections of the address
		PortInUse = Address[AddressWidth-3:AddressWidth-7];
	   PortAddress = Address[AddressWidth-8:0];
		
		// Create a single write enable signal based on the address
		PortWriteEnable = '0;
		PortWriteEnable[PortInUse] = WriteEnable & &Address[AddressWidth-1:AddressWidth-2];
		
		// Feed the read result back as the last 16k word block
		SlaveReadData[3] = PortReadData[PortInUse];
	end
	 
endinterface
	

// The VgaSystem module instantiates the VGA controller with a dual port RAM to permit
// a display to be produced and modified by the processor.
module VgaSystem
(
	input CLOCK_50,
	input Reset,
	output logic        VGA_BLANK_N,
	output logic        VGA_SYNC_N,
	output logic        VGA_HS,
	output logic        VGA_VS,
	output logic [ 7:0] VGA_R,
	output logic [ 7:0] VGA_G,
	output logic [ 7:0] VGA_B,
	
	interface TheBus
);
   // A memory block
	logic [15:0] VgaRam [16384];
	
	// Signals used to extract the individual pixel value from the VGA memory
	logic [15:0] PixelPair;
	logic [ 7:0] Pixel;
	logic [10:0] nextX;
	logic [ 9:0] nextY;

	// Instantiate the module designed by the student to generate VGA 
	// control signals.
	// The VGA controller is expected to produce an 800x600 VESA comaptible
   //	signal and this is effectively downsampled to produce a 200x150 display.
	VgaController iControl
	(
		.Clock(CLOCK_50),
		.Reset,
		.blank_n(VGA_BLANK_N),
		.sync_n(VGA_SYNC_N),
		.hSync_n(VGA_HS),
		.vSync_n(VGA_VS),
		.nextX,
		.nextY
	);

	// Create a dual port memory that can be read or written over the bus
	// and can be simultaneously read to get pixels for the screen. Pixels 
	// take one byte each and are stored in pairs so that one row of pixels 
	// takes 100 memory locations and the whole screen is 15000 memory 
	// locations.
	always_ff @(posedge CLOCK_50)
	begin
		TheBus.ReadData = VgaRam[TheBus.SlaveAddress];
		if (TheBus.WriteEnable)	VgaRam[TheBus.SlaveAddress] <= TheBus.WriteData;
			
		if( nextX >= 11'd0 && nextX <= 11'd799 )
			begin
				if( nextY >= 10'd8 && nextY <= 10'd599 )
					begin
					PixelPair <= VgaRam[(nextX[10:2]*75)+nextY[9:3]];
					end
			end			
	end

	
	// Split the value read from the memory to get the correct pixel byte.
	// The pixel is stored as RRRGGGBB format (i.e 3 bit red value, 3 bit
	// green value, 2 bit blue value).
	always_comb
	begin
		Pixel = PixelPair[((nextY[0])?15:7) -:8];
		VGA_R = {{2{Pixel[7 -:3]}},2'b00};
		VGA_G = {{2{Pixel[4 -:3]}},2'b00};
		VGA_B =  {4{Pixel[1 -:2]}};
	end

endmodule



// The BusinPort module continuously prodvides the bus
// with a value from the input port.
module BusInPort
(
	input logic Clock,
	interface   TheBus,
	input [DataWidth-1:0] BusPort
);

	// Asynchronous read
	always_comb
	begin
			TheBus.ReadData = BusPort;
	end
	
endmodule



// The BusOutPort module registers enabled writes on the 
// bus to the appropriate address.
module BusOutPort
(
	input logic Clock,
	interface   TheBus,
	output logic [DataWidth-1:0] BusPort
);

	// Synchronous write
	always_ff @(posedge Clock)
	begin
			if (TheBus.WriteEnable) BusPort <= TheBus.WriteData;
	end
	
	// No input so the ReadData defaults to zero
	assign TheBus.ReadData = '0;
	
endmodule



// The ProgamMemory module is a wrapper that allows the bus
// interface to be connected to an Altera IP memory block.
// This module can be loaded using the In-System Memory 
// Content Editor and is identified as PROG
module ProgramMemory
(
	input logic Clock,
	interface   TheBus
);
	RomBlock iRom(
		.address(TheBus.SlaveAddress),
		.clock(Clock),
		.q(TheBus.ReadData)
	);
	
endmodule



// The DataMemory module is a wrapper that allows the bus
// interface to be connected to an Altera IP memory block
// This module can be loaded using the In-System Memory 
// Content Editor and is identified as DATA
module DataMemory
(
	input logic Clock,
	interface   TheBus
);
	RAM iRAM(
		.address(TheBus.SlaveAddress),
		.clock(Clock),
		.data(TheBus.WriteData),
		.wren(TheBus.WriteEnable),
		.q(TheBus.ReadData)
	);
endmodule

