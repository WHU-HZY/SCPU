`include "ctrl_encode_def.v"
// data memory
module dm(clk, DMWr, addr, din, pc, DMType, ByteSel, dout);
   input          clk;
   input          DMWr;
   input  [31:2]  addr;
   input  [31:0]  din;
   input  [31:0]  pc;
   input  [2:0]   DMType;
   input  [1:0]   ByteSel;
   output [31:0]  dout;
     
   reg [31:0] dmem[127:0];
   reg [31:0] dout;

   always @(posedge clk) //时钟上升沿，写memory
      if (DMWr) begin //写使能信号
      case(DMType) //根据字长类型选择写入方式
      `dm_word://字长为4字节
         case(ByteSel)
         2'b00: dmem[addr[31:2]] <= din; //写入4字节

         2'b01: dmem[addr[31:2]][31:8] <= din[23:0]; //写入高3字节
                dmem[addr[31:2] + 1][7:0] <= din[31:24];//写入低1字节

         2'b10: dmem[addr[31:2]][31:16] <= din[15:0]; //写入高2字节
                dmem[addr[31:2] + 1][15:0] <= din[31:16];//写入低2字节

         2'b11: dmem[addr[31:2]][31:24] <= din[7:0]; //写入高1字节
                dmem[addr[31:2] + 1][23:0] <= din[31:8];//写入低3字节
         endcase
      `dm_half://字长为2字节
         case(ByteSel)
         2'b00: dmem[addr[31:2]][15:0] <= din[15:0]; //0-1字节
         
         2'b01: dmem[addr[31:2]][23:8] <= din[15:0]; //1-2字节

         2'b10: dmem[addr[31:2]][31:16] <= din[15:0]; //2-3字节

         2'b11: dmem[addr[31:2]][31:24] <= din[7:0]; //第3字节
                dmem[addr[31:2] + 1][7:0] <= din[15:8];//第3字节

         endcase
      `dm_byte://字长为1字节
         case(ByteSel)
         2'b00: dmem[addr[31:2]][7:0] <= din[7:0]; //第0字节
         2'b01: dmem[addr[31:2]][15:8] <= din[7:0]; //第1字节
         2'b10: dmem[addr[31:2]][23:16] <= din[7:0]; //第2字节
         2'b11: dmem[addr[31:2]][31:24] <= din[7:0]; //第3字节
         endcase
      endcase

         //打印当前写入地址和写入数据
         $display("pc = %h: dataaddr = %h, memdata = %h", pc,{addr [31:2],2'b00}, din);
      end

   always @(*)begin //异步读出memory
      case(DMType) //根据字长类型选择写入方式
      `dm_word://字长为4字节
          dout = dmem[addr[31:2]];
      
      endcase
   end

endmodule    
