\name{GSSvocab}
\alias{GSSvocab}
\docType{data}
\title{
Data from the General Social Survey (GSS) from the National Opinion Research Center of the University of Chicago.
}
\description{
This data set illustrates analyis of a multifactor observational study, with response given by subject's score on a vocabulary test, and factors for age group, education level, natality status, gender and year of the survey.
}
\usage{data("GSSvocab")}
\format{
  A data frame with 28867 observations on the following 8 variables.
  \describe{
    \item{\code{year}}{a factor with levels \code{1978} \code{1982} \code{1984} \code{1987} \code{1988} \code{1989} \code{1990} \code{1991} \code{1993} \code{1994} \code{1996} \code{1998} \code{2000} \code{2004} \code{2006} \code{2008} \code{2010} \code{2012} \code{2014} \code{2016}.  Data are included from the GSS for each of these years.}
    \item{\code{gender}}{a factor with levels \code{female} \code{male}}
    \item{\code{nativeBorn}}{Was the respondent born in the US?  A factor with levels \code{no} and \code{yes}.}
    \item{\code{ageGroup}}{a factor with levels \code{18-29} \code{30-39} \code{40-49} \code{50-59} \code{60+}, grouped age of the respondent.}
    \item{\code{educGroup}}{a factor with levels \code{<12 yrs} \code{12 yrs} \code{13-15 yrs} \code{16 yrs} \code{>16 yrs}, grouped education level of the respondent.  12 years corresponds to high school graduate, 16 years to college graduate.}
    \item{\code{vocab}}{Number of words out of 10 correct on a vocabulary test}
    \item{\code{age}}{age of the respondent in years}
    \item{\code{educ}}{years of education of the respondent}
  }
}
\details{
This file includes the years of the GSS for which the \code{vocab} and \code{nativeBorn} items were included.
}
\source{
These data were collected from the GSS data explorer \url{https://gssdataexplorer.norc.org}, using the data fields \code{year}, \code{id_}, \code{age}, \code{educ}, \code{sex}, \code{born} and \code{wordsum}.  The GSS began in 1972, and has included several thousand data items, some regularly and some only once, on topics of interest to social scientists.  Data have been slightly edited to change entires like \code{No answer} and \code{Not applicable} to missing value codes.
}
\examples{
data(GSSvocab)
}
\keyword{datasets}
