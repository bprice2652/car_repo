\name{UN}
\alias{UN}
\docType{data}
\title{
National Statistics from the United Nations, Mostly From 2009--2011
}
\description{
National health, welfare, and education statistics for 213
places, mostly UN members, but also other areas like Hong Kong that are not
independent countries.
}
\usage{data(UN)}
\format{
  A data frame with 213 rows on the following 7 variables.
  \describe{
    \item{\code{region}}{Region of the world: \code{Africa}, \code{Asia}, \code{Caribbean}, \code{Europe}, 
        \code{Latin Amer}, \code{North America}, \code{NorthAtlantic}, \code{Oceania}.}
    \item{\code{group}}{A factor with levels \code{oecd} for countries that
are members of the OECD, the Organization for Economic Co-operation and
Development, as of May 2012, \code{africa} for countries on the African
continent, and \code{other} for all other countries.  No OECD countries are
located in Africa.}
    \item{\code{fertility}}{Total fertility rate, number of children per woman.}
    \item{\code{ppgdp}}{Per capita gross domestic product in US dollars.}
    \item{\code{lifeExpF}}{Female life expectancy, years.}
    \item{\code{pctUrban}}{Percent urban.}
    \item{\code{infantMortality}}{Infant deaths by age 1 year per 1000 live births}
  }
}

\source{
All data were collected from UN tables accessed at \url{http://unstats.un.org/unsd/demographic/products/socind/}
on April 23, 2012. OECD membership is from \url{https://www.oecd.org/}, accessed
May 25, 2012.
}

\note{
Similar data, from the period 2000-2003, appear in the \code{alr3} package
under the name \code{UN3}. 
This data set was formerly named \code{UNlla} and replaces the older dataset named \code{UN}.
}

\references{
Weisberg, S. (2014). \emph{Applied Linear Regression}, 4th edition.
Hoboken NJ: Wiley.
}
\examples{
summary(UN)
}
\keyword{datasets}
