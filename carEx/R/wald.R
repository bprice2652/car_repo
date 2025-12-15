# moved here 2019-05-23 by J. Fox

## wald.R
## This a collection of functions designed to facilitate testing hypotheses
## with Wald tests.
## The methods are readily extended to any fitting method that returns a vector
## of estimated parameters and an estimated variance matrix.
## Extensions are implemented through the 'getFix' generic function.
##
##
## see also Leff
## Changes:
##
## 2018 04 07: commented out isnarow code in getX since it seems in error
## 2014 06 04: changed fit@fixef to fixef(fit) in a number of 'getFix' methods
## October 2, 2011:  modified 'wald' to better handle rank-deficient models
##                   previously columns of L and columns and rows of vcov
##                   corresponding to NAs in beta were deleted ignoring the
##                   possibility that L beta is not estimable if any
##                   non-zero element of L multiplies an NA in beta.
##
## 2013 06 18: added df argument to wald to override denominator dfs. Useful
##             for saturated binomial fits or other binomials where residual
##             dfs are not appropriate.
##
## 2013 09 17: added getFix.multinom with df = Inf
##

# scraps:
# L <- list( 'marginal value of education' =Lform( fit, form = list(0, 1, 2 *
# education, 0, 0, type == 'prof', type == 'wc', 2 * education * (type ==
# 'prof'), 2 * education * (type == 'wc')), data = Prestige)) wald( fit, L )
# chat <- coef( wald( fit, L ), se = 2) xyplot( coef +coefp+coefm ~ education
# | type, cbind(Prestige,chat)[order(Prestige$education),], type = 'l')
# xyplot( chat~ education | type, Prestige)
#
# # This approach can be used to predict responses with a fitting method that
# has a # 'model.matrix' method but does not have a 'predict' method or does
# not return # estimated standard errors with its 'predict' method.
#
# datafit <- model.frame(fit) # or just the data frame used for the fit ww <-
# wald(fit, model.matrix(fit)) datafit <- cbind(datafit, coef(ww, se =2)) #
# ...etc as above


