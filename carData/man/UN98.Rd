\name{UN98}
\alias{UN98}
\docType{data}
\title{
United Nations Social Indicators Data 1998]
}
\description{
Social indicators data on 207 nations distributed by the United Nations circa 1998.
}
\usage{data("UN98")}

\format{
  A data frame with 207 observations on the following 13 variables.
  \describe{
    \item{\code{region}}{a factor with alphabetical levels \code{Africa}, \code{America}, \code{Asia}, \code{Europe}, \code{Oceania}.}
    \item{\code{tfr}}{total fertility rate, number of children per woman.}
    \item{\code{contraception}}{percentage of married women using any method of contraception.}
    \item{\code{educationMale}}{average number of years of education for men.}
    \item{\code{educationFemale}}{average number of years of education for women.}
    \item{\code{lifeMale}}{expectation of life at birth for males.}
    \item{\code{lifeFemale}}{expectation of life at birth for females.}
    \item{\code{infantMortality}}{infant deaths per 1000 live births.}
    \item{\code{GDPperCapita}}{gross domestic product per person in U.S. dollars.}
    \item{\code{economicActivityMale}}{percentage of men who are economically active.}
    \item{\code{economicActivityFemale}}{percentage of women who are economically active.}
    \item{\code{illiteracyMale}}{percentage of males 15 years of age and older who are illiterate.}
    \item{\code{illiteracyFemale}}{percentage of females 15 years of age and older who are illiterate.}
  }
}
\details{
In a few cases where the percentages of males and females 15 and older who are illiterate were unavailable, these variables were filled in by regression imputation from the corresponding percentages 25 and older who are illiterate.
}
\source{
Downloaded from \code{http://www.un.org/Depts/unsd/social/main.htm} in 1998.
}

\examples{
summary(UN98)
}
\keyword{datasets}
