\name{Rossi}
\alias{Rossi}
\docType{data}
\title{Rossi et al.'s Criminal Recidivism Data}
\description{
  This data set is originally from Rossi et al. (1980), and is used as an example
  in Allison (1995). The data pertain to 432 convicts who were released from
  Maryland state prisons in the 1970s and who were followed up for one
  year after release. Half the released convicts were assigned at random to
  an experimental treatment in which they were given financial aid; half did not
  receive aid.
}
\usage{Rossi}

\format{
  A data frame with 432 observations on the following 62 variables.
  \describe{
    \item{\code{week}}{week of first arrest after release or censoring; all censored
      observations are censored at 52 weeks.}
    \item{\code{arrest}}{\code{1} if arrested, \code{0} if not arrested.}
    \item{\code{fin}}{financial aid: \code{no} \code{yes}.}
    \item{\code{age}}{in years at time of release.}
    \item{\code{race}}{\code{black} or \code{other}.}
    \item{\code{wexp}}{full-time work experience before incarceration: \code{no} or \code{yes}.}
    \item{\code{mar}}{marital status at time of release: \code{married} or \code{not married}.}
    \item{\code{paro}}{released on parole? \code{no} or \code{yes}.}
    \item{\code{prio}}{number of convictions prior to current incarceration.}
    \item{\code{educ}}{level of education: \code{2} = 6th grade or less;
    	\code{3} = 7th to 9th grade; \code{4} = 10th to 11th grade;
    	\code{5} = 12th grade; \code{6} = some college.}
    \item{\code{emp1}}{employment status in the first week after release: \code{no} or \code{yes}.}
    \item{\code{emp2}}{as above.}
    \item{\code{emp3}}{as above.}
    \item{\code{emp4}}{as above.}
    \item{\code{emp5}}{as above.}
    \item{\code{emp6}}{as above.}
    \item{\code{emp7}}{as above.}
    \item{\code{emp8}}{as above.}
    \item{\code{emp9}}{as above.}
    \item{\code{emp10}}{as above.}
    \item{\code{emp11}}{as above.}
    \item{\code{emp12}}{as above.}
    \item{\code{emp13}}{as above.}
    \item{\code{emp14}}{as above.}
    \item{\code{emp15}}{as above.}
    \item{\code{emp16}}{as above.}
    \item{\code{emp17}}{as above.}
    \item{\code{emp18}}{as above.}
    \item{\code{emp19}}{as above.}
    \item{\code{emp20}}{as above.}
    \item{\code{emp21}}{as above.}
    \item{\code{emp22}}{as above.}
    \item{\code{emp23}}{as above.}
    \item{\code{emp24}}{as above.}
    \item{\code{emp25}}{as above.}
    \item{\code{emp26}}{as above.}
    \item{\code{emp27}}{as above.}
    \item{\code{emp28}}{as above.}
    \item{\code{emp29}}{as above.}
    \item{\code{emp30}}{as above.}
    \item{\code{emp31}}{as above.}
    \item{\code{emp32}}{as above.}
    \item{\code{emp33}}{as above.}
    \item{\code{emp34}}{as above.}
    \item{\code{emp35}}{as above.}
    \item{\code{emp36}}{as above.}
    \item{\code{emp37}}{as above.}
    \item{\code{emp38}}{as above.}
    \item{\code{emp39}}{as above.}
    \item{\code{emp40}}{as above.}
    \item{\code{emp41}}{as above.}
    \item{\code{emp42}}{as above.}
    \item{\code{emp43}}{as above.}
    \item{\code{emp44}}{as above.}
    \item{\code{emp45}}{as above.}
    \item{\code{emp46}}{as above.}
    \item{\code{emp47}}{as above.}
    \item{\code{emp48}}{as above.}
    \item{\code{emp49}}{as above.}
    \item{\code{emp50}}{as above.}
    \item{\code{emp51}}{as above.}
    \item{\code{emp52}}{as above.}
  }
}

\source{
  Allison, P.D. (1995). \emph{Survival Analysis Using the SAS System: A Practical Guide.}
  Cary, NC: SAS Institute.
}

\references{
  	Rossi, P.H., R.A. Berk, and K.J. Lenihan (1980). \emph{Money, Work, and Crime:
  	Some Experimental Results.} New York: Academic Press.
  
  	John Fox, Marilia Sa Carvalho (2012).
    The RcmdrPlugin.survival Package: Extending the R Commander Interface to Survival Analysis.
    \emph{Journal of Statistical Software}, 49(7), 1-32.
} 

\examples{
summary(Rossi)
}
\keyword{datasets}
