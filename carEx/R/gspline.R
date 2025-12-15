# moved here 2019-05-23 by J. Fox

##
##  TODO: use new.env(parent=emptyenv())
## Use ::: to use hidden functions
## Delete function in gspline
##
## General parametric polynomial splines: March 10, 2019
##  
##  Note that Cmat, Xf, Dmat, Xmat, basis, Pcon 
##  are unexported functions that are used in the
##  vignette explaining the principles behind
##  gspline. 
##   
##  They are also used within gspline and Xf and Xmat
##  are also explictitly added to the environment 
##  of the spline function created by gspline,
##
##

gspline <- function(
    knots, 
    degree = 3,
    smoothness = pmax(
        pmin(degree[-1],degree[-length(degree)]) - 1, 0),
    intercept = 0,
    constraints = NULL,
    estimates = NULL,
    periodic = FALSE,
    tolerance = 1e-14
){
    
    basis  <- function(X, tol = 1e-9) {
        # returns linear independent columns
        # with possible pivoting
        q <- qr(X, tol = tol)
        sel <- q$pivot[seq_len(q$rank)]
        ret <- X[, sel, drop = FALSE]
        colnames(ret) <- colnames(X)[sel]
        ret
    }
    
    Cmat <- function( knots, degree, smoothness, lin = NULL, intercept = 0, signif = 3) {
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
                    rownames( dmat ) <- paste0("C", sm, '|', signif(k, signif))
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
    
    Emat <- function(knots, degree, smoothness , intercept = FALSE, signif = 3) {
        if (length(degree) < length(knots) + 1) degree <- rep( degree,
                                                               length.out =  length(knots) + 1)
        dmin <- min(degree)
        dmax <- max(degree)
        imax = length(degree)
        # derivatives for changes to estimate
        
        # Quick temporary fix if smoothness is a list 
        # - generate extra terms that will be dropped due to collinearity with constraints
        if(is.list(smoothness)) smoothness <- rep(-1, length(knots))
        
        zeroi = as.numeric(cut( 0, c(-Inf, sort(knots), Inf))) # index of interval containing 0
        dzero = degree[zeroi] # degree of interval containing 0
        
        cmat = Xf(0, knots, degree = dmax, D = seq( 1, dzero)) # derivatives at 0 - may be discarded
        
        if ( imax > zeroi ){  # intervals to the right of the interval containing 0
            for ( i in (zeroi+1): imax) {
                d.right = degree[ i ]
                d.left  = degree[ i-1 ]
                k = knots[ i - 1 ]
                sm = smoothness[ i - 1 ]
                if (  d.right > sm ) {
                    dmat  =Xf( k , knots, dmax, D = seq(sm+1,d.right) , F ) -
                        Xf( k , knots, dmax, D = seq(sm+1,d.right) , T )
                    # rownames( dmat ) = paste( "C", seq(sm+1,d.right) ,  ,signif(k, signif),").",
                    #                           , sep = '')
                    rownames( dmat ) = paste0( "C", seq(sm+1, d.right),'|', signif(k, signif))
                    cmat = rbind( cmat,  dmat)
                    
                }
            }
        }
        
        if ( zeroi > 1 ){
            for ( i in zeroi: 2) {
                d.right = degree[ i ]
                d.left  = degree[ i-1 ]
                k = knots[ i - 1 ]
                sm = smoothness[ i - 1 ]
                if (  d.left > sm ) {
                    dmat = Xf( k , knots, dmax, D = seq(sm+1,d.left) , F ) -
                        Xf( k , knots, dmax, D = seq(sm+1,d.left) , T )
                    rownames( dmat ) = paste0( "C", seq(sm+1, d.left),'|', signif(k, signif))
                    
                    cmat = rbind( cmat,  dmat)
                    
                }
            }
        }
        cmat
    }
    Xmat <-	function(x,
                     degree,
                     D = 0,
                     signif = 3) {
        # Returns rows of design matrix if D = 0
        # or linear hypothesis matrix for D-th derivative
        if (length(D) < length(x))
            D = rep(D, length.out = length(x))
        if (length(x) < length(D))
            x = rep(x, length.out = length(D))
        xmat = matrix(x, nrow = length(x), ncol = degree + 1)
        expvec <- 0:degree
        coeffvec <- rep(1, degree + 1)
        expmat <- NULL
        coeffmat <- NULL
        
        for (i in 0:max(D)) {
            expmat <- rbind(expmat, expvec)
            coeffmat <- rbind(coeffmat, coeffvec)
            coeffvec <- coeffvec * expvec
            expvec <- ifelse(expvec > 0, expvec - 1, 0)
        }
        X = coeffmat[D + 1,,drop = FALSE] * xmat ^ expmat[D + 1,, drop = FALSE]
        
        xlab = signif(x, signif)
        rownames(X) = ifelse(D == 0,
                             paste('f(', xlab , ')', sep = ''),
                             paste0("D", D, "|", xlab))                         # new style
        colnames(X) = paste("X", 0:(ncol(X) - 1), sep = "")
        class(X) <- c('gspline_matrix',class(X))
        X
    }
    Xf <- function(x,
                 knots,
                 degree = 3,
                 D = 0,
                 right = TRUE,
                 periodic = FALSE,
                 signif = 3) {
            # Returns block diagonal matrix (if x ordered)
            # with design matrix or linear hypothesis matrix
            # for the 'full' model with contrained parameters.
            #
            # With the default, right == TRUE,
            # if x is at a knot then it is included in
            # in the lower interval.
            # With right = FALSE, it is included in the higher
            # interval. This is needed when building
            # derivative constraints at the knot
            if(periodic) {
                period <- max(knots)
                xx <- x %% period
                if(right) xx[xx==0] <- period
                x <- xx
                knots <- knots[-length(knots)]
            }
            xmat = Xmat (x, degree, D , signif)
            k = sort(knots)
            g = cut(x, c(-Inf, k, Inf), right = right)
            ret <- do.call('cbind',
                           lapply(seq_along(levels(g)), function(i)
                               (g == levels(g)[i]) *  xmat))
            if(periodic) rownames(ret) <- paste0(rownames(ret), '/',signif(period, signif)) # new style
            class(ret) <- c('gspline_matrix',class(ret))
            
            ret
        }
    
    #
    # Value and derivatives at 0
    #
    # And all discontinuities at knots
    #
    Dmat <- function(knots, degree, periodic = FALSE, signif = 3) {
        dm <- max(degree)
        cmat <- Xf(0, knots, dm, D=0:dm, periodic = periodic)
        n_knots <- length(knots)
        for (i in seq_len(n_knots - 1) ) {
            k <- knots[i]
            dmat <- Xf(k, knots, dm, D = seq(0,dm), F, periodic = periodic) -
                Xf(k, knots, dm, D = seq(0,dm), T, periodic = periodic)
            # rownames( dmat ) <- paste( "C(",signif(k, signif),").",
            #                            seq(0,dm), sep = '')
            rownames( dmat ) <- paste0( "C",seq(0,dm),'|',signif(k, signif))  # new style for derivatives
            if(periodic) rownames(dmat) <- paste0(rownames(dmat),'/',signif(max(k),signif))
            cmat <- rbind( cmat,  dmat)
        }
        k <- knots[length(knots)]
        if(periodic) {
            dmat <- Xf(0, knots, dm, D = seq(0,dm), F, periodic = periodic) -
                Xf(k, knots, dm, D = seq(0,dm), T, periodic = periodic)
            # rownames( dmat ) <- paste( "C(0 mod ",signif(k, signif),").",
            #                            seq(0,dm), sep = '')
            rownames( dmat ) <- paste( "C", seq(0,dm),'|', signif(k, signif),'/',signif(max(k), signif))  # new style for derivatives
            cmat <- rbind(cmat, dmat)
        } else {
            dmat <- Xf(k, knots, dm, D = seq(0,dm) , F ,periodic = periodic) -
                Xf(k, knots, dm, D = seq(0,dm) , T ,periodic = periodic)
            # rownames( dmat ) <- paste( "C(",signif(k, signif),").",
            #                            seq(0,dm), sep = '')     
            rownames( dmat ) <- paste0( "C",seq(0,dm),'|',signif(k, signif))  # new style for derivatives
            cmat <- rbind(cmat, dmat)
        }
        class(cmat) <- c('gspline_matrix',class(cmat))
        
        cmat
    }
    
    #
    # Parameters to constrain
    #
    # TODO: Change so degree can be a list
    #
    Pcon <- function(knots, degree, periodic) {
        degree <- rep( degree, length.out = length(knots) + 1)
        if(periodic) {
            if(degree[length(degree)] != degree[1]) warning("For periodic splines, the degree of the last and first intervals should match")
            knots <- knots[-length(knots)]
            degree <- degree[-length(degree)]
        }
        dm <- max(degree)
        cmat <- NULL
        for ( i in seq_along(degree)) {
            di <- degree[i]
            if ( dm > di ) {
                dmat <- diag( (length(knots) + 1) * (dm +1)) [
                    (i - 1)*(dm + 1) + 1 + seq( di+1,dm), , drop = F]
                rownames( dmat ) = paste( "I.", i,".",seq(di+1,dm),sep = '')
                cmat = rbind( cmat, dmat)
            }
        }
        if(!is.null(cmat)) class(cmat) <- c('gspline_matrix',class(cmat))
        cmat
    }
    
    #
    # Parse knots, degree and smoothness to create 
    # constraint and estimation matrices:
    # - Identify rows of Dmat that are used for contraints
    #   and rows used for estimates
    
    
    if(periodic) {
        if(min(knots) <= 0) stop('For a periodic spline all knots must be positive')
    }
    if(any(knots != sort(knots))) stop('Knots must be in ascending order') 
    degree <- rep(degree, length.out = length(knots) + 1)
    max_degree <- max(degree)
    smoothness <- rep(smoothness, length.out = length(knots))
    if(!is.list(smoothness)) smoothness <- 
        lapply(smoothness, function(n) if(n<0) -1 else 0:n)
    Dmat_smoothness_indices <-
        unlist(
            lapply(seq_along(smoothness), function(i)
                smoothness[[i]] + (max_degree + 1) * i + 1)
        )
    Dmat_smoothness_indices <- Dmat_smoothness_indices[unlist(smoothness) > -1] 
    
    # Build constraints
    constraint_mat <- Dmat(knots, degree, periodic = periodic)[Dmat_smoothness_indices, ,drop = F] 
    constraint_mat <- rbind(constraint_mat, Pcon(knots, degree, periodic = periodic))
    if(!is.null(constraints)) 
        constraint_mat <- rbind(constraint_mat, constraints)
    if(!is.null(intercept)) {
        constraint_mat <- 
            rbind(constraint_mat, Xf(intercept, knots, max_degree, periodic = periodic))
        Dmat_smoothness_indices <- c(1,Dmat_smoothness_indices)
    }
    cmat <- t(basis(t(constraint_mat)))
    
    estimate_mat <- 
        rbind(estimates,
              Dmat(knots, degree, periodic = periodic)[-Dmat_smoothness_indices, ,drop = FALSE])
    # the following is necessary in case some of the derivatives
    # estimated at 0 have been coerced to 0 by other constraints
    estimate_mat <- t(basis(t(rbind(constraint_mat, estimate_mat))))
    estimate_mat <- estimate_mat[-seq_len(nrow(constraint_mat)),,drop = FALSE]
    
    emat <- estimate_mat
    
    A <- rbind(constraint_mat, estimate_mat)
#    if(debug) svs <- svd(A,nu=0,nv=0)
    G <- solve( rbind(constraint_mat, estimate_mat), 
                diag(ncol(constraint_mat))[,-seq_len(nrow(constraint_mat)), drop = FALSE])
    colnames(G) <- rownames(estimate_mat)
    # 
    # create closure
    #
    fun <- function(x, D = NULL, limit = 1) {
        if(is.null(D)) {
            ret <- Xf(x, knots, max_degree, periodic = periodic) %*% G # model matrix
        } else {
            # Hypothesis matrix
            D <- rep(D, length.out = length(x))
            limit <- rep(limit, length.out = length(x))
            left <- Xf(x, 
                       knots = knots, 
                       degree = max_degree, 
                       D = D,
                       periodic = periodic,
                       right = TRUE)
            right <- Xf(x, 
                        knots = knots, 
                        degree = max_degree, 
                        D = D, 
                        periodic = periodic,
                        right = FALSE)
            cleft <- c(1,0,-1)[ match(limit, c(-1,1,0)) ]
            cright <- c(0,1,1)[ match(limit, c(-1,1,0)) ]
            # disp((right - left) %*% G)
            continuous <- apply((right - left) %*% G, 1, function(x) all(abs(x) < 10 * tolerance))
            # disp(continuous)
            raw <- left * cleft + right * cright
            ret <- raw %*% G
            nam <- rownames(ret)
            nam <- sub("^f","g", nam)
            # nam_left <- sub("\\)","-)", nam)
            # nam_right <- sub("\\)","+)", nam)
            nam_left <- sub("(/|$)","-\\1", nam)     # new style
            nam_right <- sub("(/|$)","+\\1", nam)    # new style
            nam_jump <- paste0(nam_right ,"-", nam_left)
            # 
            # If we're testing for a jump and the derivative is 
            # continuous we should show the identity of the 
            # jump tested.
            # 
            # If we're testing for a derivative at a knot
            # and the derivative is continuous, we should
            # indicate that by removing the direction indicator
            #
            # So:
            # If we're testing a jump we use the full name of 
            # the linear combination even if it happens to be 
            # at a point of continuity
            # Otherwise, used the directional notation only
            # if the tested derivative is discontinuous
            rownames(ret) <-
                ifelse(limit == 0,
                       nam_jump,
                       ifelse(continuous, nam,
                              ifelse(limit == 1, nam_right, nam_left)))
        }
        class(ret) <- c('gspline_matrix', class(ret))
        
        # # begin PROOF OF CONCEPT
        # 
        # nc <- ncol(ret)
        # attr(ret, "transformation") <- if (stabilize){
        #     tmat <- diag(nc)
        #     nut <- nc*(nc - 1)/2
        #     tmat[upper.tri(tmat)] <- (1:nut)/nut
        #     ret <- ret %*% tmat
        #     tmat
        # }
        # else diag(nc)
        #
        # # transformation recoverable from model.frame()
        # 
        # # end PROOF OF CONCEPT
        
        ret
    }
    
    # Modify colnames of G matrix to show direction of limit
    # if there is a discontinuity of derivatives at origin
    
    if(!is.null(intercept)) {
        dest <- fun(rep(intercept,max(degree)+1), D = 0:max(degree), limit = -1)
        
        tos <- grep('-$|-/',rownames(dest), value = TRUE)
        
        froms <- sub('([0-9])-','\\1', tos)
        froms <- sub('(.*)','^\\1$', froms)
        froms <- sub('\\|','\\\\|', froms)
        
        for(i in seq_along(tos)) {
            colnames(G) <- sub(froms[i], tos[i], colnames(G))
        }
        
    }
    class(fun) <- c('gspline', class(fun))
    fun
}

print.gspline <- function(x, show = c('knots','degree','smoothness','G','constraint_mat','estimate_mat'), ...) {
    cat('Spline function created by gspline\n')
    ret <- (Filter(Negate(is.function),  sapply(ls(environment(x)), get, environment(x))))
    ret <- lapply(ret, function(x) if(is.numeric(x)) zapsmall(x) else x)
    if(!is.null(show)) ret <- ret[show]
    print(ret)
    invisible(ret)
}

print.gspline_matrix <- function(x, ...) {
    x <- zapsmall(x)
    class(x) <- "matrix"
    print(x)
}

knots.gspline <- function(Fn, ...) {
    environment(Fn)$knots
}

# if(FALSE) {
# # testing code
#     sp <- gspline(c(-1,0,1),3,2)
#     sp(c(-1,0,2,3))
#     sp(c(-1,-1,-1,0,2,3),2,limit=c(-1,0,1,0,0,0))
#     print(sp)
#     sp <- gspline(c(-2,0,2),3,1)
#     sp(seq(-1,2))
#     sp(seq(-1,2),1)
#     sp(c(0,0,0,0),c(0,1,2,3))
#     sp(c(0,0,0,0),c(0,1,2,3), limit = -1)
#     
#     # test periodic splines
#     zd <- data.frame(x=-10:10)
#     zd <- within(zd, y <- x + abs(x) + .01*rnorm(x))
#     sp0 <- gspline(0,1,0)
#     fit <- lm(y ~ sp0(x), zd)
#     summary(fit)
#     print(sp)
#     
#     # problem?: parameters estimate from left, not right
#     
#     zd <- within(zd, yd <- x + abs(x) + I(x > 0) + .01 * rnorm(x))
#     spd <- gspline(0,1, -1)
#     fit <- lm(yd ~ spd(x), zd)
#     summary(fit)
#     spd(c(0,0,0,0,0,0), D=c(0,0,0,1,1,1), limit = c(-1,0,1,-1,0,1)) %>%
#         {Lmat <- .}
#     wald(fit, cbind(0,Lmat))
#     plot(yd ~ x, zd)
#     print(sp)
#     
#     # both level and slope are limits from the left: 
#     # probably should leave that way because it's easier
#     # to add change than to go back
#     
#     # TODO: need to add limit directions on G matrix
#     
#     load("../data/Unemp.RData", verbose = T)
#     plot(unemployment ~ date, data=Unemp, type="b")   
#     dim(Unemp)
#     dd <- Unemp
#     dd$y <- dd$unemployment
#     dd$x <- 1:nrow(dd)
#     f1 <- function(x) cbind(Sin=sin(2*pi*x/12),Cos=cos(2*pi*x/12))  # fundamental
#     f2 <- function(x) structure(f1(x/2), names = c('Sin2','Cos2'))
#     f3 <- function(x) structure(f1(x/3), names = c('Sin3','Cos3'))
#     f4 <- function(x) structure(f1(x/4), names = c('Sin4','Cos4'))
#     per <- gspline(c(3,6,9,12),c(1,2,2,2,1),0, periodic = TRUE)
#     per2 <- gspline(c(3,6,9,12),2,1, periodic = TRUE)
#     per3 <- gspline(c(3,6,9,12),3,2, periodic = TRUE)
#     per4 <- gspline(c(3,6,9,12),4,3, periodic = TRUE)
#     perstep <- gspline(c(3,6,9,12),0,-1, periodic = TRUE)
#     
#     per
#     fits <- list(
#         hetero = lm(y ~ per(x), dd),
#         quad = lm(y ~ per2(x), dd),
#         cubic =  lm(y ~ per3(x), dd),
#         quartic = lm(y ~ per4(x), dd),
#         step = lm(y ~ perstep(x), dd),
#         f1 = lm(y ~ f1(x), dd),
#         f2 = lm(y ~ f1(x) + f2(x), dd),
#         f3 = lm(y ~ f1(x) + f2(x) + f3(x), dd),
#         f4 = lm(y ~ f1(x) + f2(x) + f3(x) + f4(x), dd)
#     )
#     fits %>% lapply(summary)
#     fits %>% sapply(AIC)
#     pred <- list(x=seq(0,24,.01))
#     plot(c(0,24),c(6.5,8.5), type = 'n')
#     fits %>% lapply(function(f) lines(pred$x,predict(f, newdata = pred)))
#     sp <- gspline(nrow(dd)*1:7/8,2,1)
#     sp3 <- gspline(nrow(dd)*1:7/8,3,2)
#     fit <- lm(y ~ per3(x) +sp(x), dd)
#     fit3 <- lm(y ~ per3(x) +sp3(x), dd)
#     fit4 <- lm(y ~ per3(x) +sp3(x), dd)
#     with(dd, {
#         plot(date,y, pch = '.',cex = 2)
#         lines(date, predict(fit))
#         lines(date, predict(fit3), col = 'red')
#     }
#     )
#     pred <- data.frame(x=seq(1,24,.01))
#     with(pred, {
#         plot(c(1,24), c(9,11), xlab = 'month', ylab = 'unemployment', type = 'n')
#         lines(x, predict(fit, newdata = pred))
#     })
#     AIC(fit,fit3)
#     library(effects)
#     allEffects(fit)
#     dd$month <- dd$x %% 12
#     fit <- lm(y ~ sp3(x) + per3(month), dd)
#     summary(fit)
#     plot(allEffects(fit))
#     #
#     # Test names
#     #
#     sp <- gspline(c(0,1,2,3), 2, c(-1,0,1,2))
#     sp(0:4)  
#     knots(sp)
#     (evs <- expand.grid(k=knots(sp), D = 1:3))
#     with(evs, sp(k,D,limit = 0))
#     evs$salt <- apply(with(evs, abs(sp(k, D, limit = 0))), 1, sum) > 1e-14 
#     evs
#     dd <- expand.grid(x = seq(-1, 4, .1))
#     dd <- within(dd, y <- x^2 + .1* rnorm(x) + (x > 0))
#     library(latticeExtra)
#     library(spida2)
#     library(gnew)
#     xyplot(y ~ x , dd)  
#     fit <- lm(y ~ sp(x),dd)
#     dd$fit <- predict(fit)
#     trellis.focus()
#     panel.xyplot(dd$x, dd$fit, type = 'l')
#     trellis.unfocus()
#     summ(fit)
#     evs <- expand.grid(limit = -1:1, x=-1:4, D = 0:2)
#     with(evs, sp(x,D,limit))
#     evs$intercept <- with(evs, 1*(D==0))
#     Lmat <- with(evs, cbind(intercept, sp(x,D, limit)))
#     knots(sp)
#     rownames(Lmat) <- with(evs, paste(x,D,limit))
#     wald(fit, Lmat)
# }