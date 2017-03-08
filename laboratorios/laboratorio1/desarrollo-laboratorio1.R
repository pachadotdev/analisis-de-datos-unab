#Antes de proceder hay que definir algunas variables en memoria y cargar librerías
    #PASO 1: Definir el directorio de trabajo
    setwd("/Users/pacha/analisis-de-datos-unab/laboratorios/laboratorio1")
    
    #PASO 2: Instalar una librería que permita leer archivos XLSX
    #Usaremos XLConnect cuya documentación se puede ver en https://cran.r-project.org/web/packages/XLConnect/XLConnect.pdf
    #install.packages("XLConnect")
    
    #PASO 3: Cargar la librería XLConnect
    library(XLConnect)
    
    #PASO 4: Leer el archivo de laboratorio
    file <- paste0(getwd(),"/Laboratorio 1.xlsx")
    data <- readWorksheetFromFile(file, sheet = "Hoja1", region = "A2:C20", header = FALSE)
    data
    
    #PASO 5: Asignar nombres a las columnas
    colnames(data) <- c("y", "x1", "x2")
    data
    
#Haga un gráfico de cada variable explicativa sobre la explicada, ¿hay correlación entre ellas?
    
    #PASO 1: Instalar y cargar en memoria ggplot (librería para graficar)
    #install.packages("ggplot2")
    library(ggplot2)
    
    #PASO 2: Graficar y versus x1 e y versus x2
    qplot(x1, y, data=data)
    qplot(x2, y, data=data)
    
    #PASO 3: Ver la correlación entre las variables
    cor(data)
    
#Calcule el estimador de los parámetros
    
    #PASO 1: Hacer una regresión sin constante
    regression_nocons <- lm(y ~ x1 + x2 -1, data=data)
    summary(regression_nocons) 
    
    #PASO 2: Hacer una regresión con constante
    regression_cons <- lm(y ~ x1 + x2, data=data)
    summary(regression_cons)
    
