\name{Anova.mira}
\alias{Anova.mira}
\title{ANOVA for mira Objects}

\description{This function provides a \code{"mira"} method for the \code{\link[car]{Anova}} function in the \pkg{car} package. \code{\link[mice]{mira}} objects are produced by fitting statistical models to multiply imputed data sets using functions in the \pkg{mice} package: \code{\link[mice]{mice-package}}.}
\usage{
\method{Anova}{mira}(mod, type = c("II", "III", 2, 3), ...)
}

\arguments{
  \item{mod}{an object of class \code{"mira"} produced by the \pkg{mice} package, \code{\link[mice]{mice-package}}.}
  \item{type}{type of test, see \code{\link[car]{Anova}}.}
  \item{\dots}{not used.}
}

\details{The tests produced are Wald tests, using the total covariance matrix for the model coefficients (including components for within and between-imputations variation) to formulate the hypothesis matrices for type II tests.}

\references{
J. Fox, \emph{Applied Regression Analysis and Generalized Linear Models, 3rd ed.}, Sage, 2016.

S. van Buuren, \emph{Flexible Imputation of Missing Data, 2nd ed.}, Chapman and Hall, 2018.
}
\author{John Fox \email{jfox@mcmaster.ca}}

\seealso{\code{\link[car]{Anova}}, \code{\link{linearHypothesis.mira}}, \code{\link[mice]{mira}}, \code{\link[mice]{mice-package}}.}

\examples{
if (require(mice)){
    nhanes2$age <- factor(nhanes2$age, 
        labels=c("age20.39", "40.59", "60.99"))
    imps <- mice(nhanes2, m=10, print=FALSE, seed=12345)
    models <- with(imps, lm(chl ~ age + bmi))
    Anova(models)
}
}

\keyword{htest}
\keyword{models}
