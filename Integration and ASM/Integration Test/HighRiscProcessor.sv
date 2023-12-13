import InstructionSetPkg::*;

module HighRiscProcessor
(
   input      Clock,
   input      Reset,
	Bus.Master Ibus,
	Bus.Master Dbus
);
	// Interconnections
	// ALU specific interconnections
	eOperation                        OpCode;
	logic             [DataWidth-1:0] AluResult;
	logic             [DataWidth-1:0] SourceDataA;
	logic             [DataWidth-1:0] SourceDataB;
	logic signed [ImmediateWidth-1:0] ImmediateData;
	
	// Register file specific interconnections
	logic                       RfWriteEnable;
   logic  [RfAddressWidth-1:0] RegA;
   logic  [RfAddressWidth-1:0] RegB;
	logic       [DataWidth-1:0] RfReadDataA;
	logic       [DataWidth-1:0] RfReadDataB;
	
	// Progam counter specific interconnections
	logic      					      PcWriteEnable;
	logic                         PcOffsetEnable;
	logic  [MemAddressWidth-1:0]  PcAddress;
	logic signed[OffsetWidth-1:0] PcOffsetValue;
	
	// Flags specific interconnections
	logic    						 FlagsWriteEnable;
	sFlags                      Flags,NextFlags;
	
	// Data memory specific interconnections
	logic                       MemWriteEnable;
	logic       [DataWidth-1:0] WriteData;

   // Indirect data bus connections 
	assign Dbus.Address   = (OpCode == LOAD) ? SourceDataB : SourceDataA;
	assign Dbus.WriteData = SourceDataB;

	// Indirect instruction bus connections
	assign Ibus.Address     = PcAddress;
	assign Ibus.WriteData   = '0;
	assign Ibus.WriteEnable = '0;
	

	// The Arithmetic logic unit is responsible for all
   // data manipulations	
	ArithmeticLogicUnit iALU
	(
		.InDest(SourceDataA),
		.InSrc(SourceDataB),
		.Operation(OpCode),
		.OutDest(AluResult),
		.InFlags(Flags),
		.OutFlags(NextFlags),
		.InImm(ImmediateData)
	);
	
	// The data written to the register file can come from the ALU
   // or the data bus (for a load instruction)	
	assign WriteData = (OpCode == LOAD) ? Dbus.ReadData : AluResult;
	
	// The register file holds all the data values except PC, FLAGs
	// Port A is the destination port, port B is the source port
	RegisterFile iRF
	(
		.Clock,
		
		.AddressA(RegA),
		.ReadDataA(RfReadDataA),
		.WriteData,
		.WriteEnable(RfWriteEnable),
		
		.AddressB(RegB),
		.ReadDataB(RfReadDataB)
	);

	// The program counter is used to indicate the 
	// instruction to be retireved from instruction
	// memory
	ProgramCounter iPC
	(
		.Clock,
		.Reset,
		.LoadValue(WriteData),
		.LoadEnable(PcWriteEnable),
		.Offset(PcOffsetValue),
		.OffsetEnable(PcOffsetEnable),
		.CounterValue(PcAddress)
	);
	
	// This register stores the 5 flag values and can be loaded 
	// directly
	FlagsRegister #(.Width(DataWidth)) iFlags
	(
		.Clock,
		.Reset,
		.LoadValue(WriteData),
		.LoadEnable(FlagsWriteEnable),
		.NextFlags,
		.Flags
	);

	// The instruction decoder module splits the 
	// instruction into different control signals 
	// and uses the flags to decide if a JR 
	// instruction should case a jump or not.
	InstructionDecoder
	iDecoder
	(
		.Instruction(Ibus.ReadData),
		.Flags,
		.OpCode,
		.RegA,
		.RegB,
		.ImmediateData,
		.RfWriteEnable,
		.PcWriteEnable,
		.PcOffsetEnable,
		.PcOffsetValue,
		.FlagsWriteEnable,
		.MemWriteEnable(Dbus.WriteEnable)
	);
	
	// This multiplexer selects the ALU input 
	// based on the destination register
	SourceSelector 
	iAluMuxA
	(
		.SourceAddress(RegA),
		.RegisterFileData(RfReadDataA),
		.ProgramCounter(PcAddress),
		.Flags(),
		.SelectedValue(SourceDataA) 			
	);
	
	// This multiplexer selects the ALU input 
	// based on the source register
	SourceSelector 
	iAluMuxB
	(
		.SourceAddress(RegB),
		.RegisterFileData(RfReadDataB),
		.ProgramCounter(PcAddress),
		.Flags(),
		.SelectedValue(SourceDataB) 			
	);
	
endmodule




module InstructionDecoder
(
	input [DataWidth-1:0] Instruction,
	input sFlags Flags,
	output eOperation OpCode,
	output logic [RfAddressWidth-1:0] RegA,
	output logic [RfAddressWidth-1:0] RegB,
	output logic signed [ImmediateWidth-1:0] ImmediateData,
	output logic RfWriteEnable,
	output logic PcWriteEnable,
	output logic PcOffsetEnable,
	output logic signed [OffsetWidth-1:0]PcOffsetValue,
	output logic FlagsWriteEnable,
	output logic MemWriteEnable
);
	logic [7:0] ExtFlags;

	assign OpCode  = eOperation'(Instruction[OpCodeStart +: OpCodeSize]);
	assign RegA    = Instruction[RegAStart   +: RegASize];
	assign RegB    = Instruction[RegBStart   +: RegBSize];
	assign PcOffsetValue = Instruction[8:0];
	assign ExtFlags = {1'b1,~Flags.Zero,~Flags.Carry,Flags};
	
	always_comb
	begin
		RfWriteEnable    = '0;
		MemWriteEnable   = '0;
		FlagsWriteEnable = '0;
		PcWriteEnable    = '0;
		PcOffsetEnable = '0;
		
		if (OpCode == STORE) MemWriteEnable = '1;
		else if (OpCode == JR)
	   begin
			if (ExtFlags[Instruction[11:9]] == 1) PcOffsetEnable = '1;
		end
		else
		begin			
			RfWriteEnable = '1;
			
			if ({1'b1,RegA[4:0]} == SPECIAL_PC) PcWriteEnable    = RegA[5];
			if ({1'b1,RegA[4:0]} == SPECIAL_FL) FlagsWriteEnable = RegA[5];
		end
		ImmediateData = RegB;
	end

endmodule
	
	
module FlagsRegister
#(
	parameter Width = 8
)
(
   input                    Clock,
   input                    Reset,
	input [Width-1:0]        LoadValue,
	input 						 LoadEnable,
	input sFlags             NextFlags,
	output sFlags				 Flags
);

	always_ff @(posedge Clock)
	begin
		if (Reset) 
			Flags <= '{default:0};
		if (LoadEnable)
			Flags <= LoadValue[0 +: $bits(sFlags)];
		else
			Flags <= NextFlags;
	end
	
endmodule

	
module SourceSelector
(
	input  [RfAddressWidth-1:0] 	SourceAddress,
	input  [DataWidth-1:0]    	RegisterFileData,
	input  [MemAddressWidth-1:0] 	ProgramCounter,
	input  sFlags		 			Flags,
	output logic [DataWidth-1:0] 		SelectedValue 			
);

	always_comb
	begin
		case (SourceAddress)
			SPECIAL_PC: SelectedValue = ProgramCounter;
			SPECIAL_FL: SelectedValue = Flags;
			default: SelectedValue = RegisterFileData;
		endcase;
	end

	
endmodule
