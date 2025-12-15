## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, comment='', message = FALSE)
library(carEx)
library(latticeExtra)

sp <- gspline(1)
Dmat <- environment(sp)$Dmat
Emat <- environment(sp)$Emat
basis <- environment(sp)$basis
Xmat <- environment(sp)$Xmat
Pcon <- environment(sp)$Pcon
Xf <- environment(sp)$Xf

Cmat <-
function( knots, degree, smoothness, lin = NULL, intercept = 0, signif = 3) {
  # GM 2013-06-13
  #	add lin: contraints, 
  # generates constraint matrix
  # GM: 2019_02_22: added facility to input smoothness as a list 
  #    for smoothness constraints that don't have the form 0:smoothness[[i]]
	
  dm = max(degree)
  
  # intercept
  
  cmat = NULL
  if( !is.null(intercept))  cmat = rbind( cmat, "Intercept" =
                                            Xf( intercept, knots, dm, D=0 ))
  # continuity constraints
 
  for ( i in seq_along(knots) ) {
    k <- knots[i]
    sm <- smoothness[[i]]
    if ( max(sm) > -1 ) {  # sm = -1 corresponds to discontinuity
	    if(!is.list(smoothness)) sm <- 0:sm
      
      dmat <- Xf( k, knots, dm, D = sm, F ) -   
      	Xf( k, knots, dm, D = sm, T )
      rownames( dmat ) <- paste( "C(",signif(k, signif),").",
                                sm, sep = '')
      cmat <- rbind( cmat,  dmat)
    }
  }
  
  # reduced degree constraints
  
  degree <- rep( degree, length.out = length(knots) + 1)
  for ( i in seq_along( degree)) {
    di <- degree[i]
    
    if ( dm > di ) {
      dmat <- diag( (length(knots) + 1) * (dm +1)) [  (i - 1)*(dm + 1) +
                                                       1 + seq( di+1,dm), , drop = F]
      rownames( dmat ) = paste( "I.", i,".",seq(di+1,dm),sep = '')
      cmat = rbind( cmat, dmat)
    }
  }
  
  # add additional linear constraints
  
  if( ! is.null(lin)) cmat <- rbind(cmat,lin) # GM:2013-06-13
  rk = qr(cmat)$rank
  spline.rank = ncol(cmat) - rk
  attr(cmat,"ranks") = c(npar.full = ncol(cmat), C.n = nrow(cmat),
                         C.rank = rk , spline.rank = spline.rank )
  attr(cmat,"d") = svd(cmat) $ d
  cmat
  
}

## ------------------------------------------------------------------------
Xf(0:9, knots = c(3,7), degree = 3)

## ------------------------------------------------------------------------
Cmat(knots = c(3, 7), degree = c(2, 3, 2), smooth = c(1, 2))

## ------------------------------------------------------------------------
Emat(knots = c(3, 7), degree = c(2, 3, 2), smooth = c(1, 2))

## ------------------------------------------------------------------------
sp <- gspline(knots = c(3, 7), degree = c(2, 3, 2), smoothness = c(1, 2))
sp(0:9)

## ------------------------------------------------------------------------
df <- data.frame(x = 0:10)
set.seed(123)
df <- within(df, y <- -2* (x-5) + .1 * (x-5)^3 + rnorm(x))
df <- rbind(df, data.frame(x = seq(0,10,.1), y = NA))
df <- df[order(df$x),]
plot(y~x, df, pch = 16)
fit <- lm(y ~ sp(x), data = df)
summary(fit)
lines(df$x , predict(fit, df))

## ------------------------------------------------------------------------
sp <- gspline(knots = c(3,7), degree = c(2,3,2), smoothness = c(1,2))
sp(0:9)

## ------------------------------------------------------------------------
sp(c(2, 3, 7), D = 1)

## ------------------------------------------------------------------------
sp(c(3, 3, 3), D = 2, limit = c(-1,0,1))

