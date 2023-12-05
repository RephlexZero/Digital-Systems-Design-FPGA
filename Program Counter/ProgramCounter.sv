module ProgramCounter (
    input logic Clock, Reset, LoadEnable, OffsetEnable,
    input logic [15:0] LoadValue,
    input logic [8:0] Offset,
    output logic [15:0] CounterValue
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
                // Length of internalCounterValue is 16 bits, so we need to pad Offset with 7 zeros.
                internalCounterValue <= internalCounterValue - {{7{1'b0}}, Offset};
            else
                internalCounterValue <= internalCounterValue + {{7{1'b0}}, Offset};
        end
        else
            internalCounterValue <= internalCounterValue + 1;
    end
    // Apply output
    assign CounterValue = internalCounterValue;
endmodule