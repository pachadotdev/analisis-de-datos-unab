##########################################
# Definir carpeta de trabajo y librerías
##########################################

setwd("/Users/pacha/analisis-de-datos-unab/laboratorios/laboratorio4/")

#install.packages("foreign")
#install.packages("httr")
#install.packages("plyr")

library(foreign) #para leer archivos de Stata, SPSS, etc
library(httr) #permite descargar desde la web
library(plyr) #comandos útiles para bases de datos

###########################
# Diccionario de variables
###########################

# Lo primero es consultar el diccionario de variables donde aparece la explicación de los códigos y la naturaleza de las variables
# http://observatorio.ministeriodesarrollosocial.gob.cl/documentos/Libro_de_Codigos_Casen_2013_Base_Principal_Metodologia_Nueva.pdf

####################################
# Descargar y cargar base de datos
####################################

url <- "http://pachamaltese.github.io/analisis-de-datos-unab/laboratorio4/casen2013.dta.zip"
zip <- "casen2013.dta.zip"
dta <- "casen2013.dta"

if(!file.exists(dta)){
  if(!file.exists(zip)){
    print("descargando")
    download.file(url, file, method="curl")
    unzip("casen2013.dta.zip")
    casen <- read.dta("casen2013.dta")
  }
} else {
  casen <- read.dta("casen2013.dta")
}

####################################
# Limpiar datos y generar variables
####################################

# creo una copia que ahorrará tiempo si quiero retroceder algunos pasos
# o sea, si me equivoco vuelvo a ejecutar esta línea y la variable casen sigue intacta (ahorra tiempo)
data <- casen

# conservo en memoria únicamente las variables relevantes para la regresión
# para esto hay que consultar el diccionario de variables
keep <- c("expr", "yoprcor", "edad", "esc", "sexo", "region", "rama1", "o10")
data <- data[keep]

# veo el tipo de variables en memoria
str(data) #hay variables enteras, factores y numéricas 

# saco las filas que tengan celdas vacías (o sino habrá que hacer pasos adicionales al final)
data <- na.omit(data)

# hay que crear la variable "logaritmo del salario por hora"
# se consideran los datos de los trabajadores con jornada > 30 horas/semana
# para el cálculo hay que calcular 
# salario ($/mes) * 12 (meses/año) / jornada (horas/semana) * 52 (semanas/año)
data <- data[data$o10 > 30,]
data$WHP <- (data$yoprcor*12)/(data$o10*52)
data$logWHP <- log(data$WHP)

# conservo solo los datos que corresponden al tramo de edad entre 35 y 45 años
data <- data[(data$edad >= 35 & data$edad <= 45),]

# conservo solo los datos que corresponden al nivel de escolaridad pedido
# profesional en Chile = 5 años (o más) de educación superior
# entonces Experiencia Laboral = Edad - Años de Escolaridad ("esc") - 5 (duración mínima de estudios profesionales)
# la ecuación de arriba puede tomar valores negativos ya que hay personas en la encuesta que se encuentran estudiando 
# y trabajan part-time, realizan continuidad de estudios, tienen post-grado, etc. entonces hay que descartar esos casos
data$exp <- data$edad - data$esc - 5
data <- data[data$exp >= 0,]
data$exp2 <- (data$exp)^2

# hay que generar una variable binaria para cada región
# antes de hacer cualquier cosa veo como están asignados los niveles del factor región
levels(data$region)

# los nombres de los niveles contienen espacios, entonces asigno nombres simples
# (ver el excel que usé para hacer que el proceso sea eficiente)
data$region <- revalue(data$region, c("i. tarapaca"="r1",
                                      "ii. antofagasta"="r2",
                                      "iii. atacama"="r3",
                                      "iv. coquimbo"="r4",
                                      "v. valpara\xedso"="r5",
                                      "vi. o higgins"="r6",
                                      "vii. maule"="r7",
                                      "viii. biob\xedo"="r8",
                                      "ix. la araucan\xeda"="r9",
                                      "x. los lagos"="r10",
                                      "xi. ays\xe9n"="r11",
                                      "xii. magallanes"="r12",
                                      "metropolitana"="r13",
                                      "xiv. los r\xedos"="r14",
                                      "xv. arica y parinacota"="r15"))

# verifico que los nombres asignados a los niveles hayan cambiado
levels(data$region)

# para crear las variables binarias uso el comando for de manera que no hay que repetir el comando para cada región
for(i in unique(data$region)) {
  data[paste(i, sep="")] <- ifelse(data$region == i, 1, 0)
}

# hay que generar una variable binaria para cada industria (o rama)
# veo como están asignados los niveles del factor región
levels(data$rama1)

# aparece un nivel que corresponde a "sin clasificar" (nivel X), entonces debo sacar ese nivel y volver a definir los niveles
data<-data[data$rama1 != "x. no bien especificado",]
data$rama1 <- factor(data$rama1) 

# verifico los cambios
levels(data$rama1)

# los nombres de los niveles contienen espacios, entonces asigno nombres simples
data$rama1 <- revalue(data$rama1, c("a. agricultura, ganader\xeda, caza y silvicultura"="sa",
                                    "b. pesca"="sb",
                                    "c. explotaci\xf3n de minas y canteras"="sc",
                                    "d. industrias manufactureras"="sd",
                                    "e. suministro de electricidad, gas y agua"="se",
                                    "f.construcci\xf3n"="sf",
                                    "g. comercio al por mayor y al por menor"="sg",
                                    "h. hoteles y restaurantes"="sh",
                                    "i. transporte, almacenamiento y comunicaciones"="si",
                                    "j. intermediaci\xf3n financiera"="sj",
                                    "k. actividades inmobiliarias, empresariales y de alquiler"="sk",
                                    "l.administrasci\xf3n p\xfablica y defensa"="sl",
                                    "m. ense\xf1anza"="sm",
                                    "n. servicios sociales y de salud"="sn",
                                    "o. otras actividades de servicios comunitarios, sociales y personales"="so",
                                    "p. hogares privados con servicio dom\xe9stico"="sp",
                                    "q.organizaciones y organos extraterritoriales"="sq"))

# verifico los cambios
levels(data$rama1)

# para crear las variables binarias uso el comando for de manera que no hay que repetir el comando para cada región

for(i in unique(data$rama1)) {
  data[paste(i, sep="")] <- ifelse(data$rama1 == i, 1, 0)
}

# si no usaba na.omit al principio hay que usar esto
#drop <- c("NA")
#data <- data[,!(names(data) %in% drop)]
#data <- data[complete.cases(data),]

#############
# Regresiones
#############

# estimadores para la muestra
summary(lm(logWHP ~ sexo + esc + exp + exp2 + r13 + sl, data = data))

# estimadores para la población (población = país)
summary(lm(logWHP ~ sexo + esc + exp + exp2 + r13 + sl, data = data, weights = expr))