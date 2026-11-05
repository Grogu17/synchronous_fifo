`timescale 1ns / 1ps

module synchronous_fifo_tb();

reg clk;
reg rst;
reg wr_en;
reg rd_en;
reg [7:0] din;

wire [7:0] dout;
wire full;
wire empty;
wire [4:0] count;

// Device under test
synchronous_fifo dut (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty),
    .count(count)
);

// Clock generation
initial clk = 0;
always #5 clk = ~clk;

// Reference model
reg [7:0] model_mem [0:15];
reg [3:0] model_wr_ptr;
reg [3:0] model_rd_ptr;
integer model_count;
integer errors;
integer i;

reg [7:0] expected_dout;
reg dout_known;

// --------------------------------------------------
// One FIFO transaction and automatic checking
// --------------------------------------------------
task cycle;
    input wr;
    input rd;
    input [7:0] data_in;

    reg accept_write;
    reg accept_read;

    begin
        // Drive inputs at falling edge
        @(negedge clk);
        wr_en = wr;
        rd_en = rd;
        din = data_in;

        // Determine accepted operations using current model state
        accept_write = wr && (model_count < 16);
        accept_read  = rd && (model_count > 0);

        // Update expected data and reference model
        if (accept_read) begin
            expected_dout = model_mem[model_rd_ptr];
            dout_known = 1'b1;
        end

        if (accept_write) begin
            model_mem[model_wr_ptr] = data_in;
            model_wr_ptr = model_wr_ptr + 1'b1;
        end

        if (accept_read) begin
            model_rd_ptr = model_rd_ptr + 1'b1;
        end

        if (accept_write && !accept_read)
            model_count = model_count + 1;
        else if (!accept_write && accept_read)
            model_count = model_count - 1;

        // Wait for DUT to sample inputs
        @(posedge clk);
        #1;

        // Check occupancy
        if (count !== model_count) begin
            $display("FAIL: count expected=%0d actual=%0d at %0t",
                     model_count, count, $time);
            errors = errors + 1;
        end

        // Check status flags
        if (full !== (model_count == 16)) begin
            $display("FAIL: full incorrect at %0t", $time);
            errors = errors + 1;
        end

        if (empty !== (model_count == 0)) begin
            $display("FAIL: empty incorrect at %0t", $time);
            errors = errors + 1;
        end

        // Check pointers against reference model
        if (dut.wr_ptr !== model_wr_ptr) begin
            $display("FAIL: write pointer expected=%0d actual=%0d at %0t",
                     model_wr_ptr, dut.wr_ptr, $time);
            errors = errors + 1;
        end

        if (dut.rd_ptr !== model_rd_ptr) begin
            $display("FAIL: read pointer expected=%0d actual=%0d at %0t",
                     model_rd_ptr, dut.rd_ptr, $time);
            errors = errors + 1;
        end

        // Check output after a valid read
        if (dout_known && (dout !== expected_dout)) begin
            $display("FAIL: dout expected=%h actual=%h at %0t",
                     expected_dout, dout, $time);
            errors = errors + 1;
        end
    end
endtask

// --------------------------------------------------
// Synchronous reset
// --------------------------------------------------
task reset_fifo;
    begin
        @(negedge clk);
        rst = 1'b1;
        wr_en = 1'b0;
        rd_en = 1'b0;
        din = 8'b0;

        @(posedge clk);
        #1;

        model_wr_ptr = 0;
        model_rd_ptr = 0;
        model_count = 0;

        if (count !== 5'd0 ||
            empty !== 1'b1 ||
            full !== 1'b0 ||
            dut.wr_ptr !== 4'd0 ||
            dut.rd_ptr !== 4'd0) begin
            $display("FAIL: reset check at %0t", $time);
            errors = errors + 1;
        end

        // dout is intentionally not reset in the DUT
        if (dout_known && (dout !== expected_dout)) begin
            $display("FAIL: dout changed during reset at %0t", $time);
            errors = errors + 1;
        end

        @(negedge clk);
        rst = 1'b0;
    end
endtask

// --------------------------------------------------
// Test sequence
// --------------------------------------------------
initial begin
    rst = 0;
    wr_en = 0;
    rd_en = 0;
    din = 0;

    model_wr_ptr = 0;
    model_rd_ptr = 0;
    model_count = 0;
    errors = 0;
    expected_dout = 0;
    dout_known = 0;
    i = 0;

    $display("TEST 1: Reset");
    reset_fifo();

    $display("TEST 2: Basic writes and FIFO order");
    cycle(1, 0, 8'hA5);
    cycle(1, 0, 8'h3C);
    cycle(0, 1, 8'h00);
    cycle(0, 1, 8'h00);

    $display("TEST 3: Read while empty");
    cycle(0, 1, 8'h00);
    cycle(0, 0, 8'h00);

    $display("TEST 4: Fill FIFO");
    for (i = 0; i < 16; i = i + 1)
        cycle(1, 0, 8'h40 + i);

    $display("TEST 5: Write while full");
    cycle(1, 0, 8'hEE);

    $display("TEST 6: Simultaneous request while full");
    cycle(1, 1, 8'hDD);

    $display("TEST 7: Simultaneous read/write");
    cycle(1, 1, 8'hEE);

    $display("TEST 8: Drain FIFO");
    while (model_count > 0)
        cycle(0, 1, 8'h00);

    $display("TEST 9: Pointer wraparound");
    for (i = 0; i < 40; i = i + 1) begin
        cycle(1, 0, i);
        cycle(0, 1, 8'h00);
    end

    $display("TEST 10: Reset while non-empty");
    cycle(1, 0, 8'h91);
    cycle(1, 0, 8'h92);
    cycle(1, 0, 8'h93);
    reset_fifo();

    $display("TEST 11: Read after reset while empty");
    cycle(0, 1, 8'h00);

    $display("TEST 12: Normal operation after reset");
    cycle(1, 0, 8'hB7);
    cycle(0, 1, 8'h00);

    @(negedge clk);
    wr_en = 0;
    rd_en = 0;

    $display("-----------------------------------");
    if (errors == 0)
        $display("ALL TESTS PASSED");
    else
        $display("TESTS FAILED: %0d error(s)", errors);
    $display("-----------------------------------");

    $finish;
end

endmodule
