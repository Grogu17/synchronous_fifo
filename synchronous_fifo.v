`timescale 1ns / 1ps

module synchronous_fifo(clk,rst,wr_en,rd_en,din,dout,full,empty,count);
input clk;
input rst;
input wr_en;
input rd_en;
input [7:0]din;
output reg [7:0]dout;
output full;
output empty;
output reg [4:0]count;

reg [7:0]memory [0:15];
reg [3:0]wr_ptr;
reg [3:0]rd_ptr;

assign full  = (count == 16);
assign empty = (count == 0);

always @(posedge clk) begin
  if(rst) begin
    count<=5'b0;
    wr_ptr<=4'b0;
    rd_ptr<=4'b0;
  end
  else begin
    if(wr_en && (~full) && rd_en && (~empty)) begin
      memory[wr_ptr]<=din;
      wr_ptr<=wr_ptr+1'b1;
      dout<=memory[rd_ptr];
      rd_ptr<=rd_ptr+1'b1;
    end

    else if(wr_en && (~full)) begin
      memory[wr_ptr]<=din;
      wr_ptr<=wr_ptr+1'b1;
      count<=count+1'b1;
    end

    else if(rd_en && (~empty)) begin
      dout<=memory[rd_ptr];
      rd_ptr<=rd_ptr+1'b1;
      count<=count-1'b1;
    end
  end
end

endmodule
