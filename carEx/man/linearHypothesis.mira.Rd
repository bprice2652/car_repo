\name{linearHypothesis.mira}
\alias{linearHypothesis.mira}
\alias{coef.mira}
\alias{vcov.mira}
\title{Linear Hypothesis Tests for mira Objects}

\description{
These functions provide a \code{"mira"} method for the \code{\link[car]{linearHypothesis}} function in the \pkg{car} package, along with basic \code{coef} and \code{vcov} methods that apply ``Rubin's Rules'' for combining estimates across imputations. \code{\link[mice]{mira}} objects are produced by fitting statistical models to multiply imputed data sets using functions in the \pkg{mice} package: \code{\link[mice]{mice-package}}.
}
\usage{
\method{linearHypothesis}{mira}(model, hypothesis.matrix, rhs = NULL, ...)
\method{coef}{mira}(object, ...)
\method{vcov}{mira}(object, ...)
}

\details{
Wald test statistics and degrees of freedom for linear hypotheses are computed by the approximate method described in Reiter (2007) if the complete-data residual degrees of freedom are known and by the method in Rubin (1987) if they are not.
}

\arguments{
  \item{model, object}{an object of class \code{"mira"} produced by the \pkg{mice} package, \code{\link[mice]{mice-package}}.}
  \item{hypothesis.matrix}{hypothesis in matrix or symbolic form: see \code{\link[car]{linearHypothesis}} for details.}
  \item{rhs}{right-hand side vector for the hypothesis, defaults to zeros.}
  \item{\dots}{not used.}
}

\references{
J. Fox, \emph{Applied Regression Analysis and Generalized Linear Models, 3rd ed.}, Sage, 2016.

S. van Buuren, \emph{Flexible Imputation of Missing Data, 2nd ed.}, Chapman and Hall, 2018.

J. P. Reiter, Small-sample degrees of freedom for multi-component significance tests with multiple imputation for missing data. \emph{Biometrika}, 2007, 94: 502-508.

D. B. Rubin, \emph{Multiple Imputation for Nonresponse in Surveys}, Wiley, 1987.
}

\author{John Fox \email{jfox@mcmaster.ca}}

\seealso{\code{\link[car]{linearHypothesis}}, \code{\link[mice]{mira}}, \code{\link[mice]{mice-package}}.}

\examples{
if (require(mice)){
    nhanes2$age <- factor(nhanes2$age, 
        labels=c("age20.39", "40.59", "60.99"))
    imps <- mice(nhanes2, m=10, print=FALSE, seed=12345)
    models <- with(imps, lm(chl ~ age + bmi))
    linearHypothesis(models, c("age40.59", "age60.99"))
}

if (require(mice)){
    linearHypothesis(models, "age40.59 = age60.99")

}
}

\keyword{htest}
\keyword{models}