## ------------------------------------------------------------------------
# customized panel function
gpanel.fit <- function (x, y, fit, lower, upper, subscripts, ..., type, group.number, 
    alpha, col, col.line, col.symbol, border = F, font, fontface) {
    if (!missing(fit)) {
        if (missing(col)) 
            col <- "blue"
        if (!missing(group.number)) {
            col <- col.line
        }
        if (!missing(subscripts)) {
            fit <- fit[subscripts]
        }
        dd <- data.frame(x = x, fit = fit)
        dd <- dd[order(dd$x), ]
        panel.lines(dd$x, dd$fit, ..., col = col, type = "l")
    }
    if (!missing(lower)) {
        if (missing(alpha) || alpha == 1) 
            alpha <- 0.3
        if (missing(col)) 
            col <- "blue"
        if (!missing(group.number)) {
            col <- col.symbol
        }
        if (!missing(subscripts)) {
            upper <- upper[subscripts]
            lower <- lower[subscripts]
        }
        dd <- data.frame(x = x, lower = lower, upper = upper)
        dd <- dd[order(dd$x), ]
        panel.polygon(c(dd$x, rev(dd$x)), c(dd$upper, rev(dd$lower)), 
            border = border, col = col, alpha = alpha, ...)
    }
}


xpred <- seq(0,10, .05)

A.1 <- cbind(0, sp(xpred, D = 1))
ww.1 <- as.data.frame(wald(fit, A.1))

A.2 <- cbind(0, sp(xpred, D = 2))
ww.2 <- as.data.frame(wald(fit, A.2))

plot(xpred, ww.1$coef, type = 'l')
plot(xpred, ww.2$coef, type = 'l')
library(latticeExtra)
ww.1$x <- xpred
xyplot(coef ~ x, ww.1, type = 'l',
 	   lower = ww.1$L2, upper = ww.1$U2,
 	   ylab = 'first derivative',
 	   subscripts = TRUE) +
 	layer(gpanel.fit(...))
head(ww.1)

## ------------------------------------------------------------------------
unemp <- Unemployment
head(unemp)
library(lattice)
library(latticeExtra)
xyplot(unemployment ~ date, unemp) + layer(panel.abline(v = as.Date('2008-12-15')))

toyear <- function(x) {
  # number of years from January 1, 2000
  (as.numeric(x) - as.numeric(as.Date('2000-01-01')))/365.25
}
unemp <- within(
  unemp,
  {
    year <- toyear(date)
    month <- as.numeric(format(date, '%m'))
  })
summary(unemp)
quintiles <- quantile(unemp$year, 1:4/5)
sp2 <- gspline(quintiles, 2, 1) # quadratic spline
sp3 <- gspline(quintiles, 3, 2) # cubic spline    

quintiles_with_crash <- sort(c(quintiles, toyear(as.Date('2008-12-15'))))

sp2d <- gspline(quintiles_with_crash, 2, c(1,1,-1,1,1))
sp3d <- gspline(quintiles_with_crash, 3,  c(2,2,-1,2,2))

fit2 <- lm(unemployment ~ sp2(year), unemp)
summary(fit2)
unemp$fit2 <- predict(fit2)
fit3 <- lm(unemployment ~ sp3(year), unemp)
summary(fit3)
unemp$fit3 <- predict(fit3)

fit2d <- lm(unemployment ~ sp2d(year), unemp)
summary(fit2d)
unemp$fit2d <- predict(fit2d)
fit3d <- lm(unemployment ~ sp3d(year), unemp)
summary(fit3d)
unemp$fit3d <- predict(fit3d)

pp <- xyplot(unemployment ~ date, unemp, type = 'b',
             col = 'gray',
             key = list(
               corner = c(1,1),
               text = list(lab = c('quadratic','cubic','quadratic disc.','cubic disc.')),
               lines = list(col= c('red','blue','red','blue'),
                            lty = c(1,1,3,3))
               )) +
  layer(panel.lines(x, unemp$fit3, col = 'blue')) +
  layer(panel.lines(x, unemp$fit2, col = 'red')) + 
  layer(panel.lines(x, unemp$fit3d, col = 'blue', lty = 2)) +
  layer(panel.lines(x, unemp$fit2d, col = 'red', lty = 2)) 
pp


## ------------------------------------------------------------------------
per3 <- gspline(12 * 1:5/5, 3, 2, periodic = TRUE)
fitper3 <-  lm(unemployment ~ sp3d(year) + per3(month), unemp)
summary(fitper3)
unemp$fitper3 <- predict(fitper3)
pp <- xyplot(unemployment ~ date, unemp, type = 'b',
             col = 'gray') +
  layer(panel.lines(x, unemp$fitper3, col = 'blue'))  
pp


## ------------------------------------------------------------------------

pred <- data.frame(month = seq(0,24,.01), year = 0)
pred$fitper3 <- predict(fitper3, newdata = pred)
xyplot(fitper3 ~ month, pred, type = 'l',
       xlim = c(0,24),
       scales = list( x = list( at =3 * 0:8)),
       ylab = 'seasonal unemployment') +
  layer(panel.abline(v = 12))


