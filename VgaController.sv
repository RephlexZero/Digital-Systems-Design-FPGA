// VGA controller


module VgaController
(
	input	logic 			Clock,
	input	logic			Reset,
	output	logic			blank_n,
	output	logic			sync_n,
	output	logic			hSync_n,
	output	logic 			vSync_n,
	output	logic	[11:0]	nextX,
	output	logic	[11:0]	nextY
);

	// use this signal as counter for the horizontal axis 
	logic [11:0] hCount;

	// use this signal as counter for the vertical axis
	logic [11:0] vCount;
	
	always_ff @(posedge Clock)
	begin
	// Reset signal moves back to 0,0 position
		if (Reset == 1)
		begin
			hCount <= 0;
			vCount <= 0;
		end	
	
	// Synchronisation signal for end of horizontal scan
		if (hCount > 1039)	// end of horizonal scan			
			hCount <= 0;		// back to beginning of horizonal scan
		else if (Reset == 0)
			hCount <= hCount + 1;	// increment horizontal position
	
	// Synchronisation signal for end of vertical scan
		if (hCount > 1039)	// if end of horizontal scan
		begin
			if (vCount > 665)	// and end of vertical scan
				vCount <= 0;	// return to beginning
			else
				vCount <= vCount + 1;	// otherwise increment vertical position
		end	
	end
	
	always_comb
	begin
	// Signal for blanking out when not in visible area
		blank_n = ~((hCount >= 800) || (vCount >= 600));
		
	// Horizonal/Vertical Sync pulses
		hSync_n = ~((hCount >= 856) && (hCount < 976));	// Horizontal Sync Pulse

		vSync_n = ~((vCount >= 637) && (vCount < 643));	// Vertical Sync Pulse

	// Sync Pulse
		sync_n = (~((hCount >= 856) && (hCount < 976))) || (~((vCount >= 637) && (vCount < 643)));
	
	// Output only when in visible area
		if (hCount < 800)
			nextX = hCount;
		else
			nextX = 0;
		if (vCount < 600)
			nextY = vCount;
		else
			nextY = 0;
	end	
endmodule
