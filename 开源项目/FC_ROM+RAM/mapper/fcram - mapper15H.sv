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

	assign byte1 = 1;
	
	// 只使用芯片1 接OE使用时候与WR取反 CE使用romsel
	assign prg_ce = romsel;
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
		//prg_addr_out[21:14] <= 0;
		prg_addr_out[21:14] <= 8'hff;
		chr_addr_out[17:10] <= 0;
		//cpu_bank[3:0] <= 4'b0000;//mapper2
	end
	
	// 0-V 
	// 1-H
	// 默认使用 H
	reg mirror = 1;
	assign ppu_ciram_a10 = mirror? ppu_addr_in[11] : ppu_addr_in[10];
	
	
	// ==============================================================
	
	// mapper15
	reg [1:0] prg_bank_mode = 2'b00;
	reg [5:0] bank = 6'b000000;
	reg ss2_A13 = 0;
	reg bank_en = 1;
	assign chr_addr_out[12:10] = ppu_addr_in[12:10];

	always @ (negedge m2)
	begin
	
		if (!m2_rst)
		begin
			if(bank_en)
			begin
				bank <= 6'b000000;
				prg_bank_mode <= 2'b00;
				ss2_A13 <= 0;
				mirror <= 1'b1;
			end
		end
		
		// 写入寄存器 切换
		if (cpu_rw_in == 0 && ~romsel && bank_en)
		begin
			prg_bank_mode <= cpu_addr_in[1:0];
			//0: Vertical 1: Horizontal
			mirror <= cpu_data[6];
			// PRG A13 if SS=2, ignored otherwise
			ss2_A13 <= cpu_data[7];
			bank <= cpu_data[5:0];
		end
		
		// 5000 开关
		if (cpu_rw_in == 0 && romsel && cpu_addr_in[14:0] == 15'h5000)
		begin
			prg_bank_mode <= 2'b00;
			bank[5:1] <= cpu_data[4:0];
		end
		// 5001 切换bank 32k
		else if (cpu_rw_in == 0 && romsel && cpu_addr_in[14:0] == 15'h5001)
		begin
			bank_en <= cpu_data[0];
		end
	end
	
	// 读取
	always @ (*)
	begin
		if (~romsel)
		begin
			case(prg_bank_mode)
				//0: NROM-256 (PRG A14=CPU A14)
				2'b00:
					begin
						prg_addr_out[13] <= cpu_addr_in[13];
						prg_addr_out[14] <= cpu_addr_in[14];
						prg_addr_out[19:15] <= bank[5:1];
					end
				//1: UNROM    (PRG A14..16=111 when CPU A14=1)
				2'b01:
					begin
						prg_addr_out[13] <= cpu_addr_in[13];
						prg_addr_out[16:14] <= cpu_addr_in[14]?3'b111:bank[2:0];
						prg_addr_out[19:17] <= bank[5:3];
					end
				//2: NROM-64  (PRG A13=p)
				2'b10: 
					begin
						prg_addr_out[13] <= ss2_A13;
						prg_addr_out[19:14] <= bank[5:0];
					end
				//3: NROM-128
				2'b11:
					begin
						prg_addr_out[13] <= cpu_addr_in[13];
						prg_addr_out[19:14] <= bank[5:0];
					end
			endcase
		end
	end
	
	
endmodule

	
	

   