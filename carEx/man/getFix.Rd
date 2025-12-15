\name{getFix}
\alias{getFix}
\alias{getFix.multinom}
\alias{getFix.lm}
\alias{getFix.glm}
\alias{getFix.lme}
\alias{getFix.gls}
\alias{getFix.merMod}
\alias{getFix.zeroinfl}
\alias{getFix.mipo}
\alias{getFix.MCMCglmm}
\alias{getFix.stanfit}
\alias{getFix.default}
\title{Get Information on Fixed Effects From a Model Object}
\usage{
getFix(fit, ...)

\method{getFix}{multinom}(fit, ...)

\method{getFix}{lm}(fit, ...)

\method{getFix}{glm}(fit, ...)

\method{getFix}{lme}(fit, ...)

\method{getFix}{gls}(fit, ...)

\method{getFix}{merMod}(fit, ...)

\method{getFix}{zeroinfl}(fit, ...)

\method{getFix}{mipo}(fit, ...)

\method{getFix}{MCMCglmm}(fit, ...)

\method{getFix}{stanfit}(fit, pars, include = TRUE, ...)

\method{getFix}{default}(fit, ...)
}
\arguments{
\item{fit}{A fitted model object}

\item{pars}{For the \code{stanfit} method; see \code{\link[rstan]{extract}}.}
          
\item{include}{For the \code{stanfit} method; see \code{\link[rstan]{extract}}.}

\item{\dots}{Other arguments [unused]}
}
\value{
Returns a list with the following components:
     \itemize{
          \item{\code{fixed}}{ fixed effect parameter estimates}
          \item{\code{vcov}}{ covariance matrix of the parameters}
          \item{\code{df}}{ denominator degrees of freedom for each effect}
          }
}
\description{
\code{getFix} extracts coefficients, their covariance matrix, and degrees of
freedom from a model object. Its main purpose is to extract information needed
by the \code{wald} function. To extend the \code{wald} function to a new class of
model objects, it is merely necessary to write a method for \code{getFix}.
}
\details{
Extending the \code{\link{wald}} function to a new class of objects only
requires a \code{getFix} method for the new class.
}
\section{Methods (by class)}{
\itemize{
\item \code{multinom}: method for \code{\link[nnet]{multinom}} objects in package \pkg{nnet}

\item \code{lm}: method for \code{\link{lm}} objects

\item \code{glm}: method for \code{\link{glm}} objects

\item \code{lme}: method for \code{\link[nlme]{lme}} objects in the \pkg{nlme} package

\item \code{gls}: method for \code{\link[nlme]{gls}} objects in the \pkg{nlme} package

\item \code{merMod}: method for \code{\link[lme4]{merMod}} objects in the \pkg{lme4} package

\item \code{zeroinfl}: method for \code{\link[pscl]{zeroinfl}} objects in the \pkg{pscl} package

\item \code{mipo}: method for \code{\link[mice]{mipo}} objects in the \pkg{mice} package

\item \code{MCMCglmm}: method for \code{\link[MCMCglmm]{MCMCglmm}} objects in the \pkg{MCMCglmm} package

\item \code{stanfit}: method for \code{\link[rstan]{stanfit}} objects in the \pkg{rstan} package

\item \code{default}: prints an error message if \code{getFix} is used for a class for which a method has not been written
}}

\examples{
mod.prestige <- lm(prestige ~ education + income, data=Prestige)
getFix(mod.prestige)

\dontrun{
# Example of a getFix method for a glm object:

print(carEx:::getFix.glm)

# Example of a getFix method for a mipo object in the mice package:

print(carEx:::getFix.mipo)
}

}
\seealso{
\code{\link{wald}}
}
\author{
Georges Monette
}
