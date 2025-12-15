# last modified 2018-09-03

Anova.mira <- function(mod, type=c("II","III", 2, 3), ...){
    type <- as.character(type)
    type <- match.arg(type)
    models <- mod$analyses
    m <- length(models)
    if (m < 2) stop("fewer than 2 'multiple' imputations")
    # the following 2 lines are necessary because of scoping
    if (inherits(models[[1]], "merMod")) coef <- lme4::fixef
    if (inherits(models[[1]], "lme")) coef <- nlme::fixef
    vcovs <- lapply(models, vcov)
    coefs <- lapply(models, coef)
    if (any(is.na(unlist(coefs)))) stop("there are aliased coefficients in the model")
    mean.coefs <- rowMeans(do.call(cbind, coefs))
    vcov.w <- vcovs[[1]]
    vcov.b <- outer(d <- coefs[[1]] - mean.coefs, d)
    for (i in 2:m){
        vcov.w <- vcov.w + vcovs[[i]]
        vcov.b <- vcov.b + outer(d <- coefs[[i]] - mean.coefs, d)
    }
    vcov.w <- vcov.w/m
    vcov.b <- vcov.b/(m - 1)
    vcov.t <- vcov.w + (m + 1)*vcov.b/m
    switch(type,
           II=Anova.II.mira(mod, vcov.t, ...),
           III=Anova.III.mira(mod,  ...),
           "2"=Anova.II.mira(mod, vcov.t, ...),
           "3"=Anova.III.mira(mod, ...))
}

Anova.II.mira <- function(models, vcov., ...){
    hyp.term <- function(term){
        which.term <- which(term==names)
        subs.term <- if (is.list(assign)) assign[[which.term]] else which(assign == which.term)
        relatives <- relatives(term, names, fac)
        subs.relatives <- NULL
        for (relative in relatives){
            sr <- if (is.list(assign)) assign[[relative]] else which(assign == relative)
            subs.relatives <- c(subs.relatives, sr)
        }
        hyp.matrix.1 <- I.p[subs.relatives, , drop=FALSE]
        hyp.matrix.1 <- hyp.matrix.1[, , drop=FALSE]
        hyp.matrix.2 <- I.p[c(subs.relatives,subs.term),,drop=FALSE]
        hyp.matrix.2 <- hyp.matrix.2[, , drop=FALSE]       
        hyp.matrix.term <- if (nrow(hyp.matrix.1) == 0) hyp.matrix.2
        else t(ConjComp(t(hyp.matrix.1), t(hyp.matrix.2), vcov.))            
        hyp.matrix.term <- hyp.matrix.term[!apply(hyp.matrix.term, 1, 
                                                  function(x) all(x == 0)), , drop=FALSE]
        if (nrow(hyp.matrix.term) == 0){
            result <- list(F=NA, "num df"=0, "den df"=NA, "Pr(>F)"=NA)
            attr(result, "r") <- NA
        }
        else result <- linearHypothesis(models, hyp.matrix.term, ...)
        result
    }
    mod <- models$analyses[[1]]
    fac <- attr(terms(mod), "factors")
    intercept <- has.intercept(mod)
    p <- length(coef(mod))
    I.p <- diag(p)
    assign <- assignVector(mod) 
    if (is.list(assign) && intercept) assign <- assign[-1]
    names <- term.names(mod)
    if (intercept) names <- names[-1]
    n.terms <- length(names)
    df <- c(rep(0, n.terms), df.residual(mod))
    if (inherits(mod, "coxph")){
        assign <- assign[assign != 0]
        clusters <- grep("^cluster\\(", names)
        if (length(clusters) > 0) {
            names <- names[-clusters]
            df <- df[-clusters]
            n.terms <- n.terms - length(clusters)
        }
    }
    table <- matrix(0, n.terms, 6)
    rownames(table) <- names
    colnames(table) <- c("F", "num df", "den df", "missing info", "riv", "Pr(>F)")
    for (i in 1:n.terms){
        hyp <- hyp.term(names[i])
        r <- attr(hyp, "r")
        table[i, ] <- unlist(c(hyp[1:3], r/(r + 1), r, hyp[4]))
    }
    class(table) <- c("anova")
    attr(table, "heading") <- c("Analysis of Deviance Table (Type II tests)\n", 
                                paste("Response:", responseName(mod)),
                                paste("Based on", length(models$analyses), "multiple imputations\n"))
    table
}

Anova.III.mira <- function(models, ...){
    mod <- models$analyses[[1]]
    intercept <- has.intercept(mod)
    p <- length(coef(mod))
    I.p <- diag(p)
    names <- term.names(mod)
    n.terms <- length(names)
    assign <- assignVector(mod) # attr(model.matrix(mod), "assign")
    if (inherits(mod, "coxph")){
        if (intercept) names <- names[-1]
        assign <- assign[assign != 0]
        clusters <- grep("^cluster\\(", names)
        if (length(clusters) > 0) {
            names <- names[-clusters]
            n.terms <- n.terms - length(clusters)
        }
    }
    table <- matrix(0, n.terms, 6)
    rownames(table) <- names
    colnames(table) <- c("F", "num df", "den df", "missing info", "riv", "Pr(>F)")
    for (term in 1:n.terms){
        subs <- if (is.list(assign)) assign[[term]] else which(assign == term - intercept)    
        hyp.matrix <- I.p[subs,,drop=FALSE]
        hyp.matrix <- hyp.matrix[, , drop=FALSE]
        hyp.matrix <- hyp.matrix[!apply(hyp.matrix, 1, function(x) all(x == 0)), , drop=FALSE]        
        if (nrow(hyp.matrix) == 0){
            table[term, ] <- c(NA, 0, NA, NA, NA)
        }
        else {
            hyp <- linearHypothesis(models, hyp.matrix,  ...)
            r <- attr(hyp, "r")
            table[term, ] <- unlist(c(hyp[1:3], r/(r + 1), r, hyp[4]))
        }
    }
    class(table) <- c("anova")
    attr(table, "heading") <- c("Analysis of Deviance Table (Type III tests)\n", 
                                paste("Response:", responseName(mod)),
                                paste("Based on", length(models$analyses), "multiple imputations\n"))
    table
}

