# Documentação do Projeto

## Introdução

Este projeto foi desenvolvido no ambito da disciplina de Projeto 4 - Multimédia Interativo, com a supervisão dos docentes Pedro Martins, Luís Pereira e Sérgio Rebelo, da FCTUC (Faculdade de Ciências e Tecnologia da Universidade de Coimbra) no ano letivo de 2021/2022.

Para tal foram usadas as tecnologias de [Processing](https://processing.org/), [Java](https://www.java.com/pt-BR/), [Node.js](https://nodejs.org/en/about/) e [JavaScript](https://developer.mozilla.org/pt-BR/docs/Web/JavaScript). 


## Harmonograph_and_HandTracking

* ### Processing 

    Para este ficheiro, é necessário importar as bibliotecas do processing referidas no inicio do programa (linhas 2 a 5), para poder gerar um documento .pdf e obter som e video.

    Depois de inicializar várias variáveis globais, o programa consiste em desenhar uma representação gráfica de uma expressão matemática baseado num movimento harmônico. Este desenho é alterado consuante a deteção de mãos no video obtido e consuante a frequência do som obtido. 

    Após as interações, existem duas opções: Ou o utilizador do programa pressiona o botão 'SPACE' para iniciar a impressão do desenho, ou de minuto em minuto, a impressão é feita automaticamente.

* ### Java

    Para ser feita a impressão, é necessário um pedido ao servidor local de método GET, para o endpoin /print, com os parâmetros name (o nome do ficheiro .pdf gerado no momento do clique ou do intervalo pré-definido), printer (o nome da impressora que se quer usar) e scale (tamanho desejado para a impressão).

* ### Node.js

    É utilizado o software Node.js para permitir a execução de código JavaScript fora de um navegador web.

    Para este projeto é necessário iniciar um servidor locar com o comando:

    ```bash
    node index.js
    ```

* ### JavaScript
    
    No código JavaScript é necessário importar as bibliotecas [express](https://expressjs.com/) e [pdf-to-printer](https://www.npmjs.com/package/pdf-to-printer).

    O programa começa por escutar a 'port:3000' para receber o pedido de impressão feito na parte de Java. 

    Faz um pedido ao servidor ao mesmo endpoint usado no pedido Java onde vai buscar á resposta o parâmetro enviados para conseguir executar a impressão. Em caso de erro o programa apresenta o erro na consola.

## TrackingMotion_Grid

* ### Processing

    É importada a biblioteca 'processing.video.*' para obter o video da câmara diponível. 

    O objetivo deste programa é aumentar a estabilidade da captação do movimento que serve como interação no programa original.

    Divide-se a janela do programa numa grelha. O movimento apenas é considerado caso o objeto mude de célula da grelha, sendo que movimentos pequenos passam a ser ignorados.
    

*Trabalho realizado por:*

Ana Inês Maçãs de França

David Rafael dos Reis Nunes

Inês Domingues Lopes

José Pedro da Rocha Antunes
 