\name{Vocab}
\alias{Vocab}
\docType{data}

\title{Vocabulary and Education}

\description{
The \code{Vocab} data frame has 30,351 rows and 4 columns.
The observations are respondents to U.S. General Social Surveys, 1972-2016.
}

\format{
  This data frame contains the following columns:
  \describe{
  	\item{year}{Year of the survey.}
  	\item{sex}{Sex of the respondent, \code{Female} or \code{Male}.}
    \item{education}{
      Education, in years.
      }
    \item{vocabulary}{
      Vocabulary test score: number correct on a 10-word test.
      }
    }
  }

\source{
 National Opinion Research Center
 \emph{General Social Survey.} 
 GSS Cumulative Datafile 1972-2016, downloaded from \url{http://gss.norc.org/}.
}

\references{
  Fox, J. (2016)
  \emph{Applied Regression Analysis and Generalized Linear Models},
  Third Edition. Sage.  
  
  Fox, J. and Weisberg, S. (2019) 
  \emph{An R Companion to Applied Regression}, Third Edition, Sage.
}


\usage{
Vocab
}

\keyword{datasets}
