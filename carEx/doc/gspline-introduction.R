## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, fig.width=6.5, fig.height=6.5)

# print.gspline <- function(x, show.function=FALSE, verbose=FALSE, ...){
#     periodic <- get("periodic", environment(x))
#     knots <- get("knots", environment(x))
#     degree <- get("degree", environment(x))
#     smooth <- get("smoothness", environment(x))
#     smooth <- sapply(smooth, max)
#     cat("\n", if (periodic) "Periodic spline with" else "Spline with")
#     cat("\n  knots at ", knots)
#     if (length(unique(degree)) == 1) cat("\n  degree", degree[1]) else cat("\n  degrees:", degree)
#     if (length(unique(smooth)) == 1) cat("\n  order of smoothness", smooth[1]) else cat("\n  orders of smoothness:", smooth)
#     if(show.function) {
#         cat("\n  Spline-generating function:\n")
#         NextMethod()
#     }
#     if (verbose){
#         objects <- ls(envir=environment(x))
#         for (object in objects){
#             cat("\n  ", object, "\n")
#             print(get(object, environment(x)))
#         }
#     }
#     invisible(x)
# }
# 
# print.gspline_matrix <- function(x, ...) {
#     xx <- x
#     class(xx) <- "matrix"
#     print(xx, ...)
#     invisible(x)
# }

# print.gsp <- function(x, strip.attributes=TRUE, ...){
#     nms <- colnames(x)
#     ncol <- ncol(x)
#     xx <- x
#     if (strip.attributes) {
#         attributes(xx) <- NULL
#         xx <- matrix(xx, ncol=ncol)
#         colnames(xx) <- nms
#     }
#     else (xx <- unclass(xx))
#     print(zapsmall(xx), ...)
#     attrs <- attributes(x)$spline.attr
#     cat("\n knots at ", attrs$knots)
#     deg <- attrs$degree
#     sm <- attrs$smooth
#     if (length(unique(deg)) == 1) cat("\n degree", deg[1]) else cat("\n degrees:", deg)
#     if (length(unique(sm)) == 1) cat("\n order of smoothness", sm[1]) else cat("\n orders of smoothness:", deg)
#     invisible(x)
# }

## ------------------------------------------------------------------------
set.seed(12345) # for reproducibility
x <- runif(200, 0, 10)
x <- sort(x)
y <- cos(1.25*(x + 1)) + x/5  + 0.5*rnorm(200)
Ey <- cos(1.25*(x + 1)) + x/5
plot(x, y)
curve(cos(1.25*(x + 1)) + x/5, add=TRUE, lty=2, lwd=2) # population regression

## ------------------------------------------------------------------------
plot(x, y, main="Piecewise Constant Fit")
curve(cos(1.25*(x + 1)) + x/5, add=TRUE, lty=2, lwd=2)
t <- c(10/3, 20/3) # knots
abline(v=t, lty=3)
mtext(c(expression(t[1]), expression(t[2])), side=1, line=0.5, at=t) 
group <- cut(x, breaks=c(-Inf, t, Inf))
means <- tapply(y, group, mean) # within-interval means
x0 <- c(0, t, 10) # knots augmented with boundaries
for (i in 1:3) lines(x0[c(i, i+1)], rep(means[i],2), lwd=2)
yhat1 <- means[group] # fitted values
mean((Ey - yhat1)^2) # RMSE

## ------------------------------------------------------------------------
mods2 <- by(data.frame(x=x, y=y, group=group), group, 
    function(df) lm(y ~ x, data=df)) # within-group linear regressions
plot(x, y, main="Piecewise Linear Fit")
curve(cos(1.25*(x + 1)) + x/5, add=TRUE, lty=2, lwd=2)
abline(v=t, lty=3)
mtext(c(expression(t[1]), expression(t[2])), side=1, line=0.5, at=t) 
for (j in 1:3){
    x1 <- x0[c(j, j + 1)]
    y1 <- predict(mods2[[j]], list(x=x1))
    lines(x1, y1, lwd=2) # draw within-group regression lines
}
yhat2 <- unlist(lapply(mods2, fitted))
mean((Ey - yhat2)^2) # RMSE

