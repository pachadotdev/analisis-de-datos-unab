---
title: "Desarrollo Laboratorio Nº5"
subtitle: Análisis de Datos
author1: "Profesores: Ramón H. Cornejo-Muñoz y Felipe Rojas"
author2: "Profesor Ayudante de Laboratorio: Mauricio Vargas"
author3: "Ayudantes: Franco Mansilla y Mauricio Díaz"
job: "Universidad Nacional Andrés Bello"
logo: logounab.png
license : by-nc-sa
hitheme: tomorrow
framework: io2012
highlighter: highlight.js
widgets: mathjax
url:
  assets: ../../assets
  lib: ../../libraries
mode: selfcontained # {standalone, draft}
<!-- knit : slidify::knit2slides --> 
knit : slidify::knit2slides
---



## Parte 1

## Estimación usando ML

---

## Ejercicio 1

Obtenga una expresión algebraica para la media y la varianza de una distribución normal con media desconocida y varianza conocida
$$
f_n (x \:|\: \mu) = \frac{1}{(2\pi\sigma^2)^{n/2}} \exp\left[-\frac{1}{2\sigma^2}\sum_{i=1}^n (x_i - \mu)^2 \right]
$$
usando ML.

---

## Desarrollo Ejercicio 1

$f_n (x \:|\: \mu)$ se maximiza con el valor de $\mu$ que maximiza
$$
Q(\mu) = \sum_{i=1}^n (x_i - \mu)^2 = \sum_{i=1}^n x_i^2 - 2\mu\sum_{i=1}^n x_i + n\mu^2
$$
Calculando $dQ/d\mu$, igualando la derivada a cero y despejando $\mu$ se tiene que $\mu^* = \bar{x}_n$.

---

## Ejercicio 2

Obtenga una expresión algebraica para la media y la varianza de una distribución normal con media y varianza desconocidas
$$
f_n (x \:|\:\mu,\sigma^2) = \frac{1}{(2\pi\sigma^2)^{n/2}} \exp\left[-\frac{1}{2\sigma^2}\sum_{i=1}^n (x_i - \mu)^2 \right]
$$
usando ML.

---

## Desarrollo Ejercicio 2

