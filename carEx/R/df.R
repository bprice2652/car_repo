# last modified 2018-09-03

df.barnard.rubin <- function(B, T, m, v.com=NULL){
    lambda <- function(v) (v + 1)/(v + 3)
    gamma <- (1 + 1/m)*B/T
    v <- (m - 1)/gamma^2
    if (is.null(v.com)) return(v)
    v.obs <- lambda(v.com)*v.com*(1 - gamma)
    1/(1/v + 1/v.obs)
}

df.reiter <- function(B, U, m, k, v.com){
    vs.com <- v.com*(v.com + 1)/(v.com + 3)
    t <- k*(m - 1)
    r <- (1 + 1/m)*tr(B %*% solve(U))/k
    a <- r*t/(t - 2)
    v.1 <- 1/(vs.com - 4*(1 + a))
    v.2 <- 1/(t - 4)
    v.3 <- (a^2)*(vs.com - 2*(1 + a))
    v.4 <- ((1 + a)^2)*(vs.com - 4*(1 + a))
    4 + 1/(v.1 + v.2*(v.3/v.4))
}