## ------------------------------------------------------------------------
x1 <- x # define spline regressors
x2 <- (x - t[1]) * (x > t[1])
x3 <- (x - t[2]) * (x > t[2])
mod3 <- lm(y ~ x1 + x2 + x3) # linear regression spline model
plot(x, y, main="Linear Regression Spline")
curve(cos(1.25*(x + 1)) + x/5, add=TRUE, lty=2, lwd=2)
abline(v=t, lty=3)
mtext(c(expression(t[1]), expression(t[2])), side=1, line=0.5, at=t)
x01 <- x0
x02 <- (x0 - t[1]) * (x0 > t[1])
x03 <- (x0 - t[2]) * (x0 > t[2])
lines(x0, predict(mod3, list(x1=x01, x2=x02, x3=x03)), lwd=2) # draw fitted lines
yhat3 <- fitted(mod3)
mean((Ey - yhat3)^2) # RMSE

## ------------------------------------------------------------------------
mods4 <- by(data.frame(x=x, y=y, group=group), group, # within-interval cubic regressions
    function(df) lm(y ~ poly(x, degree=3, raw=TRUE), data=df))
plot(x, y, main="Piecewise Cubic Fit")
curve(cos(1.25*(x + 1)) + x/5, add=TRUE, lty=2, lwd=2)
abline(v=t, lty=3)
mtext(c(expression(t[1]), expression(t[2])), side=1, line=0.5, at=t)
xx <- seq(0, 10, length=500)
for (j in 1:3){
    xj <- xx[xx >= x0[j] & xx < x0[j + 1]]
    yj <- predict(mods4[[j]], list(x=xj))
    lines(xj, yj, lwd=2)  # draw within-interval cubics
}
yhat4 <- unlist(lapply(mods4, fitted))
mean((Ey - yhat4)^2) # RMSE

## ------------------------------------------------------------------------
mod5 <- lm(y ~ poly(x1, degree=3, raw=TRUE) + 
               poly(x2, degree=3, raw=TRUE) + 
               poly(x3, degree=3, raw=TRUE))
plot(x, y, main="Cubic Regression Spline with Order-0 Smoothness")
curve(cos(1.25*(x + 1)) + x/5, add=TRUE, lty=2, lwd=2)
abline(v=t, lty=3)
mtext(c(expression(t[1]), expression(t[2])), side=1, line=0.5, at=t)
x01 <- xx
x02 <- (xx - t[1]) * (xx > t[1])
x03 <- (xx - t[2]) * (xx > t[2])
lines(xx, predict(mod5, list(x1=x01, x2=x02, x3=x03)), lwd=2)
yhat5 <- fitted(mod5)
mean((Ey - yhat5)^2) # RMSE

## ------------------------------------------------------------------------
mod6 <- lm(y ~ poly(x1, degree=3, raw=TRUE) + I(x2^2) + I(x3^2) + I(x2^3) + I(x3^3))
plot(x, y, main="Cubic Regression Spline with Order-1 Smoothness")
curve(cos(1.25*(x + 1)) + x/5, add=TRUE, lty=2, lwd=2)
abline(v=t, lty=3)
mtext(c(expression(t[1]), expression(t[2])), side=1, line=0.5, at=t)
lines(xx, predict(mod6, list(x1=x01, x2=x02, x3=x03)), lwd=2)
yhat6 <- fitted(mod6)
mean((Ey - yhat6)^2) # RMSE

## ------------------------------------------------------------------------
mod7 <- lm(y ~ poly(x1, degree=3, raw=TRUE) + I(x2^3) + I(x3^3))
plot(x, y, main="Cubic Regression Spline with Order-2 Smoothness")
curve(cos(1.25*(x + 1)) + x/5, add=TRUE, lty=2, lwd=2)
abline(v=t, lty=3)
mtext(c(expression(t[1]), expression(t[2])), side=1, line=0.5, at=t)
lines(xx, predict(mod7, list(x1=x01, x2=x02, x3=x03)), lwd=2)
yhat7 <- fitted(mod7)
mean((Ey - yhat7)^2) # RMSE

## ------------------------------------------------------------------------
library(carEx)
sp_pc <- gspline(knots=t, degree=0, smoothness=-1)
sp_pc
mod.gsp1 <- lm(y ~ sp_pc(x))
all.equal(as.vector(yhat1), as.vector(fitted(mod.gsp1)))
plot(x, y, main="Piecewise Constant Fit Using gspline()")
curve(cos(1.25*(x + 1)) + x/5, add=TRUE, lty=2, lwd=2)
abline(v=t, lty=3)
mtext(c(expression(t[1]), expression(t[2])), side=1, line=0.5, at=t) 
lines(seq(0, 10, length=1000), 
      predict(mod.gsp1, newdata=list(x=seq(0, 10, length=1000))),
      lwd=2)

