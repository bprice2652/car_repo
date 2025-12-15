\name{deltaMethod.mira}
\alias{deltaMethod.mira}
\title{deltaMethod Method for mira Objects}

\description{This function provides a \code{"mira"} method for the \code{\link[car]{deltaMethod}} function in the \pkg{car} package. \code{\link[mice]{mira}} objects are produced by fitting statistical models to multiply imputed data sets using functions in the \pkg{mice} package: \code{\link[mice]{mice-package}}.}

\usage{
\method{deltaMethod}{mira}(object, ...)
}

\arguments{
  \item{object}{an object of class \code{"mira"} produced by the \pkg{mice} package, \code{\link[mice]{mice-package}}.}
  \item{\dots}{other arguments to be passed to \code{\link[car]{deltaMethod}}.}
}

\details{
t-test statistics and degrees of freedom are computed as for Wald tests, using the approach described in Barnard and Rubin (1999) if the complete-data residual degrees of freedom are known and by the approach in Rubin (1987) if they are not known.
}

\references{
J. Fox, \emph{Applied Regression Analysis and Generalized Linear Models, 3rd ed.}, Sage, 2016.

S. van Buuren, \emph{Flexible Imputation of Missing Data, 2nd ed.}, Chapman and Hall, 2018.

J. Barnard and D. B. Rubin, Small-sample degrees of freedom with multiple imputation. \emph{Biometrika}, 1999, 86:948-955.

D. B. Rubin, \emph{Multiple Imputation for Nonresponse in Surveys}, Wiley, 1987.
}

\author{John Fox \email{jfox@mcmaster.ca}}

\seealso{\code{\link[car]{deltaMethod}}, \code{\link[mice]{mira}}, \code{\link[mice]{mice-package}}.}

\examples{
if (require(mice)){
    nhanes2$age <- factor(nhanes2$age, 
        labels=c("age20.39", "40.59", "60.99"))
    imps <- mice(nhanes2, m=10, print=FALSE, seed=12345)
    models <- with(imps, lm(chl ~ age + bmi))
    deltaMethod(models, "age40.59/age60.99")
}
}

\keyword{htest}
\keyword{models}
