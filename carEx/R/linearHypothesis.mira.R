# last modified 2018-09-01

tr <- function(X) sum(diag(X))

linearHypothesis.mira <- function(model, hypothesis.matrix, rhs=NULL, ...){
    models <- model$analyses
    m <- length(models)
    if (m < 2) stop("fewer than 2 'multiple' imputations")
    vcovs <- lapply(models, vcov)
    # the following 2 lines are necessary because of scoping
    if (inherits(models[[1]], "merMod")) coef <- lme4::fixef
    if (inherits(models[[1]], "lme")) coef <- nlme::fixef
    coefs <- lapply(models, coef)
    if (any(is.na(unlist(coefs)))) stop("there are aliased coefficients in the model")
    df.res <- df.residual(models[[1]])
    beta.1 <- rowMeans(do.call(cbind, coefs))
    if (is.character(hypothesis.matrix)) {
        L <- makeHypothesis(names(beta.1), hypothesis.matrix, rhs)
        if (is.null(dim(L))) L <- t(L)
        rhs <- L[, NCOL(L)]
        L <- L[, -NCOL(L), drop = FALSE]
        rownames(L) <- hypothesis.matrix
    }
    else {
        L <- if (is.null(dim(hypothesis.matrix))) t(hypothesis.matrix)
        else hypothesis.matrix
        if (is.null(rhs)) rhs <- rep(0, nrow(L))
    }
    values.hyp.diff <- values.hyp <- vcovs.hyp <- vector(m, mode="list")
    for (i in 1:m){
        values.hyp[[i]] <- as.vector(L %*% coefs[[i]] - rhs)
        values.hyp.diff[[i]] <- as.vector(L %*% (coefs[[i]] - beta.1) - rhs)
        vcovs.hyp[[i]] <- L %*% vcovs[[i]] %*% t(L)
    }
    s <- nrow(L)
    vcov.w <- vcovs.hyp[[1]]
    vcov.b <- outer(values.hyp.diff[[1]], values.hyp.diff[[1]])
    for (i in 2:m){
        vcov.w <- vcov.w + vcovs.hyp[[i]]
        vcov.b <- vcov.b + outer(values.hyp.diff[[i]], values.hyp.diff[[i]])
    }
    vcov.w <- vcov.w/m
    vcov.b <- vcov.b/(m - 1)
    r <- ((m + 1)/m)*tr(vcov.b %*% solve(vcov.w))/s
    value.hyp <- L %*% beta.1 - rhs
    f <- (t(value.hyp) %*% solve(vcov.w) %*% value.hyp)/(s*(1 + r))
    df.d <- if (is.null(df.res)){
        t <- s*(m - 1)
        if (t > 4){
            4 + (t - 4)*(1 + (1 - 2/t)/r)^2
        } else {
            0.5*t*(1 + 1/s)*(1 + 1/r)^2
        }
    } else {
        df.reiter(vcov.b, vcov.w, m, s, df.res)
    }
    pval <- pf(f, s, df.d, lower.tail=FALSE)
    title <- "Linear hypothesis test\n\nHypothesis:"
    topnote <- paste("Based on", m, "multiple imputations")
    note <- paste0("Estimated rate of missing information = ", round(r/(r + 1), 3), "\n",
                   "Relative increase in variance due to nonresponse = ", round(r, 3), "\n")
    rval <- matrix(c(f, s, df.d, pval), nrow = 1)
    colnames(rval) <- c("F", "num df", "den df", "Pr(>F)")
    rownames(rval) <- "Hypothesis"
    result <- structure(as.data.frame(rval),
                        heading = c(title, printHypothesis(L, rhs, names(beta.1)), "", topnote, note),
                        class = c("anova", "data.frame"))
    attr(result, "value") <- value.hyp
    attr(result, "vcov") <- vcov.w
    attr(result, "r") <- r
    result
}
