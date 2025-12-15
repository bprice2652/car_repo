\name{getX}
\alias{getX}
\title{Model Matrix for a Fit, Possibly on a New Data Frame}
\usage{
getX(fit, data = getData(fit))
}
\arguments{
\item{fit}{a fitted object with formula method}

\item{data}{(default NULL) a data frame on which to evaluate the model matrix}
}
\value{
a design matrix
}
\description{
This function returns the X matrix for a fit, possibly based on a different data frame than the model.
It performs a function very close to that of \code{\link{model.matrix}} except that \code{model.matrix}
expects the variable for the LHS of the formula to be in the data set, ostensibly in order to remove rows
for which the LHS variable(s) are NA. In addition, \code{getX} attaches the argument data set as an attribute.
}
\details{
Extending \code{getX} to new classes merely requires a \code{\link{getData}} method. The \code{\link{formula}} method is also used but usually already exists.
}
