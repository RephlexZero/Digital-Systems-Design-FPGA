// VGA controller
// Coursework activity 4
// November 2022

module VgaController
(
	input	logic	Clock,
	input	logic	Reset,
	output	logic	blank_n,
	output	logic	sync_n,
	output	logic	hSync_n,
	output	logic 	vSync_n,
	output	logic	[10:0] nextX,
	output	logic	[ 9:0] nextY
);

	// use this signal as counter for the horizontal axis 
	logic [10:0] hCount;

	// use this signal as counter for the vertical axis
	logic [ 9:0] vCount;

	// VGA timing parameters
	parameter H_DISPLAY = 800;
	parameter H_FRONT_PORCH = 56;
	parameter H_SYNC_PULSE = 120;
	parameter H_BACK_PORCH = 64;
	
	parameter V_DISPLAY = 600;
	parameter V_FRONT_PORCH = 37;
	parameter V_SYNC_PULSE = 6;
	parameter V_BACK_PORCH = 23;


	always_ff @(posedge Clock) begin
		if (Reset) begin
			hCount <= 0;
			vCount <= 0;
		end else begin
			// If we are at the end of the row, reset the horizontal counter and increment the vertical counter
			if (hCount == H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH) begin
				hCount <= 0;
				vCount <= vCount + 1;
			// If we are at the end of the screen, reset the vertical counter
			if (vCount == V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH) begin
				vCount <= 0;
			end
			// Otherwise, increment the horizontal counter
			end else begin
				hCount <= hCount + 1;
			end
		end
	end

	// Generate sync and blank signals
	assign hSync_n = (hCount < H_DISPLAY + H_FRONT_PORCH) && (hCount >= H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE);
	assign vSync_n = (vCount < V_DISPLAY + V_FRONT_PORCH) && (vCount >= V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE);
	assign sync_n = ~hSync_n || ~vSync_n;
	assign blank_n = (vCount < V_DISPLAY) && (hCount < H_DISPLAY);

	// Output next X and Y pixel positions if not in blanking period
	always_comb begin
		if (vCount < V_DISPLAY) begin
			nextY = vCount;
		end else begin
			nextY = 0;
		end
		if (hCount < H_DISPLAY) begin
			nextX = hCount;
		end else begin
			nextX = 0;
		end
	end

endmodule