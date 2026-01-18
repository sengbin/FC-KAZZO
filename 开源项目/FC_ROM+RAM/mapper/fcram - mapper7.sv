//`timescale 1ns / 1ps

module fcram
(	
	// CPU
	input osc50,
	input m2,
	input m2_rst,
	input romsel,
	input cpu_rw_in,
	output irq,
	
	input [7:0]  cpu_data,
	input [14:0] cpu_addr_in,
	// 输出高位地址线
	output reg [21:13] prg_addr_out,
	
	input prg_addr_out_A_1,
	output byte1,
	
	// 片选
	output prg_ce,
	output prg_we,
	output prg_oe,
	
	
	// PPU
	input ppu_rd,
	input ppu_wr,
	input ppu_ce,
	input [12:10] ppu_addr_in,
	
	output chr_ce,
	output chr_oe,
	output chr_we,
	output chr_ce2,
	
	// 镜像
	output ppu_ciram_a10,
	
	// H
	input  ppu_A13_ne,
	output  ciram_ce,
	
	output reg [17:10] chr_addr_out
	
);

	// 写入使能 默认不可用 PRG_WE
	reg write_en = 1;

	assign byte1 = 1;
	
	// 只使用芯片1 接OE使用时候与WR取反 CE使用romsel
	assign prg_ce = romsel;
	//assign prg_we = cpu_rw_in | romsel | write_en;
	assign prg_we = cpu_rw_in | romsel;
	assign prg_oe = ~cpu_rw_in | romsel;
	
	assign chr_ce = ppu_ce;
	assign chr_we = ppu_wr;
	assign chr_oe = ppu_rd;
	assign chr_ce2 = 1;
	
	//assign ciram_ce = ppu_A13_ne;
	assign ciram_ce = ~ppu_ce;
	
	assign irq = 1'bZ;
	
	initial
	begin
		prg_addr_out[21:14] <= 0;
		chr_addr_out[17:10] <= 0;
	end
	
	
	
	//===========
		
	reg mirror = 1;
	reg [2:0] bank = 3'b111;
	
	assign prg_addr_out[14:13] = cpu_addr_in[14:13];
	assign prg_addr_out[17:15] = bank[2:0];
	assign chr_addr_out[12:10] = ppu_addr_in[12:10];
	
	assign ppu_ciram_a10 = mirror;
	
	always @ (negedge m2)
	begin
		if (cpu_rw_in == 0 && !romsel)
		begin
			if (cpu_rw_in == 0)
				bank <= cpu_data[2:0];
				mirror <= cpu_data[4];
		end
	end
	
	
endmodule

	
	

   