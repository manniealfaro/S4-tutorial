
## @knitr env, include=FALSE, echo=FALSE, cache=FALSE
library("knitr")
opts_chunk$set(fig.align = 'center', 
               fig.show = 'hold', 
               par = TRUE,
               prompt = TRUE,
               eval = TRUE,
               stop_on_error = 1L,
               comment = NA)
options(replace.assign = TRUE, 
        width = 55)
set.seed(1)


## @knitr makedata1, tidy = FALSE
n <- 10
m <- 6
marray <- matrix(rnorm(n * m, 10, 5), ncol = m)
pmeta <- data.frame(sampleId = 1:m, 
                    condition = rep(c("WT", "MUT"), each = 3))


## @knitr makedata2, tidy= FALSE
rownames(pmeta) <- colnames(marray) <- LETTERS[1:m]
fmeta <- data.frame(geneId = 1:n, 
                    pathway = sample(LETTERS, n, replace = TRUE))
rownames(fmeta) <- 
    rownames(marray) <- paste0("probe", 1:n)
maexp <- list(marray = marray,
              fmeta = fmeta,
              pmeta = pmeta)
rm(marray, fmeta, pmeta)
str(maexp)


## @knitr access
maexp$pmeta
summary(maexp$marray[, "A"])
wt <- maexp$pmeta[, "condition"] == "WT"
maexp$marray["probe8", wt]
maexp[["marray"]]["probe3", !wt]


## @knitr bw1, dev='pdf', echo=TRUE
boxplot(maexp$marray)


## @knitr subset
x <- 1:5
y <- 1:3
marray2 <- maexp$marray[x, y]
fmeta2 <- maexp$fmeta[x, ]
pmeta2 <- maexp$pmeta[y, ]
maexp2 <- list(marray = marray2,
               fmeta = fmeta2,
               pmeta = pmeta2)
rm(marray2, fmeta2, pmeta2)
str(maexp2)


## @knitr makeclass, tidy = FALSE
MArray <- setClass("MArray",
                   slots = c(marray = "matrix",
                       fmeta = "data.frame",
                       pmeta = "data.frame"))


## @knitr makeobject, tidy = FALSE
## an empty object
MArray()
ma <- MArray(marray = maexp[[1]],
             pmeta = maexp[["pmeta"]],
             fmeta = maexp[["fmeta"]])       
class(ma)
ma


## @knitr accesswithat
ma@pmeta


## @knitr showmeth
show
isGeneric("show")
hasMethod("show")


## @knitr showmethod, tidy = FALSE
setMethod("show", 
          signature = "MArray", 
          definition = function(object) {
              cat("An object of class ", class(object), "\n", sep = "")
              cat(" ", nrow(object@marray), " features by ", 
                  ncol(object@marray), " samples.\n", sep = "")
              invisible(NULL)
          })
ma 


## @knitr makegen
setGeneric("marray", function(object) standardGeneric("marray"))


## @knitr makemeth, tidy = FALSE
setMethod("marray", "MArray", 
          function(object) object@marray)
marray(ma)


## @knitr otheraccess, echo = FALSE
setGeneric("pmeta", function(object) standardGeneric("pmeta"))
setGeneric("fmeta", function(object) standardGeneric("fmeta"))
setMethod("pmeta", "MArray", function(object) object@pmeta)
setMethod("fmeta", "MArray", function(object) object@fmeta)


## @knitr syntaticsugar
letters[1:3]
`[`(letters, 1:3)


## @knitr subsetma
setMethod("[", "MArray",
          function(x,i,j,drop="missing") {              
              .marray <- x@marray[i, j]
              .pmeta <- x@pmeta[j, ]
              .fmeta <- x@fmeta[i, ]
              MArray(marray = .marray,
                     fmeta = .fmeta,
                     pmeta = .pmeta)
          })
ma[1:5, 1:3]


## @knitr setval, tidy = FALSE
setValidity("MArray", function(object) {
    msg <- NULL
    valid <- TRUE
    if (nrow(marray(object)) != nrow(fmeta(object))) {
        valid <- FALSE
        msg <- c(msg, 
                 "Number of data and feature meta-data rows must be identical.")
    }
    if (ncol(marray(object)) != nrow(pmeta(object))) {
        valid <- FALSE
        msg <- c(msg, 
                 "Number of data rows and sample meta-data columns must be identical.")
    }
    if (!identical(rownames(marray(object)), rownames(fmeta(object)))) {
        valid <- FALSE
        msg <- c(msg, 
                 "Data and feature meta-data row names must be identical.")        
    }
    if (!identical(colnames(marray(object)), rownames(pmeta(object)))) {
        valid <- FALSE
        msg <- c(msg, 
                 "Data row names and sample meta-data columns names must be identical.")        
    }
    if (valid) TRUE else msg 
})
validObject(ma)


## @knitr notvalid
x <- marray(ma)
y2 <- y <- fmeta(ma)
z2 <- z <- pmeta(ma)
rownames(y) <- 1:nrow(y)
rownames(z) <- letters[1:6]
MArray(marray = x, fmeta = y, pmeta = z)
MArray(marray = x, fmeta = y2, pmeta = z2) 


## @knitr introspec
slotNames(ma)
getClass("MArray")


## @knitr sessioninfo, results='asis', echo=FALSE
toLatex(sessionInfo())