$f_n (x \:|\: \mu,\sigma^2)$ se maximiza con los valores $\mu$ y $\sigma^2$ que maximizan $\ln f_n (x \:|\: \mu,\sigma^2)$
$$
\begin{align*}
z &= \ln f_n (x \:|\: \mu,\sigma^2) \cr
&= -\frac{n}{2}\ln(2\pi) - \frac{n}{2}\ln(\sigma^2) - \frac{1}{2\sigma^2} \sum_{i=1}^n (x_i - \mu)^2
\end{align*}
$$
Para encontrar los valores $\mu$ y $\sigma^2$ se resuelve el sistema
$$
\left\{
\begin{array}
[c]{l}%
\frac{\partial z(\mu,\sigma^2)}{\partial \mu} = 0 \: \Longrightarrow \: \frac{1}{\sigma^2} \left(\sum_{i=1}^n x_i - n\mu \right) = 0 \\
\frac{\partial z(\mu,\sigma^2)}{\partial \sigma^2} = 0 \: \Longrightarrow \: -\frac{n}{2\sigma^2} + \frac{1}{2\sigma^4} \sum_{i=1}^n (x_i - \mu)^2
\end{array}
\right.
$$
De la primera ecuación $\mu^* = \bar{x}_n$ y reemplazando en la segunda ecuación $\sigma^2 = \frac{1}{n} \sum_{i=1}^n (x_i - \bar{x}_n)^2$.

---

## Ejercicio 3

A partir de los siguientes datos simulados

```r
set.seed(1001)
N <- 100
x <- runif(N)
y <- 5 * x + 3 + rnorm(N)
```
Compare los resultados de la estimación del modelo $y ~ x$ usando OLS y ML. 

---

## Desarrollo Ejercicio 3 (1)

Estimación usando OLS

```r
fit1 <- lm(y ~ x)
coefficients(fit1)
```

```
(Intercept)           x 
   3.033213    4.877196 
```

---

## Desarrollo Ejercicio 3 (2)

Estimación usando OLS
<div class="rimage center"><img src="fig/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" class="plot" /></div>

---

## Desarrollo Ejercicio 3 (3)

Estimación usando ML: Se usará el supuesto de normalidad del residuo y los ejercicios 1 y 2

```r
library(stats4)
library(bbmle)
LL1 <- function(beta0, beta1, mu, sigma) {
  R = y - (beta0 + beta1*x)
  R = suppressWarnings(dnorm(R, mu, sigma, log = TRUE))
  -sum(R)
}
```

---

## Desarrollo Ejercicio 3 (4)

Función `mle` (`stats4`): Sensible a los valores iniciales (calcula gradientes e invierte la matriz hessiana)

```r
mle(LL1, start = list(beta0 = 1, beta1 = 2, mu = 0, sigma=1))
  Error in solve.default(oout$hessian) : 
  Lapack routine dgesv: system is exactly singular: U[3,3] = 0
  
mle(LL1, start = list(beta0 = 3, beta1 = 1, mu = 0, sigma=1))
        Estimate   Std. Error  
  beta0 3.01656914        NaN
  beta1 4.87740163 0.30856800
  Warning message:
  In sqrt(diag(object@vcov)) : NaNs produced

mle(LL1, start = list(beta0 = 3, beta1 = 5, mu = 0, sigma=1))
        Estimate   Std. Error
  beta0 3.01660716 5.931642e+03
  beta1 4.87719352 3.085551e-01
```

---

## Desarrollo Ejercicio 3 (5)


```r
fit2 <- mle(LL1, start = list(beta0 = 3, beta1 = 5, mu = 0, sigma=1))
summary(fit2)
```


```r
Maximum likelihood estimation

Coefficients:
        Estimate   Std. Error
beta0 3.01660716 5.931642e+03
beta1 4.87719352 3.085551e-01
mu    0.01660716 5.931642e+03
sigma 0.94057281 6.650833e-02

-2 log L: 271.5342 
```

---

## Desarrollo Ejercicio 3 (6)

Función `mle2` (`bbmle`): Evita los métodos basados en el cálculo diferencial $\Longrightarrow$ método robusto


```r
mle2(LL1, start = list(beta0 = 1, beta1 = 2, mu = 0, sigma=1), control = list(maxit= 1000))
        Estimate Std. Error z value     Pr(z)    
  beta0 2.016411   0.089510  22.527 < 2.2e-16 ***
  beta1 4.878325   0.308626  15.807 < 2.2e-16 ***

mle2(LL1, start = list(beta0 = 3, beta1 = 1, mu = 0, sigma=1), control = list(maxit= 1000))
        Estimate Std. Error z value  Pr(z)    
  beta0 3.016569   0.089493 33.7071 <2e-16 ***
  beta1 4.877402   0.308568 15.8066 <2e-16 ***

mle2(LL1, start = list(beta0 = 3, beta1 = 5, mu = 0, sigma=1), control = list(maxit= 1000))
        Estimate Std. Error z value  Pr(z)    
  beta0 3.016607   0.089490 33.7090 <2e-16 ***
  beta1 4.877194   0.308555 15.8066 <2e-16 ***
```

---

## Desarrollo Ejercicio 3 (7)

```r
fit3 <- mle2(LL1, start = list(beta0 = 3, beta1 = 5, mu = 0, sigma=1), 
             control = list(maxit= 1000))
summary(fit3)
```


```r
Maximum likelihood estimation

Coefficients:
      Estimate Std. Error z value  Pr(z)    
beta0 3.016607   0.089490 33.7090 <2e-16 ***
beta1 4.877194   0.308555 15.8066 <2e-16 ***
mu    0.016607   0.089490  0.1856 0.8528    
sigma 0.940573   0.066509 14.1421 <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

-2 log L: 271.5342 
```

---

## Ejercicio 4

A partir del <a href="http://pachamaltese.github.io/complementos/complemento-laboratorio4/complemento-laboratorio4.html">complemento del Laboratorio Nº4</a> estime los parámetros de la siguiente función de producción usando ML:

$$y = \beta_0 + \sum_i \beta_i x_i$$

---

## Desarrollo Ejercicio 4 (1)

Con base en la diapositiva 10 se debe hacer algunos ajustes a `LL1` 

```r
library(stats4); library(bbmle)
data("appleProdFr86", package = "micEcon")
data <- appleProdFr86
rm(appleProdFr86)

data$qCap <- data$vCap/data$pCap
data$qLab <- data$vLab/data$pLab
data$qMat <- data$vMat/data$pMat

LL2 <- function(beta0, betacap, betalab, betamat, mu, sigma) {
  R = data$qOut - (beta0 + betacap*data$qCap + betalab*data$qLab + betamat*data$qMat)
  R = suppressWarnings(dnorm(R, mu, sigma, log = TRUE))
  -sum(R)
}
```

---

## Desarrollo Ejercicio 4 (2)


```r
fit4 <- mle2(LL2, start = list(beta0 = 0, betacap = 10, betalab = 20, betamat = 30, 
                               mu = 0, sigma=1), control = list(maxit= 10000))
summary(fit4)
```

```r
Maximum likelihood estimation

Coefficients:
           Estimate  Std. Error     z value     Pr(z)    
beta0   -7.3685e+05  1.9999e-05 -3.6845e+10 < 2.2e-16 ***
betacap  1.6521e+00  4.5835e-01  3.6045e+00 0.0003128 ***
betalab  1.1610e+01  2.8228e-01  4.1130e+01 < 2.2e-16 ***
betamat  4.5521e+01  2.5620e+00  1.7768e+01 < 2.2e-16 ***
mu      -7.3685e+05  1.9999e-05 -3.6845e+10 < 2.2e-16 ***
sigma    3.5627e+05  1.0943e-07  3.2558e+12 < 2.2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

---

## Parte 2

## Estimación lineal y no lineal usando OLS

---

## Ejercicio 1

Examine las variables de la base de datos `appleProdFr86` testee la correlación lineal entre los inputs y el output y en base a estos datos estime los parámetros de las siguientes funciones de producción:

* Cobb-Douglas: $$y = A \prod_i x_i^{\beta_i} $$
* Translogarítmica: $$\ln y = \beta_0 + \sum_i \alpha_i \ln x_i + \frac{1}{2} \sum_i \sum_j \beta_{ij} \ln x_i \ln x_j$$

---

## Desarrollo Ejercicio 1 (1)

Verificación de hipótesis: Correlación lineal entre dos variables
$$H_0:\: \rho = 0$$
$$H_1:\: \rho\neq 0$$
Se usa el estadístico 
$$
t = r \sqrt{\frac{n-2}{1-r^2}}
$$
que sigue una distribución $t$ con $n-2$ grados de libertad.

---

## Desarrollo Ejercicio 1 (2)


```r
cor.test(data$qOut, data$qCap, alternative="greater")
  alternative hypothesis: true correlation is greater than 0
  t = 8.7546, df = 138, p-value = 3.331e-15
  cor: 0.5975547 
  95 percent confidence interval: 0.4996247 1.0000000
  
cor.test(data$qOut, data$qLab, alternative="greater")
  alternative hypothesis: true correlation is greater than 0
  t = 20.203, df = 138, p-value < 2.2e-16
  cor: 0.8644853 
  95 percent confidence interval: 0.8243685 1.0000000
  
cor.test(data$qOut, data$qMat, alternative="greater")
  alternative hypothesis: true correlation is greater than 0
  t = 15.792, df = 138, p-value < 2.2e-16
  cor: 0.8023509 
  95 percent confidence interval: 0.7463428 1.0000000  
```

---

## Desarrollo Ejercicio 1 (3)

$y = A \prod_i x_i^{\beta_i}$ se debe transformar en $\ln(y) = \ln(A) + \sum_{i=1}^n \beta_i \ln(x_i)$.

```r
prodCD <- lm(log(qOut) ~ log(qCap) + log(qLab) + log(qMat), data = data)
summary(prodCD)
```

```r
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) -2.06377    1.31259  -1.572   0.1182    
log(qCap)    0.16303    0.08721   1.869   0.0637 .  
log(qLab)    0.67622    0.15430   4.383 2.33e-05 ***
log(qMat)    0.62720    0.12587   4.983 1.87e-06 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.656 on 136 degrees of freedom
Multiple R-squared:  0.5943,	Adjusted R-squared:  0.5854 
F-statistic: 66.41 on 3 and 136 DF,  p-value: < 2.2e-16
```

---

## Desarrollo Ejercicio 1 (4)

$\ln y = \beta_0 + \sum_i \beta_i \ln x_i + \frac{1}{2} \sum_i \sum_j \beta_{ij} \ln x_i \ln x_j$ se estima directamente.

```r
prodTL <- lm(log(qOut) ~ log(qCap) + log(qLab) + log(qMat) + I(0.5*log(qCap)^2) 
             + I(0.5*log(qLab)^2) + I(0.5*log(qMat)^2) + I(log(qCap)*log(qLab))
             + I(log(qCap)*log(qMat)) + I(log(qLab)*log(qMat)), data = data)
