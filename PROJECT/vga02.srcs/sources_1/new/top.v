`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Student
// 
// Create Date: 27.06.2019 15:16:45
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input wire [6:0] sw,
    input wire CLK,             // clock da placa: 100 MHz
    input wire RST_BTN,         // botao de reset
    output wire VGA_HS_O,       // saida de sincronizacao horizontal
    output wire VGA_VS_O,       // saida de sincronizacao vertical
    output reg [3:0] VGA_R,     // 4-bit VGA vermelho
    output reg [3:0] VGA_G,     // 4-bit VGA verde
    output reg [3:0] VGA_B      // 4-bit VGA azul
    );

    wire rst = RST_BTN;  // reset: ativo alto na Basys3 (BTNC)

    // Gerando um clock de 25 MHz para o pixel
    reg [15:0] cnt;
    reg pix_stb;
    always @(posedge CLK)
        {pix_stb, cnt} <= cnt + 16'h4000;  // divide por 4: (2^16)/4 = 0x4000

    wire [9:0] x;  // posicao atual do pixel x: valor 10-bit: 0-1023
    wire [8:0] y;  // posicao atual do pixel y: valor  9-bit: 0-511
    wire active;   // Recebe alto quando estiver na zona ativa para 'desenhar' o pixel

    vga640x360 display (
        .i_clk(CLK), 
        .i_pix_stb(pix_stb),
        .i_rst(rst),
        .o_hs(VGA_HS_O), 
        .o_vs(VGA_VS_O), 
        .o_x(x), 
        .o_y(y),
        .o_active(active)
    );

    // Buffers de espaco da VRAM (read-write)
    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 360;
    localparam VRAM_DEPTH = SCREEN_WIDTH * SCREEN_HEIGHT; 
    localparam VRAM_A_WIDTH = 18;  // 2^18 > 640 x 360
    localparam VRAM_D_WIDTH = 6;   // bits de cor por pixel

    reg [VRAM_A_WIDTH-1:0] address;
    wire [VRAM_D_WIDTH-1:0] dataout;

    sram #(
        .ADDR_WIDTH(VRAM_A_WIDTH), 
        .DATA_WIDTH(VRAM_D_WIDTH), 
        .DEPTH(VRAM_DEPTH), 
        .MEMFILE("lena.mem"))  // carregando o bitmap
        vram (
        .i_addr(address), 
        .i_clk(CLK), 
        .i_write(0),  // Trabalhando apenas com leitura
        .i_data(0), 
        .o_data(dataout)
    );

    reg [11:0] palette [0:63];  // 64 x 12-bit paleta de entrada de cores
    reg [11:0] colour;
    
    initial begin
        $display("Loading palette.");
        $readmemh("lena_palette.mem", palette);  // Carregando a paleta do bitmap da imagem
    end

    always @ (posedge CLK)
    begin
        address <= y * SCREEN_WIDTH + x;
        
        if (active)
        begin
            colour <= palette[dataout];

            if(sw[0] == 1)
            begin  // Inverter cores
                colour <= 0'b111111111111 - palette[dataout];
            end
            else if(sw[1] == 1)
            begin  // Remove cor vermelha
                colour <= 0'b000011111111 & palette[dataout];
            end
            else if(sw[2] == 1)
            begin  // Remove cor verde
                colour <= 0'b111100001111 & palette[dataout];
            end
            else if(sw[3] == 1)
            begin  // Remove cor azul
                colour <= 0'b111111110000 & palette[dataout];
            end
            else if(sw[4] == 1)
            begin  // Filtro de cor vermelha
                colour <= 0'b111100000000 & palette[dataout];
            end
            else if(sw[5] == 1)
            begin  // Filtro de cor verde
                colour <= 0'b000011110000 & palette[dataout];
            end
            else if(sw[6] == 1)
            begin  // Filtro de cor azul
                colour <= 0'b000000001111 & palette[dataout];
            end
               
        end  
        else
            begin
                colour <= 0;
            end  
        VGA_R <= colour[11:8];
        VGA_G <= colour[7:4];
        VGA_B <= colour[3:0];
    end
endmodule
