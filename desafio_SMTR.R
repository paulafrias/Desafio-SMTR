
library("basedosdados")
library(rlang)
library(devtools)
library(tidyverse)
library(geosphere)
library(weathermetrics)
library(leaflet)
library(geobr)

# Conectando com meu projeto do google cloud para extrair a base do repositorio publico do "base  dos dados"

set_billing_id("meta-history-290421")

# Guardando a requisição em um objeto

query <- "SELECT * FROM `rj-smtr.br_rj_riodejaneiro_onibus_gps.registros_tratada` LIMIT 1000"


# Carregando a base de dados no Environment a partir da query

data <- read_sql(query)

# Salvando a base de dados em csv para ter o backup

write.csv2(data, "dataonibus.csv")

#Conhecendo os dados para saber quantos codigos unicos existem


summary(unique(data$ordem))

# retirando as repetições dos onibus que estão sempre em repouso, ou seja, a distancia para a garagem não se altera 

data <- arrange(data, ordem, timestamp_gps) #ordena
data$distanciaanterior <-c(0,data$distancia_da_garagem_metros[-999]) # cria uma variavel com o item anterior da distancia da garagem
data$diferenca <- data$distancia_da_garagem_metros-data$distanciaanterior #faz a diferenca das distancias da garagem

data2 <- data %>% filter(diferenca!=0) 


#Retirando os onibus que so aparecem uma vez, os que sempre estão em repouso tiveram um observação sobrando da etapa anterior, a qual será retirada nessa


unicos<- as.data.frame(table(data2$ordem))

unicos$ordem <- unicos$Var1

data2 <- left_join(data2, unicos, "ordem")

data3<- data2 %>% filter( Freq > 1)

#verificar quantos sobraram

summary(unique(data3$ordem))

# Separando a data da hora

data3$segundosgps <-as.numeric( substr(data3$timestamp_gps, 18,19))+as.numeric( substr(data3$timestamp_gps, 15,16))*60 + 
  as.numeric( substr(data3$timestamp_gps, 12,13))*3600

# agrupando por onibus de pegando o espaço inicial e final, e o tempo inicial e final para calcular a velocidade media em m/s

data4 <- data3 %>% 
  group_by(ordem) %>%
  summarise(segundos = abs(max(segundosgps) - min(segundosgps)), metros =abs( min(distancia_da_garagem_metros) - max(distancia_da_garagem_metros)) ) %>% 
  mutate(velocidade_media= metros/segundos)

#Convertendo para Km/h

data4$vmkm <- convert_wind_speed(data4$velocidade_media, "mps", "kmph")

# Os resultados não foram satisfatorias.As velocidades deram um valor muito baixo.


# Plotando pontos por linhas


Rio <- read_municipality( code_muni = 3304557, year=2010 )

ggplot(data3) + geom_sf(data=Rio)+geom_point(aes(x = longitude, y = latitude, colour=linha), size = 1) + 
  theme(legend.position="bottom")

# Base Final

basefinal <- data4 %>% select(Identificador = ordem, Velocidade = vmkm)

save(data, data2,data3,data4,Rio, basefinal, file = "bases_SMTR.RData")



  
