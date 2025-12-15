\name{Unemployment}
\alias{Unemployment}
\docType{data}
\title{
Canadian Monthly Unemployment Rate
}
\description{
Monthly unemployment data for Canada for the period 1995-01-01 through 2019-02-01
}

\usage{Unemployment}

\format{
  A data frame with 290 observations on the following 2 variables.
  \describe{
    \item{\code{date}}{a \code{"Date"} object.}
    
    \item{\code{unemployment}}{Percentage unemployed.}
  }
}

\source{
Downloaded from \url{https://research.stlouisfed.org/} on 2019-03-18.
}

\examples{
 plot(unemployment ~ date, type="l", lwd=2, data=Unemployment)
}
\keyword{datasets}
