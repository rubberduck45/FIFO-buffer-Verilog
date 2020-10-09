module proj3(port1, port2, dready1, dready2, dreq, clock, reset, dack1, dack2, port3, dready3);

  input [7:0] port1, port2;
  output [7:0] port3;

  input clock, reset, dready1, dready2, dreq;
  output dack1, dack2, dready3;

  reg[7:0] R1, R2, R3, R4, R5, R6, R7, R8, Rout;

  wire treq1, treq2, treq3;
  wire tgrant1, tgrant2, tgrant3; //get token from arbiter

  wire rd1, rd2; //read from port1/port2
  wire wr; //write to Rout
  reg[2:0] regread; //track register to read from
  reg[2:0] regwrite; //track register to write to
  reg full,empty; //all registers full/empty

  initial begin
     regread = 1'd0;
     regwrite = 3'd0;
  end

  always @ (posedge rd1&clock&~full)
      begin
        if(regwrite == 3'd0)
          R1 <= port1;
        else if(regwrite == 3'd1)
          R2 <= port1;
        else if(regwrite == 3'd2)
          R3 <= port1;
        else if(regwrite == 3'd3)
          R4 <= port1;
        else if(regwrite == 3'd4)
          R5 <= port1;
        else if(regwrite == 3'd5)
          R6 <= port1;
        else if(regwrite == 3'd6)
          R7 <= port1;
        else if(regwrite == 3'd7)
          R8 <= port1;
        regwrite <= regwrite + 3'd1;
        if(regwrite == regread)
          full <= 1'd1;
          empty <= 1'd0;
      end

  always @ (posedge rd2&clock&~full)
      begin
        if(regwrite == 3'd0)
          R1 <= port2;
        else if(regwrite == 3'd1)
          R2 <= port2;
        else if(regwrite == 3'd2)
          R3 <= port2;
        else if(regwrite == 3'd3)
          R4 <= port2;
        else if(regwrite == 3'd4)
          R5 <= port2;
        else if(regwrite == 3'd5)
          R6 <= port2;
        else if(regwrite == 3'd6)
          R7 <= port2;
        else if(regwrite == 3'd7)
          R8 <= port2;
        regwrite <= regwrite + 3'd1;
        if(regwrite == regread)
          full <= 1'd1;
          empty <= 1'd0;
      end

  always @ (posedge wr&clock&~empty)
    begin
      if(regread == 3'd0)
        Rout <= R1;
      else if(regread == 3'd1)
        Rout <= R2;
      else if(regread == 3'd2)
        Rout <= R3;
      else if(regread == 3'd3)
        Rout <= R4;
      else if(regread == 3'd4)
        Rout <= R5;
      else if(regread == 3'd5)
        Rout <= R6;
      else if(regread == 3'd6)
        Rout <= R7;
      else if(regread == 3'd7)
        Rout <= R8;
      regread <= regread + 3'd1;
      if(regwrite == regread)
        full <= 1'd0;
        empty <= 1'd1;
    end

  assign port3 = Rout;

  //Task1 state machine;
  reg [3:0] task1_addr;
  wire [4:0] task1_data;

  port1 task1(task1_addr, task1_data);
  always @ (posedge reset or negedge clock)
      if(reset)
          task1_addr <= 4'd2;
      else
          task1_addr <= {task1_data[4:3], dready1, tgrant1};

      //assign outputs from data
      assign treq1 = task1_data[2];
      assign dack1 = task1_data[1];
      assign rd1 = task1_data[0];

  //task2
  reg [3:0] task2_addr;
  wire [4:0] task2_data;

  port2 task2(task2_addr, task2_data);
  always @ (posedge reset or negedge clock)
      if(reset)
          task2_addr <= 4'd2;
      else
          task2_addr <= {task2_data[4:3], dready2, tgrant2};

      //assign outputs from data
      assign treq2 = task2_data[2];
      assign dack2 = task2_data[1];
      assign rd2 = task2_data[0];

  //task 3
  reg [3:0] task3_addr;
  wire [4:0] task3_data;

  port3 task3(task3_addr, task3_data);
  always @ (posedge reset or negedge clock)
      if(reset)
          task3_addr <= 4'd2;
      else
          task3_addr <= {task3_data[4:3], dreq, tgrant3};

      //assign outputs from data
      assign treq3 = task3_data[2];
      assign dready3 = task3_data[1];
      assign wr = task3_data[0];

  //Arbiter
  reg  [7:0] addr;
  wire [5:0] data;

  arbiter arb(addr, data);
  always @ (posedge reset or negedge clock)
      if(reset)
          addr <= 8'd64;
      else
          addr <= {data[5:3], treq1, treq2, treq3, empty, full};

      //assign outputs from data
      assign tgrant1 = data[2];
      assign tgrant2 = data[1];
      assign tgrant3 = data[0];

endmodule

//modules to read in state machine data

module port1 (addr, data);
  input  [3:0] addr;
  output [4:0] data;

  reg [4:0] port1new_memory[0:15];

  initial
     $readmemh("/home/rhp219/verilog/New folder/port1.dat",port1new_memory);

  assign data = port1new_memory[addr];
endmodule

module port2 (addr, data);
  input  [3:0] addr;
  output [4:0] data;

  reg [4:0] port2new_memory[0:15];

  initial
     $readmemh("/home/rhp219/verilog/New folder/port2.dat",port2new_memory);

  assign data = port2new_memory[addr];
endmodule

module port3 (addr, data);
  input  [3:0] addr;
  output [4:0] data;

  reg [4:0] port3_memory[0:15];

  initial
     $readmemh("/home/rhp219/verilog/New folder/port3.dat",port3_memory);

  assign data = port3_memory[addr];
endmodule

module arbiter (addr, data);
  input  [7:0] addr;
  output [5:0] data;

  reg [5:0] arbiter_memory[0:255];

  initial
     $readmemh("/home/rhp219/verilog/New folder/arbiter.dat",arbiter_memory);

  assign data = arbiter_memory[addr];
endmodule


module test_proj3;
  wire reset, clk1, clk2, clk3, clk4;
  reg [7:0] op1, op2;
  integer data_file1, data_file2;
  reg eof1, eof2;
  wire dack1, dack2;
  wire dready1, dready2, dready3;
  wire dreq;
  wire wr1, wr2, rd;
  wire [7:0] port3;

  initial
      begin
          //open data test file
          data_file1 =$fopen("/home/rhp219/verilog/New folder/proj3A.dat", "rb");
          data_file2 = $fopen("/home/rhp219/verilog/New folder/proj3B.dat", "rb");
      end

  //init test_init(reset, clock);
  clocks clk(reset, clk1, clk2, clk3, clk4);
  always @(posedge clk1&wr1)
      begin
          eof1 = $feof(data_file1);
          if(eof1 == 0)
              $fscanf(data_file1, "%d", op1);
          else
              begin
                  $fclose(data_file1);
                  //add delay to get all outputs
                  #1000 $finish;
              end
      end
  always @(posedge clk2&wr2)
    begin
        eof2 = $feof(data_file2);
        if(eof2 == 0)
            $fscanf(data_file2, "%d", op2);
        else
            begin
            $fclose(data_file2);
            //add delay to get all outputs
            #1000 $finish;
        end
    end
  ext1 external1(dack1, clk1, reset, dready1, wr1);
  ext2 external2(dack2, clk2, reset, dready2, wr2);
  ext3 external3(dready3, clk3, reset, dreq);
  proj3 my_proj3(op1, op2, dready1, dready2, dreq, clk4, reset, dack1, dack2, port3, dready3);
  //proj3 my_proj3(op1, op2, 1, 1, 1, clock, reset);

endmodule








//external sys 1
module ext1(dack1, clock, reset, dready1, wr1);
  input dack1, clock, reset;
  output dready1, wr1;
  reg  [2:0] addr;
  wire [3:0] data;

  extport1 ext1(addr, data);
  always @ (posedge reset or negedge clock)
      if(reset)
          addr <= 3'd0;
      else
          addr <= {data[3:2], dack1};

      //assign outputs from data
      assign dready1 = data[0];
      assign wr1 = data[1];

endmodule


//external sys 2
module ext2(dack2, clock, reset, dready2, wr2);
  input dack2, clock, reset;
  output dready2, wr2;
  reg  [2:0] addr;
  wire [3:0] data;

  extport2 ext2(addr, data);
  always @ (posedge reset or negedge clock)
      if(reset)
          addr <= 3'd0;
      else
          addr <= {data[3:2], dack2};

      //assign outputs from data
      assign dready2 = data[0];
      assign wr2 = data[1];

endmodule

//external sys 3
module ext3(dready3, clock, reset, dreq, rd);
  input dready3, clock, reset;
  output dreq, rd;
  reg  [2:0] addr;
  wire [3:0] data;

  extport2 ext2(addr, data);
  always @ (posedge reset or negedge clock)
      if(reset)
          addr <= 3'd0;
      else
          addr <= {data[3:2], dready3};

      //assign outputs from data
      assign dreq = data[0];
      assign rd = data[1];

endmodule

//EXTERNAL state machine modules
module extport1 (addr, data);
  input  [2:0] addr;
  output [3:0] data;

  reg [3:0] extport1_memory[0:7];

  initial
     $readmemh("/home/rhp219/verilog/New folder/extport1.dat",extport1_memory);

  assign data = extport1_memory[addr];
endmodule

module extport2 (addr, data);
  input  [2:0] addr;
  output [3:0] data;

  reg [3:0] extport2_memory[0:7];

  initial
     $readmemh("/home/rhp219/verilog/New folder/extport1.dat",extport2_memory);

  assign data = extport2_memory[addr];
endmodule

module extport3 (addr, data);
  input  [2:0] addr;
  output [3:0] data;

  reg [3:0] extport3_memory[0:7];

  initial
     $readmemh("/home/rhp219/verilog/New folder/extport3.dat",extport3_memory);

  assign data = extport3_memory[addr];
endmodule

//clocks
module clocks(reset, clk1, clk2, clk3, clk4);
   // provides a reset signal and four independent clocks
   output reset, clk1, clk2, clk3, clk4;
   reg clk1, clk2, clk3, clk4;
   reg [8:0] X;
   wire clk;

   init clocks_init(reset, clk);
   always @(posedge clk or posedge reset)
     if (reset)
       begin
	  X <= 9'd1;
	  clk1 <= 1'd0;
	  clk4 <= 1'd0;
       end
     else
       begin
	  clk1 <= X[1] & X[3];
	  clk4 <= X[4] & X[6] & ~X[7];
	  X <= {X[7:0], 1'b0}^{4'b0000, X[8], 3'b000, X[8]};
	// corresponds to primitive polynomial
	// x^9 + x^4 + 1
       end
   always @(posedge ~clk or posedge reset)
     if (reset)
       begin
	  clk2 <= 1'd0;
	  clk3 <= 1'd0;
       end
     else
       begin
	  clk2 <= X[1] & ~X[2] & ~X[4];
	  clk3 <= X[0] & ~X[5];
       end

endmodule // clocks


//EXTERNAL state machine modules
module extport1 (addr, data);
  input  [2:0] addr;
  output [3:0] data;

  reg [3:0] extport1_memory[0:7];

  initial
     $readmemh("/home/rhp219/verilog/New folder/extport1.dat",extport1_memory);

  assign data = extport1_memory[addr];
endmodule

module extport2 (addr, data);
  input  [2:0] addr;
  output [3:0] data;

  reg [3:0] extport2_memory[0:7];

  initial
     $readmemh("/home/rhp219/verilog/New folder/extport2.dat",extport2_memory);

  assign data = extport2_memory[addr];
endmodule

module extport3 (addr, data);
  input  [2:0] addr;
  output [3:0] data;

  reg [3:0] extport3_memory[0:7];

  initial
     $readmemh("/home/rhp219/verilog/New folder/extport3.dat",extport3_memory);

  assign data = extport3_memory[addr];
endmodule
