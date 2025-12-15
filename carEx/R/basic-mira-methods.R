# created 2018-09-01

coef.mira <- function(object, ...){
    models <- object$analyses
    # the following 2 lines are necessary because of scoping
    if (inherits(models[[1]], "merMod")) coef <- lme4::fixef
    if (inherits(models[[1]], "lme")) coef <- nlme::fixef
    coefs <- sapply(models, coef)
    rowMeans(coefs)
}

vcov.mira <- function(object, ...){
    models <- object$analyses
    m <- length(models)
    if (m < 2) stop("fewer than 2 'multiple' imputations")
    # the following 2 lines are necessary because of scoping
    if (inherits(models[[1]], "merMod")) coef <- lme4::fixef
    if (inherits(models[[1]], "lme")) coef <- nlme::fixef
    vcovs <- lapply(models, vcov)
    coefs <- sapply(models, coef)
    b <- rowMeans(coefs)
    vcov.w <- vcovs[[1]]
    vcov.b <- outer(coefs[, 1] - b, coefs[, 1] - b)
    for (i in 2:m){
        vcov.w <- vcov.w + vcovs[[i]]
        vcov.b <- vcov.b + outer(coefs[, i] - b, coefs[, i] - b)
    }
    vcov.w <- vcov.w/m
    vcov.b <- vcov.b/(m - 1)
    as.matrix(vcov.w + (1 + 1/m)*vcov.b)
}