```

---

## Desarrollo Ejercicio 1 (5)


```r
                         Estimate Std. Error t value Pr(>|t|)  
(Intercept)              -4.14581   21.35945  -0.194   0.8464  
log(qCap)                -2.30683    2.28829  -1.008   0.3153  
log(qLab)                 1.99328    4.56624   0.437   0.6632  
log(qMat)                 2.23170    3.76334   0.593   0.5542  
I(0.5 * log(qCap)^2)     -0.02573    0.20834  -0.124   0.9019  
I(0.5 * log(qLab)^2)     -1.16364    0.67943  -1.713   0.0892 .
I(0.5 * log(qMat)^2)     -0.50368    0.43498  -1.158   0.2490  
I(log(qCap) * log(qLab))  0.56194    0.29120   1.930   0.0558 .
I(log(qCap) * log(qMat)) -0.40996    0.23534  -1.742   0.0839 .
I(log(qLab) * log(qMat))  0.65793    0.42750   1.539   0.1262  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.6412 on 130 degrees of freedom
Multiple R-squared:  0.6296,	Adjusted R-squared:  0.6039 
F-statistic: 24.55 on 9 and 130 DF,  p-value: < 2.2e-16
```

---

## Ejercicio 2

Determine cual de las dos funciones de la parte anterior es más adecuada para representar la relación entre los inputs y el output.

---

## Desarrollo Ejercicio 2 (1)

Test de Wald:

```r
library(lmtest)
waldtest(prodCD, prodTL)

  Model 1: log(qOut) ~ log(qCap) + log(qLab) + log(qMat)
  Model 2: log(qOut) ~ log(qCap) + log(qLab) + log(qMat) + I(0.5 * log(qCap)^2) + 
      I(0.5 * log(qLab)^2) + I(0.5 * log(qMat)^2) + I(log(qCap) * 
      log(qLab)) + I(log(qCap) * log(qMat)) + I(log(qLab) * log(qMat))
    Res.Df Df     F  Pr(>F)  
  1    136                   
  2    130  6 2.062 0.06202 .
  ---
  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

