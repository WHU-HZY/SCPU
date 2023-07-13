`include "ctrl_encode_def.v"
// data memory
module dm(clk, DMWr, addr, din, PC, DMType, dout);
   input          clk;
   input          DMWr;
   input  [31:2]  addr;
   input  [31:0]  din;
   input  [31:0]  PC;
   input  [2:0]   DMType;
   output [31:0]  dout;
     
   reg [31:0] dmem[8191:0]; ////
   reg [31:0] dout;

   always @(posedge clk) //时钟上升沿，写memory
      if (DMWr) begin //写使能信号
      case(DMType) //根据字长类型选择写入方式
      `dm_word:dmem[addr[31:2]] <= din; //写入4字节//字长为4字节
      `dm_halfword:dmem[addr[31:2]][15:0] <= din[15:0]; //0-1字节//字长为2字节
      `dm_byte:dmem[addr[31:2]][7:0] <= din[7:0]; //第0字节//字长为1字节
      endcase
         //打印当前写入地址和写入数据
         $display("pc = %h: dataaddr = %h, memdata = %h", PC,{addr [31:2],2'b00}, din);
      end

   always @(*)begin //异步读出memory

      //$signed()和$unsigned()这两个函数的作用是告诉编译器所修饰
      //的变量的二进制数据被当作有符号数或无符号数来处理。并不对变量数据做任何转换操作。


///
      case(DMType) //根据字长类型选择写入方式
      `dm_word: dout = dmem[addr[31:2]];//字长为4字节，单字数据，没有符号问题
      `dm_halfword: dout[15:0] <= $signed(dmem[addr[31:2]][15:0]);//字长为2字节,有符号数,在最高位赋值时都需要进行有符号数处理
      `dm_byte:dout[7:0] <= $signed(dmem[addr[31:2]][7:0]);//字长为1字节,有符号数,在最高位赋值时都需要进行有符号数处理
      `dm_halfword_unsigned:dout[15:0] <= $unsigned(dmem[addr[31:2]][15:0]);//字长为2字节,无符号数,在最高位赋值时都需要进行无符号数处理
      `dm_byte_unsigned:dout[7:0] <= $unsigned(dmem[addr[31:2]][7:0]);//字长为1字节,无符号数,在最高位赋值时都需要进行无符号数处理
      endcase
   end

endmodule    



