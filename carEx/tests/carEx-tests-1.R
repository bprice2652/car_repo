# tests of mira methods for linearHypothesis(), Anova(), deltaMethod()

# last modified 2018-08-31

if (require(mice) && require(carEx)){
    nhanes2$age <- factor(nhanes2$age, labels=c("age20.39", "40.59", "60.99"))
    imps <- mice(nhanes2, m=10, print=FALSE, seed=12345)
    mods.1 <- with(imps, lm(chl ~ age + bmi))
    mods.2 <- with(imps, lm(chl ~ bmi))
    l.1 <- linearHypothesis(mods.1, c("age40.59", "age60.99"))
    m.1 <- D1(mods.1, mods.2)
    a.1 <- Anova(mods.1)
    l.2 <- linearHypothesis(mods.1, "bmi")
    d.2 <- deltaMethod(mods.1, "bmi")
    if (!isTRUE(all.equal(as.vector(m.1$result[, "F.value"]), l.1[, "F"])))
        stop("failed test 1-1a")
    if (!isTRUE(all.equal(as.vector(m.1$result[, "df2"]), l.1[, "den df"])))
        stop("failed test 1-1b")
    if (!isTRUE(all.equal(l.1[, "F"], a.1[1, "F"])))
        stop("failed test 1-2")
    if (!isTRUE(all.equal(l.2[, "F"], (d.2[, "Estimate"]/d.2[, "SE"])^2)))
        stop("failed test 1-3")
    if (!isTRUE(all.equal(summary(pool(mods.1))[, "estimate"], as.vector(coef(mods.1)))))
        stop("failed test 1-4")
    if (!isTRUE(all.equal(summary(pool(mods.1))[, "std.error"], as.vector(sqrt(diag(vcov(mods.1)))))))
        stop("failed test 1-5")
    }