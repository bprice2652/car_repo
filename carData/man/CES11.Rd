\name{CES11}
\alias{CES11}
\docType{data}
\title{
2011 Canadian National Election Study, With Attitude Toward Abortion}
\description{
Data are drawn from the 2011 Canadian National Election Study, including a question on banning abortion and variables related to the sampling design.}
\usage{data("CES11")}
\format{
  A data frame with 2231 observations on the following 9 variables.
  \describe{
    \item{\code{id}}{Household ID number.}
    \item{\code{province}}{a factor with (alphabetical) levels \code{AB}, \code{BC}, \code{MB}, \code{NB}, \code{NL}, \code{NS}, \code{ON}, \code{PE}, \code{QC}, \code{SK}; the sample was stratified by province.}
    \item{\code{population}}{population of the respondent's province, number over age 17.}
    \item{\code{weight}}{weight sample to size of population, taking into account unequal sampling probabilities by province and household size.}
    \item{\code{gender}}{a factor with levels \code{Female}, \code{Male}.}
    \item{\code{abortion}}{attitude toward abortion, a factor with levels \code{No}, \code{Yes}; answer to the question "Should abortion be banned?"}
    \item{\code{importance}}{importance of religion, a factor with (alphabetical) levels \code{not}, \code{notvery}, \code{somewhat}, \code{very}; answer to the question, "In your life, would you say that religion is very important, somewhat important, not very important, or not important at all?"}
    \item{\code{education}}{a factor with (alphabetical) levels \code{bachelors} (Bachelors degree), \code{college} (community college or technical school), \code{higher} (graduate degree), \code{HS} (high-school graduate), \code{lessHS} (less than high-school graduate), \code{somePS} (some post-secondary).}
    \item{\code{urban}}{place of residence, a factor with levels \code{rural}, \code{urban}.}
  }
}
\details{
This is an extract from the data set for the 2011 Canadian National Election Study distributed by the Institute for Social Research, York University.
}

\references{
Fournier, P., Cutler, F., Soroka, S., and Stolle, D. (2013). 
Canadian Election Study 2011: Study documentation. 
Technical report, Canadian Opinion Research Archive, 
Queen's University, Kingson,Ontario.

Northrup, D. (2012). 
The 2011 Canadian Election Survey: Technical documention. 
Technical report, Institute for Social Research, 
York University, Toronto, Ontario.
}


\examples{
summary(CES11)
}
\keyword{datasets}
