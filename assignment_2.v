module pipelining(rs1,rs2,rd,z,addr,func,clk1,clk2);
input clk1,clk2;
input [3:0] rs1,rs2,rd;
input [1:0] func;
input [7:0] addr;
output [15:0] z;
reg [15:0] L12_A,L12_B,L23_z,L34_z;
reg [3:0] L12_rd,L12_func,L23_rd;
reg [7:0] L12_addr,L23_addr,L34_addr;

reg [15:0] regbank [0:15];
reg [15:0] mem [0:255];

assign z = L34_z;
//stage1
always @(posedge clk1)
begin
L12_A <= #2 regbank[rs1];
L12_B <= #2 regbank[rs2];
L12_rd <= #2 rd;
L12_func <= #2 func;
L12_addr <= #2 addr;
end
//stage2
always @(negedge clk2)
begin
	case(func)
		0: L23_z <= #2 L12_A + L12_B;
		1: L23_z <= #2 L12_A - L12_B;
		2: L23_z <= #2 L12_A & L12_B;
		3: L23_z <= #2 L12_A ^ L12_B;
		default: L23_z <= #2 16'hxxxx;
	endcase
	L23_rd <= #2 L12_rd;
	L23_addr <= #2 L12_addr;
end
//stage3
always @(posedge clk1)
begin
regbank[L23_rd] <= #2 L23_z;
L34_z <= #2 L23_z;
L34_addr <= #2 L23_addr;
end
//stage4
always @(negedge clk2)
begin
mem[L34_addr] <= #2 L34_z;
end 

endmodule

module pipelining_test;

	// Inputs
	reg [3:0] rs1;
	reg [3:0] rs2;
	reg [3:0] rd;
	reg [7:0] addr;
	reg [1:0] func;
	reg clk1;
	reg clk2;

	// Outputs
	wire [15:0] z;
	integer k;

	// Instantiate the Unit Under Test (UUT)
	pipelining uut (
		.rs1(rs1), 
		.rs2(rs2), 
		.rd(rd), 
		.z(z), 
		.addr(addr), 
		.func(func), 
		.clk1(clk1), 
		.clk2(clk2)
	);

initial begin
// Initialize Inputs
	clk1=0;
	clk2=0;
	repeat(20)
		begin
		#5 clk1=1;
		#5 clk1=0;
		#5 clk2=1;
		#5 clk2=0;
		end
	end
	
	//initialize registers
	initial begin
	for(k=0;k<16;k=k+1)
	uut.regbank[k] = k;
   end
	
initial begin
#5 
rs1=5;
rs2=3;
rd=1;
func=0;
addr=125;
#20
rs1=6;
rs2=4;
rd=2;
func=1;
addr=126;
#20
rs1=7;
rs2=5;
rd=3;
func=0;
addr=127;
#20
rs1=8;
rs2=6;
rd=4;
func=1;
addr=128;
#20
rs1=9;
rs2=7;
rd=5;
func=0;
addr=129;
end
      
endmodule