wald <- function(fit, Llist = "", clevel = 0.95,
             pred = NULL,
             data = NULL, debug = FALSE , maxrows = 25,
             full = FALSE, fixed = FALSE,
             invert = FALSE, method = 'svd',
             df = NULL, pars = NULL,...) {
        # New version with support for stanfit
        if (full) return(wald(fit, getX(fit)))
        if(!is.null(pred)) return(wald(fit, getX(fit,pred)))
        dataf <- function(x,...) {
            x <- cbind(x)
            rn <- rownames(x)
            if(length(unique(rn)) < length(rn)) rownames(x) <- NULL
            data.frame(x, ...)
        }
        as.dataf <- function(x, ...) {
            x <- cbind(x)
            rn <- rownames(x)
            if(length(unique(rn)) < length(rn)) rownames(x) <- NULL
            as.data.frame(x, ...)
        }
        unique.rownames <- function(x) {
            ret <- c(tapply(1:length(x), x, function(xx) {
                if(length(xx) == 1) ""
                else 1:length(xx)
            })) [tapply(1:length(x), x)]
            ret <- paste(x, ret, sep="")
            ret
        }
        if(inherits(fit, 'stanfit')) {
            fix <- if(is.null(pars)) getFix(fit) else getFix(fit,pars=pars,...)
            if(!is.matrix(Llist)) stop(
                paste('Sorry: wald needs Llist to be a n x',
                      length(fix$fixed),'matrix for this stanfit object'))
        } else {
            fix <- getFix(fit)
        }
        beta <- fix$fixed
        vc <- fix$vcov
        
        dfs <- if(is.null(df) ) fix$df else df + 0*fix$df
        
        if(is.character(Llist) ) Llist <- structure(list(Llist), names=Llist)
        if(!is.list(Llist)) Llist <- list(Llist)
        
        ret <- list()
        for (ii in 1:length(Llist)) {
            ret[[ii]] <- list()
            Larg <- Llist[[ii]]
            # Create hypothesis matrix: L
            L <- NULL
            if(is.character(Larg)) {
                L <- Lmat(fit,Larg, fixed = fixed, invert = invert)
            } else {
                if(is.numeric(Larg)) {   # indices for coefficients to test
                    if(is.null(dim(Larg))) {
                        if(debug) disp(dim(Larg))
                        if((length(Larg) < length(beta)) && (all(Larg>0)||all(Larg<0)) ) {
                            L <- diag(length(beta))[Larg,]
                            dimnames(L) <- list( names(beta)[Larg], names(beta))
                        } else L <- rbind( Larg )
                    }
                    else L <- Larg
                }
            }
            if (debug) {
                disp(Larg)
                disp(L)
            }
            # get data attribute, if any, in case it gets dropped
            Ldata <- attr( L , 'data')
            
            ## identify rows of L that are not estimable because they depend on betas that are NA
            Lna <- L[, is.na(beta), drop = FALSE]
            narows <- apply(Lna,1, function(x) sum(abs(x))) > 0
            
            L <- L[, !is.na(beta),drop = FALSE]
            ## restore the data attribute
            attr(L,'data') <- Ldata
            beta <- beta[ !is.na(beta) ]
            
            ## Anova
            if( method == 'qr' ) {
                qqr <- qr(t(na.omit(L)))
                # Qqr <- Q(t(L))
                L.rank <- qqr$rank
                # L.rank <- attr(Qqr,'rank')
                # L.miss <- attr(Qqr,'miss')
                if(debug)disp( t( qr.Q(qqr)))
                L.full <- t(qr.Q(qqr))[ 1:L.rank,,drop=FALSE]
                #L.full <- t(Qqr[!L.miss,])[ 1:L.rank,,drop=F]
            } else if ( method == 'svd' ) {
                if(debug) disp(L)
                #              if(debug)disp( t(na.omit(t(L))))
                #              sv <- svd( t(na.omit(t(L))) , nu = 0 )
                sv <- svd( na.omit(L) , nu = 0 )
                
                if(debug)disp( sv )
                tol.fac <- max( dim(L) ) * max( sv$d )
                if(debug)disp( tol.fac )
                if ( tol.fac > 1e6 ) warning( "Poorly conditioned L matrix, calculated numDF may be incorrect")
                tol <- tol.fac * .Machine$double.eps
                if(debug)disp( tol )
                L.rank <- sum( sv$d > tol )
                if(debug)disp( L.rank )
                if(debug)disp( t(sv$v))
                L.full <- t(sv$v)[seq_len(L.rank),,drop = FALSE]
            } else stop("method not implemented: choose 'svd' or 'qr'")
            
            # from package(corpcor)
            # Note that the definition tol= max(dim(m))*max(D)*.Machine$double.eps
            # is exactly compatible with the conventions used in "Octave" or "Matlab".
            
            if (debug && method == "qr") {
                disp(qqr)
                disp(dim(L.full))
                disp(dim(vc))
                disp(vc)
            }
            if (debug) disp(L.full)
            if (debug) disp(vc)
            
            vv <-  L.full %*% vc %*% t(L.full)
            eta.hat <- L.full %*% beta
            Fstat <- (t(eta.hat) %*% qr.solve(vv,eta.hat,tol=1e-10)) / L.rank
            included.effects <- apply(L,2,function(x) sum(abs(x),na.rm=TRUE)) != 0
            denDF <- min( dfs[included.effects])
            numDF <- L.rank
            ret[[ii]]$anova <- list(numDF = numDF, denDF = denDF,
                                    "F-value" = Fstat,
                                    "p-value" = pf(Fstat, numDF, denDF, lower.tail = FALSE))
            ## Estimate
            
            etahat <- L %*% beta
            
            # NAs if not estimable:
            
            etahat[narows] <- NA
            if( nrow(L) <= maxrows ) {
                etavar <- L %*% vc %*% t(L)
                etasd <- sqrt( diag( etavar ))
            } else {
                etavar <- NULL
                etasd <- sqrt( apply( L * (L%*%vc), 1, sum))
            }
            
            denDF <- apply( L , 1 , function(x,dfs) min( dfs[x!=0]), dfs = dfs)
            
            aod <- cbind(
                Estimate=c(etahat),
                Std.Error = etasd,
                DF = denDF,
                "t-value" = c(etahat/etasd),
                "p-value" = 2*pt(abs(etahat/etasd), denDF, lower.tail =FALSE))
            colnames(aod)[ncol(aod)] <- 'p-value'
            if (debug ) disp(aod)
            if ( !is.null(clevel) ) {
                #print(aod)
                #print(aod[,'DF'])
                #print(aod[,'etasd'])
                hw <- qt(1 - (1-clevel)/2, aod[,'DF']) * aod[,'Std.Error']
                #print(hw)
                aod <- cbind( aod, LL = aod[,"Estimate"] - hw, UL = aod[,"Estimate"] + hw)
                #print(aod)
                if (debug ) disp(colnames(aod))
                labs <- paste(c("Lower","Upper"), format(clevel))
                colnames(aod) [ ncol(aod) + c(-1,0)] <- labs
            }
            if (debug ) disp(rownames(aod))
            aod <- as.dataf(aod)
            
            rownames(aod) <- rownames(as.dataf(L))
            # 
            # GM 2019_02_21: remove dependency on labs function in spida2
            #
            # labs(aod) <- names(dimnames(L))[1]
            ret[[ii]]$estimate <- aod
            ret[[ii]]$coef <- c(etahat)
            ret[[ii]]$vcov <- etavar
            ret[[ii]]$L <- L
            ret[[ii]]$se <- etasd
            ret[[ii]]$L.full <- L.full
            ret[[ii]]$L.rank <- L.rank
            if( debug ) disp(attr(Larg,'data'))
            data.attr <- attr(Larg,'data')
            if(is.null(data.attr) && !(is.null(data))) data.attr <- data
            ret[[ii]]$data <- data.attr
        }
        names(ret) <- names(Llist)
        attr(ret,"class") <- "wald"
        ret
    }

