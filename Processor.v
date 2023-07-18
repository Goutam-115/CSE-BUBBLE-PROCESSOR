// In this code, you can add the array values from address 0 to address n-1 in the data memory(There are n elements in the array).
// As our memeory size is 256, we assumed to have the maximum value of n as 255.
// At the address (address 255), we will store the value of n (i.e. size of array to be sorted).
// We have initialised the temporary registers to zero.
// Our register number 0 is assigned value zero (as $zero) in mips.
// To read the value of the n, we have initialised the size address at $t9

module finalcsebubble(clk);
   input clk;
   reg [7:0] pc;
   wire [31:0] ins_curr;
   wire [7:0] newpc;
    reg [31:0] re [31:0];
    initial begin
    pc=8'b00000000; // initialized PC to zero
    re[0]=   32'd0;  
    re[9]=   32'd1;  
    re[10] = 32'd0;
    re[11] = 32'd0;
    re[12] = 32'd0;
    re[13] = 32'd0;
    re[14] = 32'd0;
    re[15] = 32'd0;
    re[16] = 32'd0;
    re[17] = 32'd0;
    re[18] = 32'd0;
    re[19] = 32'd255;
    datain = 32'd0;
    end

   wire branch_taken;
   wire write_enable;
   reg [31:0] datain;
   wire [31:0] dataout;
   wire mem_mode;
   wire [7:0] mem_address;
   veda_memory_ins v1(clk,1'b0,1'b0,pc,1'b1,0,ins_curr);
   branch_control b1(ins_curr,re[{27'b0,ins_curr[25:21]}],re[{27'b0,ins_curr[20:16]}],branch_taken);
   change_pc cpc1(branch_taken,ins_curr,pc,newpc);
   wire [31:0] curr_result;
   alu alu1(ins_curr,re[{27'b0,ins_curr[25:21]}],re[{27'b0,ins_curr[20:16]}],curr_result);
   write_control wc(ins_curr,write_enable);
   assign mem_mode = (ins_curr[31:26] == 6'b 010010) ? 1'b0 : 1'b1;
   assign mem_address= (re[ins_curr[20:16]][7:0]+ins_curr[7:0]);
   veda_memory_data v2(clk,1'b0,write_enable,mem_address,mem_mode,datain,dataout);
   wire [1:0] cur_type;
   ins_type it1(ins_curr,cur_type);
   always@(posedge clk)
       begin
        $display(pc);
          if(cur_type==2'b00)
           begin
             re[{27'b0,ins_curr[15:11]}]=curr_result;
           end
          else if(cur_type==2'b01)
            begin
              if(ins_curr[31:26]==6'b010001) //lw
                begin
                  re[{27'b0,ins_curr[25:21]}] = dataout;
                end
              else if(ins_curr[31:26]==6'b010010)  //sw
                begin
                  datain = re[{27'b0,ins_curr[25:21]}];
                end
            end
          pc=newpc;
       end
endmodule

// module for write control
module write_control(ins,write_enable);
  input [31:0] ins;
  output write_enable;
  assign write_enable = (ins[31:26] == 6'b000001) ? 1 :
                        (ins[31:26] == 6'b001011) ? 1 :  
                        (ins[31:26] == 6'b001100) ? 1 :  
                        (ins[31:26] == 6'b001101) ? 1 :  
                        (ins[31:26] == 6'b001110) ? 1 :  
                        (ins[31:26] == 6'b001111) ? 1 :  
                        (ins[31:26] == 6'b010000) ? 1 :  
                        (ins[31:26] == 6'b010001) ? 1 :  
                        (ins[31:26] == 6'b010010) ? 1 :  
                        0;              
endmodule

// instruction memory module
module veda_memory_ins(clk,rst,write_enable,address,mode,datain,dataout);
  input clk,rst,write_enable,mode;
  input wire [7:0] address;
  input wire [31:0] datain;
  output wire [31:0] dataout;
  reg [31:0] memory [255:0];

  initial begin
    memory[0] = 32'b010001_01011_10011_0000000000000000; 
    memory[1] = 32'b000001_01011_01001_01011_00000_100001;
    memory[2] = 32'b000010_00000000000000000000000101;
    memory[5] = 32'b010011_01011_00000_0000000000010110;
    memory[6] = 32'b000001_00000_00000_01100_00000_100000;
    memory[7] = 32'b000001_00000_01100_01100_00000_100000;
    memory[8] = 32'b010111_01100_01011_0000000000001011;
    memory[9] = 32'b000001_01011_01001_01011_00000_100001;
    memory[10]= 32'b000010_00000000000000000000000101;
    memory[11]= 32'b000001_00000_01100_01101_00000_100000;
    memory[12]= 32'b000001_01010_01101_01101_00000_100000;
    memory[13]= 32'b010001_01110_01101_0000000000000000;
    memory[14]= 32'b000001_01001_01100_01111_00000_100000;
    memory[15]= 32'b000001_00000_01111_01111_00000_100000;
    memory[16]= 32'b000001_01010_01111_01111_00000_100000;
    memory[17]= 32'b010001_10000_01111_0000000000000000;
    memory[18]= 32'b000001_01001_01100_01100_00000_100000;
    memory[19]= 32'b011000_01110_10000_0000000000000111; 
    memory[20]= 32'b010010_01110_01111_0000000000000000;
    memory[21]= 32'b010010_10000_01101_0000000000000000;
    memory[22]= 32'b000010_00000000000000000000000111;    
  end
  assign dataout = (write_enable & (~mode)) ? datain : memory[address];
  always@(posedge clk, rst)
    begin
      if(rst) for(integer i=0;i<32;i=i+1) memory[i] <= 32'b0;            
      else if(write_enable && ~mode)
        begin
          memory[address] <= datain;
        end    
    end 
endmodule

// data memory module
module veda_memory_data(clk,rst,write_enable,address,mode,datain,dataout);
  input clk,rst,write_enable,mode;
  input wire [7:0] address;
  input wire [31:0] datain;
  output wire [31:0] dataout;
  reg [31:0] memory [255:0];
  initial begin
  memory[0]=32'd5;
  memory[1]=32'd71;
  memory[2]=32'd2354;
  memory[3]=32'd63;
  memory[4]=32'd5;
  memory[5]=32'd14;
  memory[6]=32'd100;
  memory[7]=32'd17;
  memory[8]=32'd9;
  memory[9]=32'd75;
  memory[10]=32'd298;
  memory[11]=32'd7755;
  memory[12]=32'd234;
  memory[13]=32'd14;
  memory[14]=32'd4784;
  memory[15]=32'd69;
  memory[255]=32'd16;
  end
  assign dataout = (write_enable & (~mode)) ? datain : memory[address];
  always@(posedge clk, rst)
    begin
      if(rst) for(integer i=0;i<32;i=i+1) memory[i] <= 32'b0;            
      else if(write_enable && ~mode)
        begin
          memory[address] <= datain;
        end    
      $display(memory[0]);
      $display(memory[1]);
      $display(memory[2]);
      $display(memory[3]);
      $display(memory[4]);
      $display(memory[5]);
      $display(memory[6]);
      $display(memory[7]);
      $display(memory[8]);
      $display(memory[9]);
      $display(memory[10]);
      $display(memory[11]);
      $display(memory[12]);
      $display(memory[13]);
      $display(memory[14]);
      $display(memory[15]);
    end 
endmodule

// alu module
module alu(ins,a,b,result);
    input [31:0] ins,a,b;
    output [31:0] result;
    wire [5:0] op=ins[31:26];
    wire [5:0] funct= ins[5:0];

    assign result = ({op,funct} == 12'b000001100000 || {op,funct} == 12'b000001100010) ? (a+b) : 
                    ({op,funct} == 12'b000001100001 || {op,funct} == 12'b000001100011) ? (a-b) :
                    ({op,funct} == 12'b000001100100) ? (a&b) :
                    ({op,funct} == 12'b000001100101) ? (a|b) :
                    ({op,funct} == 12'b000001100110) ? (a<b) :
                    ({op,funct} == 12'b000001101000) ? (a<<ins[10:6]) :
                    ({op,funct} == 12'b000001101001) ? (a>>ins[10:6]) :
                    (op == 6'b001011) ? (b+{16'b0,ins[15:0]}) :
                    (op == 6'b001100) ? (b+{16'b0,ins[15:0]}) :
                    (op == 6'b001101) ? (b&{16'b0,ins[15:0]}) :
                    (op == 6'b001110) ? (b|{16'b0,ins[15:0]}) :
                    (op == 6'b001111) ? (b<{16'b0,ins[15:0]}) :
                    0;

endmodule

// branch control module
module branch_control (ins,a,b,branch);
    input [31:0] ins;
    input [31:0] a,b;
    wire [5:0] opcode;
    assign opcode= ins[31:26];
    output branch;    
                    // branch operation for beq
    assign branch = (opcode == 6'b010011 && a == b) ? 1 :
                    // branch operation for bne
                    (opcode == 6'b010100 && a != b) ? 1 :
                    // branch operation for bgt
                    (opcode == 6'b010101 && a > b) ? 1 :
                    // branch operation for bgte
                    (opcode == 6'b010110 && a >= b) ? 1 :
                    // branch operation for ble
                    (opcode == 6'b010111 && a < b) ? 1 :
                    // branch operation for bleq
                    (opcode == 6'b011000 && a <= b) ? 1 :
                    // Unconditional Jump
                    (opcode == 6'b000010) ? 1 :
                    // Jump return address
                    (opcode == 6'b000011) ? 1 :
                    // jal
                    (opcode == 6'b000100) ? 1 :
                    // Default case
                    0;              
endmodule

// module to update value of PC
module change_pc(branch_taken,ins,pc,temp);
     input branch_taken;
     input [7:0] pc;
     input [31:0] ins;
     output [7:0] temp;     
     assign temp= (branch_taken) ? ins[7:0]: pc+8'b00000001;
endmodule

// module to determine type of instruction; type=00: R-type, type=01: I-type, type=10: J-type
module ins_type(ins,type);
    input [31:0] ins;
    output [1:0] type;
    assign type = (ins[31:26] == 6'b000001) ? 2'b00 : (((ins[31:26] == 6'b000011) || (ins[31:26] == 6'b000010) || (ins[31:26] == 6'b000100)) ? 2'b10 : 2'b01);
endmodule
