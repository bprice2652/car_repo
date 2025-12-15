\name{MplsStops}
\alias{MplsStops}
\docType{data}
\title{
Minneapolis Police Department 2017 Stop Data
}
\description{
Results of nearly all stops made by the Minneapolis Police Department for the year 2017.
}
\format{
  A data frame with 51857 observations on the following 14 variables.
  \describe{
    \item{\code{idNum}}{character vector of incident identifiers}
    \item{\code{date}}{a POSIXlt date variable giving the date and time of the stop}
    \item{\code{problem}}{a factor with levels \code{suspicious} for suspicious vehicle or person stops and  \code{traffic} for traffic stops}
    \item{\code{citationIssued}}{a factor with levels \code{no} \code{yes} indicating if a citation was issued}
    \item{\code{personSearch}}{a factor with levels \code{no} \code{yes} indicating if the stopped person was searched}
    \item{\code{vehicleSearch}}{a factor with levels \code{no} or \code{yes} indicating if a vehicle was searched}
    \item{\code{preRace}}{a factor with levels \code{white}, \code{black}, \code{east african}, \code{latino}, \code{native american}, \code{asian}, \code{other}, \code{unknown} for the officer's assessment of race of the person stopped before speaking with the person stopped}
    \item{\code{race}}{a factor with levels \code{white}, \code{black}, \code{east african}, \code{latino}, \code{native american}, \code{asian}, \code{other}, \code{unknown}, officer's determination of race after the incident}
    \item{\code{gender}}{a factor with levels \code{female}, \code{male}, \code{unknown}, gender of person stopped}
    \item{\code{lat}}{latitude of the location of the incident, somewhat rounded}
    \item{\code{long}}{latitude of the location of the incident, somewhat rounded}
    \item{\code{policePrecinct}}{Minneapolis Police Precinct number}
    \item{\code{neighborhood}}{a factor with 84 levels giving the name of the Minneapolis neighborhood of the incident}
    \item{\code{MDC}}{a factor with levels \code{mdc} for data collected via in-vehicle computer, and \code{other} for data submitted by officers not in a vehicle, either on foot, bicycle or horseback.  Several of the variables above were recorded only in-vehicle}
  }
}
\details{
A few stops have been deleted, either because thesu location data was missing, or a few very rare categories were also removed.  The data frame \code{\link{MplsDemo}} contains 2015 demongraphic data on Minneapolis neighborhoods, using the same neighborhood names as this data file.  Demographics are available for 84 of Minneaolis' 87 neighborhoods.  The remaining 3 presumably have no housing.
}
\source{
These are public data obtained from <http://opendata.minneapolismn.gov/datasets/police-stop-data>.  A few more fields, and more data, are available at the original source
}
\examples{
summary(MplsStops)
}
\keyword{datasets}