# Test
if(FALSE){
    library(nlme)
    fit <- lme(mathach ~ ses * Sex * Sector, hs, random = ~ 1|school)
    summary(fit)
    pred <- expand.grid( ses = seq(-2,2,1), Sex = levels(hs$Sex), Sector = levels(hs$Sector))
    pred
    wald(fit,model.matrix(fit,data=pred))
    model.matrix(fit,data = pred)
    model.matrix(~ ses * Sex * Sector,data=pred)
}


print.wald <- function(x, round = 6,...) {
	pround <- round - 1
    pformat <- function(x, digits = pround) {
        x <- format(xx <- round(x,digits))
        x[ as.double(xx) == 0 ] <- paste(c("<.",rep('0',digits-1),'1'),collapse="")
        x
    }
    rnd <- function(x,digits) {
        if (is.numeric(x)) x <- round(x,digits=digits)
        format(x)
    }
    for( ii in 1:length(x)) {
        nn <- names(x)[ii]
        tt <- x[[ii]]
        ta <- tt$anova
        
        ta[["p-value"]] <- pformat(ta[["p-value"]])
        print(as.data.frame(ta,row.names=nn))
        te <- tt$estimate
        rowlab <- attr(te,"labs")
        
        te[,'p-value'] <- pformat( te[,'p-value'])
        if ( !is.null(round)) {
            for ( ii in 1:length(te)) {
                te[[ii]] <- rnd(te[[ii]],digits=round)
            }
        }
        # 
        # GM 2019_02_21: remove dependency on labs function in spida2
        #
        # labs(te) <- rowlab
        print(te,digits=round,...)
        cat("\n")
    }
    invisible(x)
}

# walddf <- function(fit, Llist = "", clevel = 0.95,
#                    data = NULL, debug = FALSE ,
#                    full = FALSE, fixed = FALSE,
#                    invert = FALSE, method = 'svd',
#                    df = NULL,
#                    se = 2, digits = 3, sep = '') {
#     obj <- wald(fit = fit, Llist = Llist, clevel = clevel,
#                 data = data, debug = debug ,
#                 full = FALSE, fixed = FALSE,
#                 invert = FALSE, method = 'svd',
#                 df = NULL)
#     ret <- as.data.frame.wald(obj,
#                               se = se, digits = digits,
#                               sep = sep)
#     ret
# }

coef.wald <- function( obj , se = FALSE ) {
    if ( length(obj) == 1) {
        ret <-
            ret <- obj[[1]]$coef
        if ( is.logical(se) && (se == TRUE) ) {
            ret <- cbind( coef = ret, se = obj[[1]]$se)
            
        } else if ( se > 0 ){
            ret <- cbind( coef = ret, coefp = ret+se*obj[[1]]$se,
                          coefm = ret - se*obj[[1]]$se)
            attr(ret,'factor') <- se
        }
    }
    else ret <- sapply( obj, coef.wald )
    ret
}

##
##
##   Functions to perform a GLH on lm, lme or lmer models
##   August 13, 2005
##
##
##
##   Lmat: generate a hypothesis matrix based on a pattern
##
##   glh
##   Lmat
##   Ldiff
##   getFix
##
##   print.glh
##


getFix <- function(fit,...) UseMethod("getFix")

