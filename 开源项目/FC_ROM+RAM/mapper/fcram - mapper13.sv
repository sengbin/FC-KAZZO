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
		//cpu_bank[3:0] <= 4'b0000;//mapper2
	end
	
	
	
	//===========
	
	
	// mapper13
	// prg-32k chr-ram 16k
	reg [1:0] chr_bank = 2'b00;
	assign prg_addr_out[14:13] = cpu_addr_in[14:13];
	assign chr_addr_out[11:10] = ppu_addr_in[11:10];
	// 固定低4k 切换高4k，16k bank
	assign chr_addr_out[14:12] = (ppu_addr_in[12]==0 || chr_bank==2'b00)? 3'b000: { chr_bank, 1'b1};
	//assign chr_addr_out[12] = ppu_addr_in[12];
	//assign chr_addr_out[14:13] = ppu_addr_in[12]? chr_bank: 2'b00;
	
	
	
	// 1-V 
	// 0-H
	wire MIRRORING_VERTICAL = 1;
	assign ppu_ciram_a10 = MIRRORING_VERTICAL ? ppu_addr_in[10] : ppu_addr_in[11];
	
	always @ (negedge m2)
	begin
		if (cpu_rw_in == 0 && ~romsel)
		begin
			chr_bank <= cpu_data[1:0];
		end
	end
	
	
endmodule

	
	

   