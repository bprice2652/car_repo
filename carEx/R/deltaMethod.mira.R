# last modified 2018-09-03

deltaMethod.mira <- function(object, ...){
    coefs <- lapply(object$analyses, coef)
    if (any(is.na(unlist(coefs)))) stop("there are aliased coefficients in the model")
    D <- lapply(object$analyses, deltaMethod, ...)
    result <- D[[1]]
    D <- do.call(rbind, D)
    m <- nrow(D)
    if (m < 2) stop("fewer than 2 'multiple' imputations")
    df.res <- df.residual(object$analyses[[1]])
    estimate <- mean(D[, "Estimate"])
    Vb <- sum((D[, "Estimate"] - estimate)^2)/(m - 1)
    Vw <- mean(D[, "SE"]^2)
    V <- Vw + (1 + 1/m)*Vb
    r <- (1 + 1/m)*Vb/Vw
    df <- df.barnard.rubin(Vb, V, m, df.res)
    t <- qt(as.numeric(sub(" %", "", colnames(D)[4]))/100, df)
    SE <- sqrt(V)
    result[1, ] <- c(estimate, SE, estimate - t*SE, estimate + t*SE)
    result[c("Missing Info", "riv", "df", "Imputations")]  <- 
        c(round(r/(r + 1), 3), round(r, 3), round(df, 2), m)
    result[, c(1, 2, 7, 3, 4, 8, 5, 6)]
}
