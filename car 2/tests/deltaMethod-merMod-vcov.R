## =====================================================================
## Regression test: deltaMethod() honours vcov. for lme4 fits
##
## The Rd: for every method other than the default, vcov. "must either
## provide the estimated covariance matrix or a function that when applied
## to object returns a covariance matrix."
##
## The bug: deltaMethod.merMod() forwarded vcov.=vcov, the stats generic,
## instead of the caller's vcov., so a user-supplied covariance matrix (for
## example a cluster-robust one) was silently replaced by vcov(object). With
## vcov. = 4 * vcov(fit) the SE of the Days slope in sleepstudy stayed at
## 1.546 instead of doubling to 3.092. lm, glm and lme fits were not affected.
##
## Identity: the delta-method SE of a single coefficient is the square root of
## its diagonal entry in the supplied vcov., so scaling vcov. by 4 doubles it.
## =====================================================================

if (requireNamespace("lme4", quietly = TRUE)) {
  library(car)
  close <- function(a, b) isTRUE(all.equal(unname(a), unname(b), tolerance = 1e-8))

  m <- lme4::lmer(Reaction ~ Days + (Days | Subject), lme4::sleepstudy)
  V4 <- 4 * as.matrix(vcov(m))
  stopifnot("deltaMethod(lmer): a supplied vcov. matrix is ignored" =
              close(deltaMethod(m, "Days", vcov. = V4)$SE, sqrt(V4[2, 2])))
  stopifnot("deltaMethod(lmer): a supplied vcov. function is ignored" =
              close(deltaMethod(m, "Days", vcov. = function(x) V4)$SE, sqrt(V4[2, 2])))
  stopifnot("deltaMethod(lmer): the default vcov. changed" =
              close(deltaMethod(m, "Days")$SE, sqrt(vcov(m)[2, 2])))

  g <- lme4::glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
                   lme4::cbpp, binomial)
  G4 <- 4 * as.matrix(vcov(g))
  stopifnot("deltaMethod(glmer): a supplied vcov. matrix is ignored" =
              close(deltaMethod(g, "period2", vcov. = G4)$SE, sqrt(G4[2, 2])))
}
