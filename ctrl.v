// `include "ctrl_encode_def.v"

//123
module ctrl(Op, Funct7, Funct3, Zero, 
            RegWrite, MemWrite,
            EXTOp, ALUOp, NPCOp, 
            ALUSrc, GPRSel, WDSel,DMType
            );
            
   input  [6:0] Op;       // opcode
   input  [6:0] Funct7;    // funct7
   input  [2:0] Funct3;    // funct3
   input        Zero;
   
   output       RegWrite; // control signal for register write
   output       MemWrite; // control signal for memory write
   output [5:0] EXTOp;    // control signal to signed extension
   output [4:0] ALUOp;    // ALU opertion
   output [2:0] NPCOp;    // next pc operation
   output       ALUSrc;   // ALU source for A
	 output [2:0] DMType;
   output [1:0] GPRSel;   // general purpose register selection
   output [1:0] WDSel;    // (register) write data selection
   

  // the definition of all the instructions

  // r format
    wire rtype  = ~Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0110011
    wire i_add  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // add 0000000 000
    wire i_sub  = rtype& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sub 0100000 000
    wire i_or   = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]&~Funct3[0]; // or 0000000 110
    wire i_and  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]& Funct3[0]; // and 0000000 111
  // r format added by me
    wire i_xor = rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&Funct3[2]& ~Funct3[1]& ~Funct3[0]; // xor 0000000 100
    wire i_sll = rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& ~Funct3[1]&~Funct3[0]; // sll 0000000 001
    wire i_sra = rtype&Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& ~Funct3[1]&~Funct3[0]; // sra 0100000 101
    wire i_srl = rtype&Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& ~Funct3[1]&~Funct3[0]; // srl 0000000 101
    wire i_slt = rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& Funct3[1]&~Funct3[0]; // slt 0000000 010
    wire i_sltu = rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& Funct3[1]& Funct3[0]; // sltu 0000000 011

  // i format
    wire itype_l  = ~Op[6]&~Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0000011

  // i format
    wire itype_r  = ~Op[6]&~Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0010011
    wire i_addi  =  itype_r& ~Funct3[2]& ~Funct3[1]& ~Funct3[0]; // addi 000
    wire i_ori  =  itype_r& Funct3[2]& Funct3[1]&~Funct3[0]; // ori 110
  // i format added by me  
    wire i_xori = itype_r& Funct3[2]& ~Funct3[1]& ~Funct3[0];// xori 100 要写回寄存器，要用到立即数，不需要写回内存 ALUOp 5'b01100 NPC_PLUS4
    wire i_andi = itype_r& Funct3[2]& Funct3[1]& Funct3[0];// andi 111 要写回寄存器，要用到立即数，不需要写回内存 ALUOp 5'b01110 NPC_PLUS4
    wire i_srai = itype_r& Funct7[6]& ~Funct7[5]& ~Funct7[4]& ~Funct7[3]& ~Funct7[2]& ~Funct7[1]& ~Funct7[0]& Funct3[2]& ~Funct3[1]& ~Funct3[0];// srai 0100000 101
    wire i_srli = itype_r& ~Funct7[6]& ~Funct7[5]& ~Funct7[4]& ~Funct7[3]& ~Funct7[2]& ~Funct7[1]& ~Funct7[0]& Funct3[2]& ~Funct3[1]& ~Funct3[0];// srli 0000000 101
    wire i_slli = itype_r& ~Funct7[6]& ~Funct7[5]& ~Funct7[4]& ~Funct7[3]& ~Funct7[2]& ~Funct7[1]& ~Funct7[0]& ~Funct3[2]& ~Funct3[1]& ~Funct3[0];// slli 0000000 001
    wire i_slti = itype_r& ~Funct3[2]& Funct3[1]& ~Funct3[0];// slti 010
    wire i_sltiu = itype_r& ~Funct3[2]& Funct3[1]& Funct3[0];// sltiu 011

  //  jalr
	  wire i_jalr =Op[6]&Op[5]&~Op[4]&~Op[3]&Op[2]&Op[1]&Op[0];//jalr 1100111

  // s format
    wire stype  = ~Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//0100011
    wire i_sw   =  stype& ~Funct3[2]& Funct3[1]&~Funct3[0]; // sw 010

  // sb format
    wire sbtype  = Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//1100011
    wire i_beq  = sbtype& ~Funct3[2]& ~Funct3[1]&~Funct3[0]; // beq
	
  // j format
    wire i_jal  = Op[6]& Op[5]&~Op[4]& Op[3]& Op[2]& Op[1]& Op[0];  // jal 1101111

  // u format
    wire utype  = ~Op[6]&~Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0010111
    wire i_lui  = utype& ~Funct3[2]& ~Funct3[1]&~Funct3[0]; // lui 011
    wire i_auipc  = utype& ~Funct3[2]& Funct3[1]&~Funct3[0]; // auipc 010


  // generate control signals
  assign RegWrite   = rtype | itype_r | i_jalr | i_jal | utype; // register write
  assign MemWrite   = stype;                           // memory write
  assign ALUSrc     = itype_r | stype | i_jal | i_jalr;   // ALU B is from instruction immediate



  // signed extension (several methods to extend the immediate numbers)
  // EXT_CTRL_ITYPE_SHAMT 6'b100000
  // EXT_CTRL_ITYPE	      6'b010000
  // EXT_CTRL_STYPE	      6'b001000
  // EXT_CTRL_BTYPE	      6'b000100
  // EXT_CTRL_UTYPE	      6'b000010
  // EXT_CTRL_JTYPE	      6'b000001
  assign EXTOp[5]  = i_srai|i_srli|i_slli; 
  assign EXTOp[4]  = i_ori | i_andi | i_jalr | i_xori | i_addi | i_slti | i_sltiu;  
  assign EXTOp[3]  = stype; 
  assign EXTOp[2]  = sbtype; 
  assign EXTOp[1]  = 0;   
  assign EXTOp[0]  = i_jal;         
  
  
  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10
  // WDSel_FromIM  2'b11 我新加的一个寄存器写入选项，用于lui指令，写入数据可能直接来自于生成的立即数
  assign WDSel[0] = itype_l | i_lui;
  assign WDSel[1] = i_jal | i_jalr| i_lui;

  // NPC_PLUS4   3'b000
  // NPC_BRANCH  3'b001
  // NPC_JUMP    3'b010
  // NPC_JALR	   3'b100
  assign NPCOp[0] = sbtype & Zero;
  assign NPCOp[1] = i_jal;
	assign NPCOp[2] = i_jalr;
  

