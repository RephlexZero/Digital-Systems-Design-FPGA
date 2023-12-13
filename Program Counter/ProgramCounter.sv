// Author(s): Kevin Huang and Jake Stewart
// Date: 13/12/2023
// Module name: ProgramCounter
// Description: this ProgramCounter module implements a 16-bit program counter

module ProgramCounter (
    input logic Clock, Reset, LoadEnable, OffsetEnable,
    input logic signed [15:0] LoadValue,
    input logic signed [8:0] Offset,
    output logic signed [15:0] CounterValue
);
    // Synchronous Reset
    always_ff @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            CounterValue <= 0;
        end else if (LoadEnable) begin
            CounterValue <= LoadValue;
        end else if (OffsetEnable) begin
            CounterValue <= CounterValue + Offset;
        end else
            CounterValue <= CounterValue + 1;
    end
endmodule