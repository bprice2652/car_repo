\name{MplsDemo}
\alias{MplsDemo}
\docType{data}
\title{
Minneapolis Demographic Data 2015, by Neighborhood
}
\description{
Minneapolis Demographic Data 2015, by Neighborhood, from the 2015 American Community Survey
}
\format{
  A data frame with 84 observations on the following 7 variables.
  \describe{
    \item{\code{neighborhood}}{name of the neighborhood}
    \item{\code{population}}{total population }
    \item{\code{black}}{fraction of the population estimated to be black}
    \item{\code{white}}{fraction of the population estimated to be white}
    \item{\code{foreignBorn}}{fraction of the population estimated to be foreign born}
    \item{\code{hhIncome}}{estimated median household income}
    \item{\code{poverty}}{estimated fraction earning less than twice the poverty level}
    \item{\code{collegeGrad}}{estimated fraction with a college degree}
  }}
\details{
The data frame \code{\link{MplsStops}} contains 2017 Minneapolis Police stop data, using the same neighborhood names as this data file.
}
\source{
http://www.mncompass.org/profiles/neighborhoods/minneapolis-saint-paul#!community-areas
}
\examples{
str(MplsDemo)
}
\keyword{datasets}