getFix.multinom <- function(fit,...) {
    ret <- list()
    ret$fixed <- c(t(coef(fit)))
    ret$vcov <- vcov(fit)
    names(ret$fixed) <- rownames(ret$vcov)
    df <- nrow(na.omit(cbind(fit$residuals))) - length(ret$fixed)
    ret$df <- rep( df, length(ret$fixed))
    ret
}

getFix.lm <- function(fit,...) {
    ss <- summary(fit)
    ret <- list()
    ret$fixed <- coef(fit)
    ret$vcov <- ss$sigma^2 * ss$cov.unscaled
    ret$df <- rep(ss$df[2], length(ret$fixed))
    ret
}

getFix.glm <- function(fit,...) {
    ss <- summary(fit)
    ret <- list()
    ret$fixed <- coef(fit)
    ret$vcov <- vcov(fit)
    ret$df <- rep(ss$df.residual, length(ret$fixed))
    ret
}

getFix.lme <- function(fit,...) {
#    if(!require(nlme)) stop("nlme package not available")
    ret <- list()
    ret$fixed <- nlme::fixef(fit)
    ret$vcov <- fit$varFix
    ret$df <- fit$fixDF$X
    ret
}

getFix.gls <- function(fit,...) {
#    if(!require(nlme)) stop("nlme package not available")
    ret <- list()
    ret$fixed <-coef(fit)
    ret$vcov <- vcov(fit)
    ds <- fit$dims
    df <- ds[[1]] - sum( unlist( ds[-1]))
    ret$df <- rep(df, length(coef(fit)))
    ret
}


getFix.lmer <- function(fit,...) {
    # 2014 06 04: changed fit@fixef to fixef(fit)
    ret <- list()
    ret$fixed <- lme4::fixef(fit)
    ret$vcov <- as.matrix( vcov(fit) )
    # ret$df <- Matrix:::getFixDF(fit)
    ret$df <- rep( Inf, length(ret$fixed))
    ret
}

# getFix.glmer <- function(fit,...) {
#     # 2014 06 04: changed fit@fixef to fixef(fit)
#     
#     ret <- list()
#     ret$fixed <- lme4::fixef(fit)
#     ret$vcov <- as.matrix(vcov(fit))
#     # ret$df <- Matrix:::getFixDF(fit)
#     ret$df <- rep( Inf, length(ret$fixed))
#     ret
# }


getFix.merMod <- function(fit,...) {
    # 2014 06 04: changed fit@fixef to fixef(fit)
    
    ret <- list()
    ret$fixed <- lme4::fixef(fit)
    ret$vcov <- as.matrix(vcov(fit))
    # ret$df <- Matrix:::getFixDF(fit)
    ret$df <- rep( Inf, length(ret$fixed))
    ret
}

getFix.zeroinfl <- function(fit,...){
    ret <- list()
    ret$fixed <- coef(fit)
    ret$vcov <- as.matrix(vcov(fit))
    # ret$df <- Matrix:::getFixDF(fit)
    ret$df <- rep( Inf, length(ret$fixed))
    ret
}

getFix.mipo <- function( fit, ...){
    # pooled multiple imputation object in mice
    # uses the minimal df for components with non-zero weights
    # -- this is probably too conservative and should
    # improved
    ret <- list()
    ret$fixed <- fit$qbar
    ret$vcov <- fit$t
    ret$df <- fit$df
    ret
}

getFix.MCMCglmm <- function(fit,...) {
    ret <- list()
    ret$fixed <- apply(fit$Sol, 2, mean)
    ret$vcov <- var( fit $ Sol)
    ret$df <- rep(Inf, length(ret$fixed))
    ret
}

getFix.stanfit <- function(fit, pars, include = TRUE, ...) {
        if(missing(pars)) pars <- dimnames(fit)$parameter
        sam <- as.matrix(fit, pars = pars , include = include)
        ret <- list()
        ret$fixed <- apply(sam, 2, mean)
        ret$vcov <- var(sam)
        ret$df <- rep(Inf, length(ret$fixed))
        ret
    }

getFix.default <- function(fit, ...) stop(paste("Write a 'getFix' method for class",class(fit)))


Vcov <- function(fit) {
    getFix(fit)$vcov
}


Vcor <- function(fit) {
    vc <- cov2cor(getFix(fit)$vcov)
    svds <- svd(vc)$d
    attr(vc,'conditionNumber') <- svds[1]/svds[length(svds)]
    vc
}


