# Projeto na placa de desenvolvimento em FPGA BASYS3

    O projeto consiste na aplicação do filtro negativo bem como no filtro de canais 
    (verde,azul,vermelho) e na exibição da imagem resultante em um monitor VGA.

   # Switches:
    Os switches utilizados na placa de desenvolvimento foram SW0, SW1, SW2, e SW3.

    O SW0 faz o filtro negativo;
    O SW1 filtra o canal vermelho;
    O SW2 filtra o canal verde;
    O SW3 filtra o canal azul;

   # Módulo monitor VGA
    O controlador VGA para a placa Basys 3 utiliza o clock de 100 MHz dividido por 4,
    para chegar ao clock de 25MHz, aproximadamente o clock de operação de um monitor
    VGA. Originalmente o monitor VGA precisa de um clock de 25.175MHz para operar com
    total precisão, e como o clock gerado é 25MHz, é necessário gerar algumas "zonas"
    de sincronização de pixels, para que a imagem na tela seja exibida de forma correta.

    Essas zonas de sincronização tem tamanhos fixos, tanto para as linhas quanto para 
    as colunas do controlador VGA. São zonas de 160 pixels para a sincronização horizon-
    tal, e 44 pixels para a sincronização vertical. 

    A cada pulso alto de clock, o controlador verifica em que zona está. Se estiver fora
    das duas zonas de sincronização, um sinal de "ativo" é colocado em alto, e indica que
    o usuário pode inserir seus pixels no monitor.

    Os pixels são enviados em um código de 12 bits, que é a resolução nativa da placa Basys 3.
    O registrador colour[11:0] recebe o código de cor do pixel e este é colocado nas saídas
    R[3:0], G[3:0], B[3:0], que estão ligadas no conector VGA da placa Basys 3.




