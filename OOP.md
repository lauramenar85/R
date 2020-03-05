---
layout: post
published: true
date: '2020-03-05'
show_meta: true
comments: true
mathjax: false
gistembed: false
noindex: false
hide_printmsg: false
sitemap: true
summaryfeed: false
title: Notas curso OOP
description: Notas del curso de OOP de Datacamp
tags:
  - desarrollo
  - R
---

# Introducción

## Objetivos de la OOP y la programación funcional

* En paradigma funcional se piensa primero en la función y luego en la estructura de los datos
* En oop lo primero es la estructura de los datos y luego la funcionalidad (metodos)
* No es práctico para el análisis de datos, preferible un aproach funcional
* OOP, recomendado para GUI y APIS

## Los modelos de OOP en R

* Activos y maduros
    * S3: Esquema simple, solo implementa funciones genéricas
    * S4: Más complejo, usado principalmente en los paquetes de bioconductor
    * ReferenceClass: Un intento de oop más clasico al estilo java
    * R6: similar al sistema anterior pero implementado de forma más sencilla

* Deprecados
    * OOP

* No populares
    * proto
    * R.oo

* Experimentales
    *  R5
    *  mutatr

**Nota**: Apuntar a S3 o R6, S4 solo para paquetes de bioconductor

## Interrogar a los objetos

* `class()` y `typeof()`
* `mode()` y `storage.mode()` (mantenida por compatiblidad con s)

```r
type_info <- function(x)
{
  c(
    class = class(x), 
    typeof = typeof(x), 
    mode = mode(x), 
    storage.mode = storage.mode(x)
  )
}

# Create list of example variables
some_vars <- list(
  an_integer_vector = rpois(24, lambda = 5),
  a_numeric_vector = rbeta(24, shape1 = 1, shape2 = 1),
  an_integer_array = array(rbinom(24, size = 8, prob = 0.5), dim = c(2, 3, 4)),
  a_numeric_array = array(rweibull(24, shape = 1, scale = 1), dim = c(2, 3, 4)),
  a_data_frame = data.frame(int = rgeom(24, prob = 0.5), num = runif(24)),
  a_factor = factor(month.abb),
  a_formula = y ~ x,
  a_closure_function = mean,
  a_builtin_function = length,
  a_special_function = `if`
)

# Loop over some_vars calling type_info() on each element to explore them
lapply(some_vars, type_info)
```

* `array`: generalización de una matriz con un númer arbitrario de dimensiones
* `formula`: Para definir relaciones entre variables en el modelado y graficación de funciones

* Funciones:
    * `closures`
    * `builtin`
    * `special`

## Asignando clases

* `class(x) <- "some_class"`, para S3 y S4
* Definir la clase no modifica la naturaleza original del objeto

```r
> # Explore the structure of chess
> str(chess)
List of 2
 $ white:List of 6
  ..$ king   : chr "g1"
  ..$ queen  : chr "h4"
  ..$ bishops: chr [1:2] "c2" "g5"
  ..$ knights: chr(0) 
  ..$ rooks  : chr [1:2] "f1" "f6"
  ..$ pawns  : chr [1:6] "a2" "b2" "d4" "e3" ...
 $ black:List of 6
  ..$ king   : chr "g8"
  ..$ queen  : chr "d7"
  ..$ bishops: chr [1:2] "b7" "e7"
  ..$ knights: chr(0) 
  ..$ rooks  : chr [1:2] "a6" "f8"
  ..$ pawns  : chr [1:6] "a5" "c3" "c4" "d5" ...
 - attr(*, "class")= chr "chess_game"
> 
> # Override the class of chess
> class(chess) <- "chess_game"
> 
> # Is chess still a list?
> is.list(chess)
[1] TRUE
> 
> # How many pieces are left on the board?
> length(unlist(chess))
[1] 24
```

# S3

## Sobrecarga de funciones

Funcionaldidad dependiente del objeto al cual se aplican, Ej `summary()`. Se construye mediante:

* función
    * generic
    * method

Por ejemplo

* función `print()`
    *  generic: `function (x, ...) UseMethod("print")`
    *  methods:
        *  `print.Date`
        *  `print.function`
        *  `print.formula`
        *  etc.

La convención en S3 para definir las funciones es `<nombre de función>.<clase de objeto>`. Para chequear funciones: `is_s3_generic()` o `is_s3_method()`

```r
library(pryr)
is_s3_generic("t")           # generic transpose function
is_s3_method("t.data.frame") # transpose method for data.frames
is_s3_method("t.test")       # a function for Student's t-tests 
```

Se puede grear un método por defecto para considerar todos los casos no contemplados

```r
# Create get_n_elements
get_n_elements <- function(x, ...)
{
  UseMethod("get_n_elements")
}

# View get_n_elements
get_n_elements

# Create a data.frame method for get_n_elements
get_n_elements.data.frame <- function(x, ...) {
  nrow(x) * ncol(x)
}
# Call the method on the sleep dataset
n_elements_sleep <- get_n_elements(sleep)

# View the result
n_elements_sleep

# View predefined objects
ls.str()

# Create a default method for get_n_elements
get_n_elements.default <- function(x, ...) {
  length(unlist(x))
}

# Call the method on the ability.cov dataset
n_elements_ability.cov <- get_n_elements(ability.cov)
```

# Metodos

Para ver metodos `methods()`, sirve para S3 y S4

```r
# metodos de print
methods("print")

# metodos del objeto lm
methods(class="lm")
```

Si solo queremos metodos de S3, tenemos `.S3methods()`

## S3 y primitivas

Las _primitivas_ son funciones normalmente escritas en `C` por razones de
performance, por ejemplo `sin()`, o  ``+`()` o `if()` o `for()`. Estas
funciones también pueden ser genericas, en este caso trabajan un poco distinto
a las funciones genericas no primitivas. Para saber cual son, diponemos de `.S3PrimitiveGenerics`. 

¿En que difieren genericas regulares y genericas primitivas?

Una generica primitiva no generará error cuando no exista un metodo específico para porcesar cierto objeto. Ejemplo `length()`.

## Múltiples clases

Un objeto puede heradar varias clases, que no es más que conjunto de cadenas. Para saber fehacientemente si un objeto hereda cierta clase, podríamos:

1. Si existe el método: `is.nuevaclase()`
2. Usar `inherits()`

La herencia se puede aplicar ejecutando multiples metodos mediante `NextMethod("clase padre")`

Ejemplo:

````r
# Inspect your workspace
ls.str()


# cat method
what_am_i.cat <- function(x, ...)
{
  # Write a message
  message("I'm a cat")
  # Call NextMethod
  NextMethod("what_am_i")
}

# mammal method
what_am_i.mammal <- function(x, ...)
{
  # Write a message
  message("I'm a mammal")
  # Call NextMethod
  NextMethod("what_am_i")
}

# character method
what_am_i.character <- function(x, ...)
{
  # Write a message
  message("I'm a character vector")
}


# Call what_am_i()
what_am_i(kitty)
```

# R6

## Fabrica de objetos

R6 define las clases como un constructor de objetos, una fabrica.

* Cargar R6
* Definir la fabrica mediante `R6Class()`
* Definir el nombre de la clase, la convención es `CamelCase`
* Los campos se definen como una lista privada de elementos con nombre
* Para crear hay que invocar al método `new()`


# Define microwave_oven_factory
microwave_oven_factory <- R6Class(
  "MicrowaveOven",
  private  = list(
    power_rating_watts = 800
  )
)
# View the microwave_oven_factory
microwave_oven_factory

# Make a new microwave oven
microwave_oven <- microwave_oven_factory$new()

## Encapsulation

* Separar la implementacion de los detalles para el usuario
* Los datos de la implementación va en la lista `private`
* Los metos del usuario va en `public`
* usar `private$` y `self$` para privados y publicos
* 