## ------------------------------------------------------------------------
sp_pl <- gspline(knots=t, degree=1, smoothness=-1)
sp_pl
mod.gsp2 <- lm(y ~ sp_pl(x))
all.equal(as.vector(yhat2), as.vector(fitted(mod.gsp2)))

## ------------------------------------------------------------------------
sp_l <- gspline(knots=t, degree=1, smoothness=0)
sp_l
mod.gsp3 <- lm(y ~ sp_l(x))
all.equal(as.vector(yhat3), as.vector(fitted(mod.gsp3)))

## ------------------------------------------------------------------------
sp_pc <- gspline(knots=t, degree=3, smoothness=-1)
sp_pc
mod.gsp4 <- lm(y ~ sp_pc(x))
all.equal(as.vector(yhat4), as.vector(fitted(mod.gsp4)))

## ------------------------------------------------------------------------
sp_c0 <- gspline(knots=t, degree=3, smoothness=0)
sp_c0
mod.gsp5 <- lm(y ~ sp_c0(x))
all.equal(as.vector(yhat5), as.vector(fitted(mod.gsp5)))

## ------------------------------------------------------------------------
sp_c1 <- gspline(knots=t, degree=3, smoothness=1)
sp_c1
mod.gsp6 <- lm(y ~ sp_c1(x))
all.equal(as.vector(yhat6), as.vector(fitted(mod.gsp6)))

## ------------------------------------------------------------------------
sp_c <- gspline(knots=t, degree=3, smoothness=2)
sp_c
mod.gsp7 <- lm(y ~ sp_c(x))
all.equal(as.vector(yhat7), as.vector(fitted(mod.gsp7)))

## ------------------------------------------------------------------------
library(splines)
mod.bs3 <- lm(y ~ bs(x, knots=t, degree=1))
all.equal( as.vector(fitted(mod.gsp3)), as.vector(fitted(mod.bs3)))
plot(x, y, main="Linear Regression Spline Using bs()")
curve(cos(1.25*(x + 1)) + x/5, add=TRUE, lty=2, lwd=2)
abline(v=t, lty=3)
mtext(c(expression(t[1]), expression(t[2])), side=1, line=0.5, at=t)
lines(seq(0, 10, length=1000), 
      predict(mod.bs3, newdata=list(x=seq(min(x), max(x), length=1000))),
      lwd=2)

## ------------------------------------------------------------------------
mod.bs7 <- lm(y ~ bs(x, knots=t, degree=3))
all.equal(as.vector(fitted(mod.gsp7)), as.vector(fitted(mod.bs7)))

## ------------------------------------------------------------------------
x <- 0:10
t <- c(10/3, 20/3)
x1 <- x # define spline regressors
x2 <- (x - t[1]) * (x > t[1])
x3 <- (x - t[2]) * (x > t[2])
X <- cbind(x1, x1^2, x1^3, x2^3, x3^3)
colnames(X) <- c("x1", "x1^2", "x1^3", "x2^3", "x3^3")
round(X, 5)

sp <- gspline(knots=t, degree=3, smoothness=2)
sp
X.gsp <- sp(x)
X.gsp

X.bs <- bs(x, knots=t, degree=3)
X.bs


## ------------------------------------------------------------------------
X / X.gsp

## ------------------------------------------------------------------------
round(X %*% diag(c(1, 1/2, 1/6, 1/6, 1/6)), 5)

## ------------------------------------------------------------------------
all.equal(fitted(lm(X.bs ~ X.gsp - 1)), X.bs, check.attributes=FALSE)

## ------------------------------------------------------------------------
round(cor(X), 3)
round(cor(X.gsp), 3)
round(cor(X.bs), 3)

## ------------------------------------------------------------------------
kappa(cbind(1, X))
kappa(cbind(1, X.gsp))
kappa(cbind(1, X.bs))

## ------------------------------------------------------------------------
X.ns <- ns(x, knots=c(10/3, 20/3), Boundary.knots=c(0, 10))
round(X.ns, 5)

## ------------------------------------------------------------------------
sp_ns <- gspline(knots=c(0, 10/3, 20/3, 10), 
             degree=c(1, 3, 3, 3, 1), 
             smoothness=c(2, 2, 2, 2))
sp_ns
X.gsp.ns <- sp_ns(x)
X.gsp.ns

all.equal(fitted(lm(X.ns ~ X.gsp - 1)), X.ns, check.attributes=FALSE)