---

## Desarrollo Ejercicio 1 (2)

Test de Razón de Verosimilitud

```r
lrtest(prodCD, prodTL)
  
  Model 1: log(qOut) ~ log(qCap) + log(qLab) + log(qMat)
  Model 2: log(qOut) ~ log(qCap) + log(qLab) + log(qMat) + I(0.5 * log(qCap)^2) + 
      I(0.5 * log(qLab)^2) + I(0.5 * log(qMat)^2) + I(log(qCap) * 
      log(qLab)) + I(log(qCap) * log(qMat)) + I(log(qLab) * log(qMat))
    #Df  LogLik Df  Chisq Pr(>Chisq)  
  1   5 -137.61                       
  2  11 -131.25  6 12.727    0.04757 *
  ---
  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1  
```

---

## Desarrollo Ejercicio 1 (3)

ANOVA

```r
anova(prodCD, prodTL, test = "F")

  Model 1: log(qOut) ~ log(qCap) + log(qLab) + log(qMat)
  Model 2: log(qOut) ~ log(qCap) + log(qLab) + log(qMat) + I(0.5 * log(qCap)^2) + 
      I(0.5 * log(qLab)^2) + I(0.5 * log(qMat)^2) + I(log(qCap) * 
      log(qLab)) + I(log(qCap) * log(qMat)) + I(log(qLab) * log(qMat))
    Res.Df    RSS Df Sum of Sq     F  Pr(>F)  
  1    136 58.534                             
  2    130 53.447  6    5.0866 2.062 0.06202 .
  ---
  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1  
```

---

## Desarrollo Ejercicio 1 (4)

Con los resultados de:
* Test de Wald
* Test de Razón de Verosimilitud
* ANOVA

Se concluye que es preferible la estimación translogarítmica.
