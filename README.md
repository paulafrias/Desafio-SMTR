# Desafio-SMTR

Repositório para documentar desafio de processo seletivo da SMTR.

O desafio consiste em calcular a velocidade média a cada 10 minutos de cada ônibus do sistema SPPO a partir de uma base de dados que se encontra no repositorio publico do "base  dos dados".

O desafio foi feito em R e todos os comandos estão comentados no script. 

# Limpando a base

Após fazer a requisição dos dados e guardar no meu ambiente de trabalho, fiz uma sumarização para saber quantos códigos únicos de ônibus tinham. 
Ao perceber que alguns onibus só apareciam uma vez ou em alguns casos o ônibus se repetia mas a distância para garagem permanecia a mesma, ou seja, estava em repouso, decidi tirar esses casos da base. 
Para limpar a base dentro dessa segunda condição eu ordenei pelo identificador do ônibus e criei uma variável com a distancia para garagem da linha anterior. Após isso, fiz a diferença da distancia e dessa nova variável para encontrar as diferenças que davam 0, ou seja, aquele ônibus estava com a mesma distância do ônibus da observação anterior. Após esse passo eu retirei os ônibus que estava com apenas uma observação. Após essas transformações sobraram 56 códigos únicos. 


# Conversão do tempo

Para me basear na variável do timestamp do gps, retirei parte da string correspondente aos segundos, minutos e hora para fazer a conversão para segundos. 

# Cálculo da velocidade

Para cálculo da velocidade eu agrupei os ônibus. Tirei a diferença do minimo e maximo do campo da distancia da garagem para cada onibus  e dividi pela diferença do minimo e maximo do campo de segundos que criei, também para cada ônibus. Assim obtive a velocidade média em m/s, após isso fiz a conversão para Km/h.
