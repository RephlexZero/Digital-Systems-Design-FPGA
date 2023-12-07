module ProgramCounter (
    input logic Clock, Reset, LoadEnable, OffsetEnable,
    input logic signed [15:0] LoadValue,
    input logic signed [8:0] Offset,
    output logic signed [15:0] CounterValue
);

    logic [15:0] internalCounterValue;

    // Synchronous Reset
    always_ff @(posedge Clock or posedge Reset) begin
        if (Reset)
            internalCounterValue <= 16'b0;
        else if (LoadEnable)
            internalCounterValue <= LoadValue;
        else if (OffsetEnable)
        begin
            // Check sign bit for negative Offset, decide if add or subtract.
            if (Offset[8])
                // Already a signed value, no need to use $signed()
                internalCounterValue <= internalCounterValue - Offset;
            else
                internalCounterValue <= internalCounterValue + Offset;
        end
        else
            internalCounterValue <= internalCounterValue + 1;
    end
    // Apply output
    assign CounterValue = internalCounterValue;
endmodule