getData <- function(x,...) UseMethod("getData")

getData.lmer <- function(x,...) slot(x,'frame')

# the following 2 functions adapted from nlme

getData.lme <- function(x,...){
    mCall <- x$call
    data <- eval(if ("data" %in% names(x)) 
        x$data
        else mCall$data)
    if (is.null(data)) 
        return(data)
    naAct <- x[["na.action"]]
    if (!is.null(naAct)) {
        data <- if (inherits(naAct, "omit")) 
            data[-naAct, ]
        else if (inherits(naAct, "exclude")) 
            data
        else eval(mCall$na.action)(data)
    }
    subset <- mCall$subset
    if (!is.null(subset)) {
        subset <- eval(asOneSidedFormula(subset)[[2]], data)
        data <- data[subset, ]
    }
    data
}

getData.gls <- function(x,...){
    mCall <- x$call
    data <- eval(mCall$data)
    if (is.null(data)) 
        return(data)
    naPat <- eval(mCall$naPattern)
    if (!is.null(naPat)) {
        data <- data[eval(naPat[[2]], data), , drop = FALSE]
    }
    naAct <- eval(mCall$na.action)
    if (!is.null(naAct)) {
        data <- naAct(data)
    }
    subset <- mCall$subset
    if (!is.null(subset)) {
        subset <- eval(asOneSidedFormula(subset)[[2]], data)
        data <- data[subset, ]
    }
    data
} 

getData.lm <- function(x,...) model.frame(x,...)


getFactorNames <- function(object, ...) UseMethod("getFactorNames")

getFactorNames.data.frame <- function(object,...) {
    names(object)[ sapply(object, is.factor)  ]
}

getFactorNames.default <- function(object,...) getFactorNames( getData(object))



print.cat <- function(object,...) {
    cat(object)
    invisible(object)
}

Lmat <- function(fit, pattern, fixed = FALSE, invert = FALSE, debug = FALSE) {
    # pattern can be a character used as a regular expression in grep
    # or a list with each component generating  a row of the matrix
    umatch <- function( pat, x, fixed , invert ) {
        ret <- rep(0,length(pat))
        for ( ii in 1:length(pat)) {
            imatch <- grep(pat[ii], x, fixed= fixed, invert = invert)
            if ( length(imatch) != 1) {
                cat("\nBad match of:\n")
                print(pat)
                cat("in:\n")
                print(x)
                stop("Bad match")
            }
            ret[ii] <- imatch
        }
        ret
    }
    if ( is.character(fit)) {
        x <- pattern
        pattern <- fit
        fit <- x
    }
    fe <- getFix(fit)$fixed
    ne <- names(fe)
    if (is.character(pattern)) {
        L.indices <- grep(pattern,names(fe), fixed = fixed, invert = invert)
        ret <- diag( length(fe)) [L.indices,,drop = FALSE]
        if (debug) disp(ret)
        rownames(ret) <- names(fe) [L.indices]
        # 
        # GM 2019_02_21: remove dependency on labs function in spida2
        #
        #  labs(ret) <- "Coefficients"
    } else if (is.list(pattern)){
        ret <- matrix(0, nrow = length(pattern), ncol = length(fe))
        colnames(ret) <- ne
        for ( ii in 1:length(pattern)) {
            Lcoefs <- pattern[[ii]]
            pos <- umatch(names(Lcoefs), ne, fixed = fixed, invert = invert)
            if ( any( is.na(pos))) stop("Names of L coefs not matched in fixed effects")
            ret[ii, pos] <- Lcoefs
        }
        rownames(ret) <- names(pattern)
    }
    # 
    # GM 2019_02_21: remove dependency on labs function in spida2
    #
    #  labs(ret) <- "Coefficients"
    ret
}


getX <- function(fit, data = getData(fit)) {
    f <- formula(fit)
    if(length(f) == 3) f <- f[-2]
    ret <- model.matrix(f, data = data)
    # isnarow <- apply(as.data.frame(data), 1, function(x) any(is.na(x)))
    # if(any(isnarow)) {
    #   ret2 <- matrix(NA, nrow(data), ncol(ret))
    #   ret2[!isnarow,] <- ret
    #   ret <- ret2
    # }
    attr(ret,'data') <- data #include data as attribute
    ret
}

