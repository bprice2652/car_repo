\name{Duncan}
\alias{Duncan}
\docType{data}

\title{Duncan's Occupational Prestige Data}

\description{
  The \code{Duncan} data frame has 45 rows and 4 columns.
  Data on the prestige and other characteristics of 45 U. S. occupations in 1950.
  }

\format{
  This data frame contains the following columns:
  \describe{
    \item{type}{ Type of occupation.
      A factor with the following levels:
        \code{prof}, professional and managerial;
        \code{wc}, white-collar;
        \code{bc}, blue-collar.
      }
    \item{income}{Percentage of occupational incumbents in the 1950 US Census who earned $3,500 or more per year (about $36,000 in 2017 US dollars).      }
    \item{education}{Percentage of occupational incumbents in 1950 who were high school graduates (which, were we cynical, we would say is roughly equivalent to a PhD in 2017)
      }
    \item{prestige}{Percentage of respondents in a social survey who rated the occupation as ``good'' or better in prestige}
    }
  }

\source{
  Duncan, O. D. (1961)
  A socioeconomic index for all occupations.
  In Reiss, A. J., Jr. (Ed.)
  \emph{Occupations and Social Status.} Free Press
  [Table VI-1].
  }

\references{
  Fox, J. (2016)
  \emph{Applied Regression Analysis and Generalized Linear Models},
  Third Edition. Sage.

  Fox, J. and Weisberg, S. (2019)
  \emph{An R Companion to Applied Regression}, Third Edition, Sage.
}

\usage{
Duncan
}

\keyword{datasets}