// `define ALUOp_nop 5'b00000
// `define ALUOp_lui 5'b00001
// `define ALUOp_auipc 5'b00010
// `define ALUOp_add 5'b00011
// `define ALUOp_sub 5'b00100
// `define ALUOp_bne 5'b00101
// `define ALUOp_blt 5'b00110
// `define ALUOp_bge 5'b00111
// `define ALUOp_bltu 5'b01000
// `define ALUOp_bgeu 5'b01001
// `define ALUOp_slt 5'b01010
// `define ALUOp_sltu 5'b01011
// `define ALUOp_xor 5'b01100
// `define ALUOp_or 5'b01101
// `define ALUOp_and 5'b01110
// `define ALUOp_sll 5'b01111
// `define ALUOp_srl 5'b10000
// `define ALUOp_sra 5'b10001

	assign ALUOp[0] = itype_l|stype|i_addi|i_ori|i_add|i_or|i_sll|i_sra|i_sltu|i_slli|i_srai|i_sltiu;
	assign ALUOp[1] = itype_l|stype|i_addi|i_add|i_and|i_andi|i_sll|i_slt|i_sltu|i_slli|i_slti|i_sltiu;
	assign ALUOp[2] = i_andi|i_and|i_ori|i_or|i_beq|i_sub|i_xor|i_xori|i_sll|i_slli;
	assign ALUOp[3] = i_andi|i_and|i_ori|i_or|i_xor|i_xori|i_sll|i_slt|i_sltu|i_slli|i_slti|i_sltiu;
	assign ALUOp[4] = i_sra|i_srl|i_srai|i_srli;

endmodule