as.data.frame.wald <- function(x, row.names=NULL, optional, se = 2, digits = 3, sep = "", which = 1, ...) {
    # modified by GM 2010_09_20 to avoid problems with coefs with duplicate rownames
    dataf <- function(x, ...) {
        x <- cbind(x)
        rn <- rownames(x)
        if(length(unique(rn)) < length(rn)) rownames(x) <- NULL
        data.frame(x, ...)
    }
    x = x[which]
    ret <- if (length(x) == 1) { # e.g. is length(which) > 1
        cf <- x[[1]]$coef
        ret <- data.frame(coef = cf, se = x[[1]]$se)
        if(is.null(names(se))) names(se) <-
            sapply(se, function(x) as.character(round(x, digits)))
        SE <- x[[1]]$se
        SEmat <- cbind(SE) %*% rbind(se)
        cplus <- cf + SEmat
        cminus <- cf - SEmat
        colnames(cplus) <- paste("U",colnames(cplus),sep=sep)
        colnames(cminus) <- paste("L",colnames(cminus),sep=sep)
        ret <- cbind(ret, cplus, cminus)
        if(!is.null(dd <- x[[1]]$data)) ret <- cbind(ret, dd)
        if(!is.null(row.names)) row.names(ret) <- row.names
        ret
    }
    else lapply( x, as.data.frame.wald)
    ret
}

Lform <- function( fit, form, data = getData(fit)) {
    # 2011-12-01: replaced with version below
    # 2012 12 04
    # Plan for Lform
    #
    
    # 2012 12 05: Lform becomes Lex to acknowledge the fact that it uses
    # expressions instead of formulas
    if (missing(form)) return ( Lcall(fit))
    gg <- getFix(fit)
    Lsub <- do.call(cbind,eval( substitute( form ), data))
    if( (nrow(Lsub) != nrow( data))) {
        if ((nrow(Lsub)==1)) Lsub <- Lsub[rep(1,nrow(data)),]
        else stop('nrow(Lsub) != nrow(data)')
    }
    if( is.null( colnames(Lsub))) colnames(Lsub) <- rep('',ncol(Lsub))
    L <- matrix( 0, nrow = nrow(Lsub), ncol = length( gg$fixed))
    rownames(L) <- rownames(data)
    colnames(L) <- names( gg$fixed)
    Lpos <- Lsub[, colnames(Lsub) == '', drop = FALSE]
    # disp(Lpos)
    Lnamed <- Lsub[ , colnames(Lsub) !='', drop  = FALSE]
    # disp(Lnamed)
    for ( ip in seq_len( ncol( Lpos ))) L[,ip] <- Lpos[,ip]
    if ( ncol( Lnamed ) > 0 ) {
        if ( length( unknown <- setdiff( colnames(Lnamed) , colnames(L)))) {
            stop( paste("Unknown effect(s):" , unknown, collapse = " "))
        }
        for ( nn in colnames(Lnamed)) L[,nn] <- Lnamed[,nn]
    }
    attr(L,"data") <- data
    L
}

Lcall <- function( fit , factors = getFactorNames(fit), debug = F){ # not currently exported
    
    nams <- names(getFix(fit)$fixed)
    
    nams <- gsub( "^", ":", nams)   # delineate terms
    nams <- gsub( "$", ":", nams)   # delineate terms
    for ( ff in factors)   {
        ff.string <- paste( ff, "([^:]*)" , sep = '')
        if(debug) disp( ff.string)
        ff.rep <- paste(ff, " == \\'\\1\\'", sep = '')
        if(debug) disp(ff.rep)
        nams <- gsub( ff.string, ff.rep, nams)
    }
    # for ( ii in seq_along(matrix)) {
    #     mm.all   <- paste( "(:",names(matrix)[ii], "[^\\)]*\\))",sep='')
    #     mm.match <- paste( "(",names(matrix)[ii], "[^\\)]*\\))",matrix[ii], sep ='')
    #     mm.rep   <- paste( "\\1")
    #     which.null <- grepl( mm.all, nams) mm.null  <-
    #
    # }
    nams <- sub("(Intercept)", 1, nams)
    nams <- gsub( "^:","(",nams)
    nams <- gsub( ":$",")",nams)
    nams <- gsub( ":", ") * (", nams)
    #if(comment) nams <- paste( nams, "  #",nams)
    nams <- paste( "with (data, \n cbind(", paste( nams, collapse = ",\n"), ")\n)\n", collapse = "")
    class(nams) <- 'cat'
    nams
}

disp <- function (x, head = deparse(substitute(x))) 
{
    cat("::: ", head, " :::\n")
    print(x)
    cat("======================\n")
    invisible(x)
}
