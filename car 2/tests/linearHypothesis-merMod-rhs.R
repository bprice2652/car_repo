## =====================================================================
## Regression test: linearHypothesis() honours rhs for lme4 fits
##
## The Rd: rhs is the "right-hand-side vector for hypothesis ... This argument
## isn't available for F-tests for linear mixed models", so the default
## Wald chi-square test of a merMod fit should use it.
##
## The bug: linearHypothesis.merMod() did not forward rhs to
## linearHypothesis.mer(), so rhs was silently replaced by 0. For
## lmer(Reaction ~ Days + (Days | Subject), sleepstudy),
## linearHypothesis(m, "Days", rhs = 10) returned Chisq 45.85 (the test of
## Days = 0) instead of 0.091; the equivalent string "Days = 10" was right.
## The documented warning for rhs with test = "F" could never fire.
##
## Identity: the Wald statistic for one coefficient is (b - r)^2 / V, and the
## rhs argument must agree with writing the same hypothesis as a string.
## =====================================================================

if (requireNamespace("lme4", quietly = TRUE)) {
  library(car)
  close <- function(a, b) isTRUE(all.equal(unname(a), unname(b), tolerance = 1e-8))

  m <- lme4::lmer(Reaction ~ Days + (Days | Subject), lme4::sleepstudy)
  b <- lme4::fixef(m)[["Days"]]
  v <- as.matrix(vcov(m))[2, 2]
  stopifnot("linearHypothesis(lmer): rhs is ignored" =
              close(linearHypothesis(m, "Days", rhs = 10)$Chisq[2], (b - 10)^2 / v))
  stopifnot("linearHypothesis(lmer): rhs disagrees with the string form" =
              close(linearHypothesis(m, "Days", rhs = 10)$Chisq[2],
                    linearHypothesis(m, "Days = 10")$Chisq[2]))
  stopifnot("linearHypothesis(lmer): matrix form ignores rhs" =
              close(linearHypothesis(m, matrix(c(0, 1), 1), rhs = 10)$Chisq[2], (b - 10)^2 / v))

  g <- lme4::glmer(cbind(incidence, size - incidence) ~ period + (1 | herd),
                   lme4::cbpp, binomial)
  bg <- lme4::fixef(g)[["period2"]]
  vg <- as.matrix(vcov(g))[2, 2]
  stopifnot("linearHypothesis(glmer): rhs is ignored" =
              close(linearHypothesis(g, "period2", rhs = -1)$Chisq[2], (bg + 1)^2 / vg))

  if (requireNamespace("pbkrtest", quietly = TRUE)) {
    w <- NULL
    withCallingHandlers(linearHypothesis(m, "Days", rhs = 10, test = "F"),
                        warning = function(cond) {
                          w <<- conditionMessage(cond)
                          invokeRestart("muffleWarning")
                        })
    stopifnot("linearHypothesis(lmer, test = 'F'): no warning that rhs is ignored" =
                identical(w, "rhs of hypothesis ignored, set to 0"))
  }
}
