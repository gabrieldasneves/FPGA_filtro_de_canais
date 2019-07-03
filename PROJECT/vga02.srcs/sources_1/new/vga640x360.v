`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2019 15:16:13
// Design Name: 
// Module Name: vga640x360
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


module vga640x360(
    input wire i_clk,           // clock base
    input wire i_pix_stb,       // clock de strobe de pixel
    input wire i_rst,           // reset: reinicia o frame
    output wire o_hs,           // sincronizacao horizontal
    output wire o_vs,           // sincronizacao vertical
    output wire o_blanking,     // high during blanking interval
    output wire o_active,       // Manda sinal alto quando estiver na zona para enviar o pixel
    output wire o_screenend,    // high for one tick at the end of screen
    output wire o_animate,      // high for one tick at end of active drawing
    output wire [9:0] o_x,      // current pixel x position
    output wire [8:0] o_y       // current pixel y position
    );

    localparam HS_STA = 16;              // Inicia sincronizacao horizontal
    localparam HS_END = 16 + 96;         // Termina sincronizacao horizontal
    localparam HA_STA = 16 + 96 + 48;    // Inicia sincronizacao horizontal do pixel ativo
    localparam VS_STA = 480 + 10;        // Inicia sincronizacao vertical
    localparam VS_END = 480 + 10 + 2;    // Termina sincronizacao vertical
    localparam VA_STA = 60;              // Inicia sincronizacao vertical do pixel ativo
    localparam VA_END = 420;             // Termina sincronizacao vertical do pixel ativo
    localparam LINE   = 800;             // Valor da linha de pixels completa (qtd de colunas)
    localparam SCREEN = 525;             // Valor da coluna de pixels completa (qtd de linhas)

    reg [9:0] h_count;  // Posicao da linha
    reg [9:0] v_count;  // Posicao da tela (coluna)

    // Gera sinais de sincronizacao (active low for 640x480)
    assign o_hs = ~((h_count >= HS_STA) & (h_count < HS_END));
    assign o_vs = ~((v_count >= VS_STA) & (v_count < VS_END));

    // Para manter os pixels (x, y) a serem "plotados" na zona ativa
    assign o_x = (h_count < HA_STA) ? 0 : (h_count - HA_STA);
    assign o_y = (v_count >= VA_END) ? 
                    (VA_END - VA_STA - 1) : (v_count - VA_STA);

    // blanking: high within the blanking period
    assign o_blanking = ((h_count < HA_STA) | (v_count > VA_END - 1));

    // Ativo: tem sinal alto enquanto o pixel estiver na zona da tela
    assign o_active = ~((h_count < HA_STA) | 
                        (v_count > VA_END - 1) | 
                        (v_count < VA_STA));

    // screenend: high for one tick at the end of the screen
    assign o_screenend = ((v_count == SCREEN - 1) & (h_count == LINE));

    // animate: high for one tick at the end of the final active pixel line
    assign o_animate = ((v_count == VA_END - 1) & (h_count == LINE));

    always @ (posedge i_clk)
    begin
        if (i_rst)  // Reseta para reiniciar o frame
        begin
            h_count <= 0;
            v_count <= 0;
        end
        if (i_pix_stb)  // Um strobe por pixel
        begin
            if (h_count == LINE)  // Fim da linha (reinicia a linha para novos pixels)
            begin
                h_count <= 0;
                v_count <= v_count + 1;
            end
            else 
                h_count <= h_count + 1;

            if (v_count == SCREEN)  // Fim da tela
                v_count <= 0;
        end
    end
endmodule
