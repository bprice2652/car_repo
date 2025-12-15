\name{OBrienKaiserLong}
\alias{OBrienKaiserLong}
\docType{data}

\title{O'Brien and Kaiser's Repeated-Measures Data in "Long" Format}

\description{Contrived repeated-measures data from O'Brien and Kaiser (1985). For details see \code{\link{OBrienKaiser}}, which is for the "wide" form of the same data.}

\usage{OBrienKaiserLong}

\format{
  A data frame with 240 observations on the following 6 variables.
  \describe{
    \item{\code{treatment}}{a between-subjects factor with levels \code{control}, \code{A}, \code{B}.}
    \item{\code{gender}}{a between-subjects factor with levels \code{F}, \code{M.}}
    \item{\code{score}}{the numeric response variable.}
    \item{\code{id}}{the subject id number.}
    \item{\code{phase}}{a within-subjects factor with levels \code{pre}, \code{post}, \code{fup}.}
    \item{\code{hour}}{a within-subjects factor with levels \code{1}, \code{2}, \code{3}, \code{4}, \code{5}.}
  }
}

\source{
  O'Brien, R. G., and Kaiser, M. K. (1985)
  MANOVA method for analyzing repeated measures designs: An extensive primer.
  \emph{Psychological Bulletin} \bold{97}, 316--333, Table 7.
}

\examples{
head(OBrienKaiserLong, 15) # first subject
}

\seealso{\code{\link{OBrienKaiser}}.}

\keyword{datasets}
