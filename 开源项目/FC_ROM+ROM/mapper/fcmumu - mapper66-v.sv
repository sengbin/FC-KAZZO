`timescale 1ns / 1ps

module fcmumu
(	
	// CPU
	input m2,
	input m2_rst,
	input romsel,
	input cpu_rw_in,
	output irq,
	
	inout [7:0]  cpu_data,
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
	
	// 镜像
	output ppu_ciram_a10,
	
	input chr_addr_out_A_1,
	output reg [21:10] chr_addr_out
	
);

		
	
	// 只使用一半空间
	assign byte1 = 1;
	
	// 接OE使用时候与WR取反 CE使用romsel
	assign prg_ce = romsel;
	assign prg_we = cpu_rw_in || romsel;
	assign prg_oe = ~cpu_rw_in || romsel;
	
	assign chr_ce = ppu_ce;
	assign chr_we = ppu_wr;
	assign chr_oe = ppu_rd;
	
	initial
	begin
		prg_addr_out[21:13] <= 9'b111111111;
		chr_addr_out[21:13] <= 9'b000000000;
	end
	
	// VH
	reg mirroring = 0;
	assign ppu_ciram_a10 = mirroring ? ppu_addr_in[11] : ppu_addr_in[10];
	
	assign irq = 1'bz;
	//===========
	
	
	// mapper66
	reg [1:0] prg_bank = 2'b11;
	reg [1:0] chr_bank = 2'b00;
	// 关闭bank切换
	reg bank_en = 1'b1;
	
	assign prg_addr_out[14:13] = cpu_addr_in[14:13];
	assign prg_addr_out[16:15] = prg_bank[1:0];
	assign chr_addr_out[12:10] = ppu_addr_in[12:10];
	assign chr_addr_out[14:13] = chr_bank[1:0];
	
	
	always @ (negedge m2)
	begin
		if (cpu_rw_in == 0 && !romsel && bank_en)
		begin
			chr_bank  <= cpu_data[1:0];
			prg_bank  <= cpu_data[5:4];
		end
		//开关
		else if (cpu_rw_in == 0 && {!romsel,cpu_addr_in[14:0]} == 16'h5000)
			bank_en <= cpu_data[0];
		//prg
		else if (cpu_rw_in == 0 && {!romsel,cpu_addr_in[14:0]} == 16'h5001)
			prg_bank  <= cpu_data[1:0];
		//chr
		else if (cpu_rw_in == 0 && {!romsel,cpu_addr_in[14:0]} == 16'h5002)
			chr_bank  <= cpu_data[1:0];
		
	end
	
endmodule

	
	

   